class Project < ActiveRecord::Base
  TOKEN_LENGTH = 4
  validates_uniqueness_of :public_key
  validates_uniqueness_of :private_key
  before_validation_on_create :assign_public_key
  before_validation_on_create :assign_private_key

  attr_accessible :name, :public_key

  has_many :revisions, :dependent => :destroy
  has_many :commits, :through => :revisions
  has_many :payloads, :dependent => :destroy

  def self.generate_public_key
    generate_unique_key
  end

  def to_param
    public_key
  end

  def to_s
    name.blank? ? public_key : name
  end

  def commit_head
    commits.find(:first, :order => ["commits.committed_at DESC"])
  end

  private
    def assign_public_key
      if self.public_key.blank?
        self.public_key = self.class.generate_public_key
      end
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
end
