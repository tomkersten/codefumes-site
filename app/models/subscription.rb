class Subscription < ActiveRecord::Base
  validates_presence_of :plan_id, :user_id
  validates_associated  :plan
  belongs_to :user
  belongs_to :plan
end
