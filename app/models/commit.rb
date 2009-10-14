class Commit < ActiveRecord::Base
  # Validations
  validates_presence_of :identifier
  validates_uniqueness_of :identifier

  # Associations
  has_many :revisions, :dependent => :destroy
  has_many :projects, :through => :revisions
  has_many :bridges_as_parent, :class_name => "RevisionBridge", :foreign_key => :parent_id, :dependent => :destroy
  has_many :bridges_as_child, :class_name => "RevisionBridge", :foreign_key => :child_id, :dependent => :destroy
  has_many :children, :through => :bridges_as_parent, :class_name => "Commit"
  has_many :parents, :through => :bridges_as_child, :class_name => "Commit"
  has_many :custom_attributes, :class_name => "CommitAttribute" do
    def [](name)
      first(:conditions => {:name => name.to_s})
    end
  end

  # Lifecycle hooks
  after_save :store_custom_attributes

  def to_param
    identifier
  end

  def committer
    "#{committer_name} [#{committer_email}]"
  end

  def child_identifiers=(csv_identifier_list)
    bridges_as_parent.destroy_all && bridges_as_parent.reload
    identifiers = csv_identifier_list.split(",").map(&:strip)
    children << identifiers.flatten.map {|identifier| Commit.find_or_create_by_identifier(identifier)}
  end

  def parent_identifiers=(csv_identifier_list)
    bridges_as_child.destroy_all && bridges_as_child.reload
    identifiers = csv_identifier_list.split(",").map(&:strip)
    parents << identifiers.flatten.map {|identifier| Commit.find_or_create_by_identifier(identifier)}
  end

  def author
    "#{author_name} [#{author_email}]"
  end

  def merge?
    parents.size > 1
  end

  def parent_identifiers(format = :full)
    parents.map {|parent| format == :full ? parent.identifier : parent.short_identifier}
  end

  def self.normalize_params(params)
    params.inject({}) do |normalized_params, key_value_pair|
      key, value = key_value_pair
      if standard_attribute?(key) || key.to_sym == :custom_attributes
        normalized_params.merge! key => value
      else
        normalized_params
      end
    end
  end

  def custom_attributes=(a_hash)
    raise ArgumentErorr, "Hash expected" unless a_hash.is_a?(Hash)
    @custom_attributes = a_hash.delete_if {|key, value| key == :custom_attributes}
  end

  def short_identifier
    identifier[0...8]
  end

  private
    def self.standard_attribute?(some_key)
      some_key.to_s == 'parent_identifiers' || column_names.include?(some_key.to_s)
    end

    # This is messy
    # TODO: clean this up
    def store_custom_attributes
      return if @custom_attributes.blank?
      unless @custom_attributes.is_a?(Hash)
        raise ArgumentError, "Custom attributes must be key-value pairs"
      end

      @custom_attributes.each do |name, value|
        custom_attributes.find_or_create_by_name(:name => name.to_s, :value => value.to_s)
      end
    end
end
