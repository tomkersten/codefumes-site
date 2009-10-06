class Subscription < ActiveRecord::Base
  include AASM
  validates_presence_of :plan_id, :user_id
  validates_associated  :plan
  belongs_to :user
  belongs_to :plan

  aasm_column :state
  aasm_initial_state :unconfirmed
  aasm_state :unconfirmed
  aasm_state :confirmed
  aasm_state :cancelled

  aasm_event :confirm do
    transitions :to => :confirmed, :from => [:unconfirmed]
  end

  aasm_event :cancel do
    transitions :to => :cancelled, :from => [:confirmed]
  end

  named_scope :confirmed, :conditions => {:state => "confirmed"}
  named_scope :unconfirmed, :conditions => {:state => "unconfirmed"}
  named_scope :cancelled, :conditions => {:state => "cancelled"}
  named_scope :confirmed_or_cancelled, :conditions => ["state in (?)",['confirmed', 'cancelled']]
end
