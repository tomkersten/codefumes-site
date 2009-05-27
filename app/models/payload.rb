class Payload < ActiveRecord::Base
  belongs_to :project
  serialize :content
  after_create :process

  private
    def process
      PayloadProcessor.process!(self)
    end
end
