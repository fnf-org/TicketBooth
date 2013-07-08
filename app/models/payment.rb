class Payment < ActiveRecord::Base
  STATUSES = [
    STATUS_IN_PROGRESS = 'P',
    STATUS_RECEIVED = 'R',
  ]

  belongs_to :ticket_request

  attr_accessible :ticket_request_id, :ticket_request_attributes, :status, :stripe_card_token

  accepts_nested_attributes_for :ticket_request,
                                reject_if: :modifying_forbidden_attributes?

  attr_accessor :stripe_card_token

  validates :ticket_request, presence: true, existence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  def save_and_charge!
    if valid?
      charge = Stripe::Charge.create(
        amount: (ticket_request.cost * 100).to_i, # in cents
        currency: 'usd',
        card: stripe_card_token,
        description: "#{ticket_request.event.name} Ticket",
      )
      self.stripe_charge_id = charge.id
      self.status = STATUS_RECEIVED
      save
    end
  rescue Stripe::StripeError => e
    errors.add :base, e.message
    false
  end

  def can_view?(user)
    ticket_request.can_view?(user)
  end

  def due_date
    (created_at + 2.weeks).to_date
  end

  def in_progress?
    status == STATUS_IN_PROGRESS
  end

  def received?
    status == STATUS_RECEIVED
  end

private

  def modifying_forbidden_attributes?(attributed)
    # Only allow donation field to be updated
    attributed.any? do |attribute, value|
      !%w[donation id].include?(attribute.to_s)
    end
  end
end
