# frozen_string_literal: true

# Applied when a ticket request has indicated that they are bringing a specific
# number of kids.
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
