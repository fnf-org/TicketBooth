# encoding: UTF-8
module TicketRequestsHelper
  def class_for_table_row(ticket_request)
    case ticket_request.status
    when 'P'
      'warning'
    when 'A'
      ticket_request.payment ? 'info' : 'success'
    end
  end

  def text_class_for_status(ticket_request)
    case ticket_request.status
    when 'P', 'A'
      'muted'
    when 'D', 'R'
      'text-error'
    when 'C'
      'text-success'
    end
  end

  def text_for_status(ticket_request)
    case ticket_request.status
    when 'P'
      'Pending Approval'
    when 'A'
      if ticket_request.payment && !ticket_request.payment.received?
        'Awaiting Payment via Alternate Method'
      else
        'Awaiting Payment'
      end
    when 'D'
      'Declined'
    when 'R'
      'Refunded'
    when 'C'
      'Completed'
    end
  end

  def price_rules_to_json(event)
    Hash[
      event.price_rules.map do |price_rule|
        [ price_rule.trigger_value, price_rule.price.to_i ]
      end
    ].to_json
  end

  def help_text_for(sym)
    case sym
    when :email
      <<-HELP
      You will use this email to sign in to your account when your tickets are
      ready to be purchased.
      HELP
    when :early_arrival
      <<-HELP
      If you need to arrive before noon on Friday and are not on the authorized
      list of staff allowed to arrive early, you'll need to purchase a pass for each      person in your vehicle. See
      https://cfaea.net/early-arrival-late-departure-policy/
      HELP
    when :late_departure
      <<-HELP
      If you need to leave after Sunday @ 2PM and are not on the authorized
      list of staff allowed to leave late, you'll need to purchase a pass for
      each person in your vehicle. See
      https://cfaea.net/early-arrival-late-departure-policy/
      HELP
    when :kids
      # HACK: This copy is specific for Cloudwatch--we'll have to add a
      # customization so that this can be set on a per-event basis
      <<-HELP
      The cost of tickets for children will be dependent on how many you bring.
      Unfortunately, kids count against our limit capacity with our contract
      at the site.  As much as we would like to allow kids in for free, we
      simply cannot afford it. However, we know we start excluding families
      from attending if we charge too much for kids to attend, and so we've
      attempted to create a pricing model that is reasonable and well-balanced.
      If anyone needs further assistance, check the financial assistance
      checkbox below, and give us a brief explanation of what your needs are.
      We'll do our best to work with you to figure something out.
      HELP
    when :cabins
      <<-HELP
      There are a limited number of wood and tent cabins available.
      Both the cabins and the tents are the same price. We encourage everyone to
      bring their own tents and camping gear so that they don't need a cabin.
      Due to limited availability, we will obviously not be able to grant all
      requests.
      HELP
    when :address
      "We'll mail your tickets to this address."
    when :needs_assistance
      <<-HELP
      We never turn anyone away for financial reasons, and will work with you to
      figure something out. Volunteering for some extra shifts, making payments
      in installments, or requesting discounted tickets are examples of payment
      arrangements we've made in the past.
      HELP
    when :notes
      <<-HELP
      For example, if you checked the box above, tell us what your needs are. If
      you are bringing kids, please include their ages.
      HELP
    when :community_fund_donation
      <<-HELP
      We are a community of individuals from a wide range of socioeconomic
      classes. This diversity contributes to the spirit of the event and ensures
      that it is attended by helping, good-willed, and unique people. Every
      year, there are individuals in this community who are not able to afford
      the full price of a ticket. As a community, we have chosen to come
      together and help these individuals by subsidizing the cost of their
      ticket. By donating to this fund, you are preserving the culture of the
      community by enabling these individuals to attend. Donating is entirely
      voluntary, but anything you can provide helps.
      HELP
    end
  end
end
