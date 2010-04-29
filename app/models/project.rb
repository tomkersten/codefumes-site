class Project < ActiveRecord::Base
  TOKEN_LENGTH = 4
  PUBLIC = 'public'
  PRIVATE = 'private'
  VISIBILITIES = {"Public" => PUBLIC, "Private" => PRIVATE}

  identifier :public_key

  validates_uniqueness_of :public_key
  validates_inclusion_of :visibility, :in => VISIBILITIES.values
  before_validation_on_create :assign_public_key
  before_validation_on_create :assign_private_key
  before_validation :set_privatized_at

  attr_accessible :name

  has_many :commits, :include => [:custom_attributes, :parents], :dependent => :destroy
  has_many :payloads, :dependent => :destroy
  belongs_to :owner, :class_name => "User"

  named_scope :private, :conditions => {:visibility => PRIVATE}
  named_scope :public,  :conditions => {:visibility => PUBLIC}

  def self.generate_public_key
    generate_unique_key
  end

  def to_param
    public_key
  end
  alias_method :permalink, :to_param

  def to_s
    name.blank? ? public_key : name
  end

  def claimed?
    !owner.blank?
  end

  def commit_head
    return commits.first if commits.count == 1
    commits.find(:first, :conditions => "revision_bridges.parent_id IS NULL", :include => [:project, :bridges_as_parent])
  end

  def recent_commits(ancestry_count = 5)
    return [] if commits.empty?
    # we've started 1-level deep by starting w/ 'commit_head',
    # so the level count must reduce by one
    number = ancestry_count.to_i - 1
    number.times.inject([commit_head]) do |lst, index|
      if lst[index].nil?
        lst
      else
        lst << lst[index].parents.first
      end
    end.compact
  end

  def public?
    visibility == PUBLIC
  end

  def private?
    visibility == PRIVATE
  end

  def covered_by_plan?
    return true if public?
    owner.covered_projects.include?(self)
  end

  def set_visibility_to(visibility_type)
    update_attribute(:visibility, visibility_type.to_s)
  end

  def build_status
    commit_head && commit_head.build_status || Commit::NOBUILDS
  end

  def viewable_by?(user_supplied)
    return true if self.public?
    return true if owner == user_supplied
    false
  end

  private
    def assign_public_key
      self.public_key = self.class.generate_public_key
    end

    def assign_private_key
      self.private_key = self.class.generate_private_key
    end

    def self.generate_private_key
      srand
      rand_string = 10.times.map {random_key}.join
      Digest::SHA1.hexdigest(rand_string)
    end

    # Borrowed heavily from RubyURL source
    # http://github.com/robbyrussell/rubyurl/tree/master
    def self.generate_unique_key
      if (temp_key = random_key) && find_by_public_key(temp_key).nil?
        return temp_key
      else
        generate_unique_key
      end
    end

    # Borrowed heavily from RubyURL source
    # http://github.com/robbyrussell/rubyurl/tree/master
    def self.random_key
      characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890'
      temp_token = ''
      srand
      TOKEN_LENGTH.times do
        pos = rand(characters.length)
        temp_token += characters[pos..pos]
      end
      temp_token
    end

    def set_privatized_at
      if private? and privatized_at.blank?
        self.privatized_at = Time.now.utc
      end
    end
end
