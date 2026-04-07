class SupportTicket < ApplicationRecord
  belongs_to :user

  enum :status, {
    active: 0,
    pending: 1,
    resolved: 2,
    closed: 3
  }

  validates :ticket_number, presence: true, uniqueness: true
  validates :problem_description, presence: true
  validates :status, presence: true

  before_validation :generate_ticket_number, on: :create

  private

  def generate_ticket_number
    self.ticket_number ||= "##{Time.current.strftime('%y%m%d')}#{SecureRandom.random_number(999999).to_s.rjust(6, '0')}"
  end
end