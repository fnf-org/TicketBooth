# == Schema Information
#
# Table name: stripe_payment_intents
#
#  id                 :bigint           not null, primary key
#  amount             :integer          not null
#  description        :string
#  last_payment_error :string
#  status             :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  customer_id        :string
#  intent_id          :string           not null
#  payment_id         :integer
#
# Indexes
#
#  index_stripe_payment_intents_on_intent_id   (intent_id)
#  index_stripe_payment_intents_on_payment_id  (payment_id)
#
# Foreign Keys
#
#  fk_rails_...  (payment_id => payments.id)
#
class StripePaymentIntent < ApplicationRecord
  belongs_to :payment

  attr_accessor :client_secret
end
