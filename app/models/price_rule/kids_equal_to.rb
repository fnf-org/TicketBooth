# frozen_string_literal: true

# == Schema Information
#
# Table name: price_rules
#
#  id            :integer          not null, primary key
#  type          :string
#  event_id      :integer
#  price         :decimal(8, 2)
#  trigger_value :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_price_rules_on_event_id  (event_id)
#

class PriceRule
  class KidsEqualTo < ::PriceRule
    def calc_price(ticket_request)
      price if ticket_request.kids == trigger_value
    end

    # TODO: Move this to a view model
    def rule_text
      "If #{trigger_value} #{'kid'.pluralize(trigger_value)}, price is $#{price.round}"
    end
  end
end
