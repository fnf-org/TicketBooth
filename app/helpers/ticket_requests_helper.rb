# encoding: UTF-8
module TicketRequestsHelper
  def class_for_table_row(ticket_request)
    case ticket_request.status
    when 'P'
      'warning'
    when 'A'
      'success'
    when 'D'
      'error'
    end
  end

  def text_class_for_status(ticket_request)
    case ticket_request.status
    when 'P'
      'muted'
    when 'A'
      'text-success'
    when 'D'
      'text-error'
    end
  end

  def text_for_status(ticket_request)
    case ticket_request.status
    when 'P'
      'Pending'
    when 'A'
      'Approved'
    when 'D'
      'Declined'
    end
  end

  def help_text_for(sym)
    case sym
    when :email
      <<-HELP
      You will use this email to sign in to your account when your tickets are
      ready to be purchased.
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
      HELP
    when :cabins
      <<-HELP
      There are a limited number of wood and tent cabins available.
      Both the cabins and the tents are the same price. We encourage everyone to
      bring their own tents and camping gear so that they don't need a cabin.
      Due to limited availability, we will obviously not be able to grant all
      requests.
      HELP
    when :volunteer_shifts
      <<-HELP
      This is not a commitment, but gives us an idea of how many volunteer
      shifts we'll be able to fill (you can enter 0). When the time comes to
      purchase your ticket, you'll be able to sign up for more or fewer shifts
      than you entered here.
      Shifts will be between 1½ – 2 hours long, with a variety of jobs to choose
      from: driving shuttles, directing people at the gate, helping in the
      kitchen, etc. No experience is required as you'll be working with people
      that will show you the ropes.
      HELP
    when :address
      "We'll mail your tickets to this address."
    when :needs_assistance
      <<-HELP
      We never turn anyone away for financial reasons, and will work with you to
      figure something out. Whether that's making you work more volunteer shifts
      or allowing you to pay for your ticket in installments, or something else,
      check this box and explain what your needs are below.
      HELP
    when :notes
      <<-HELP
      For example, if you checked the box above, tell us what your needs are. We
      can't promise that we'll be able to satisfy every request, but we'll do
      our best.
      HELP
    end
  end
end
