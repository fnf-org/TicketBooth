# frozen_string_literal: true

# == Schema Information
#
# Table name: price_rules
#
#  id            :bigint           not null, primary key
#  price         :decimal(8, 2)
#  trigger_value :integer
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  event_id      :bigint
#
# Indexes
#
#  index_price_rules_on_event_id  (event_id)
#
class PriceRule
  class KidsEqualTo < PriceRule
    def calc_price(ticket_request)
      price if ticket_request.kids == trigger_value
    end

    # TODO: Move this to a view model
    def rule_text
      "If #{trigger_value} #{'kid'.pluralize(trigger_value)}, price is $#{price.round}"
    end
  end
end
