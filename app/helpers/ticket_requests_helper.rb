# frozen_string_literal: true

module TicketRequestsHelper
  def class_for_table_row(ticket_request)
    case ticket_request.status
    when 'P'
      'bg-warning'
    when 'A'
      ticket_request.payment ? 'bg-info' : 'bg-success'
    end
  end

  def text_class_for_status(ticket_request)
    case ticket_request.status
    when 'P'
      'bg-warning'
    when 'A'
      'bg-warning-subtle'
    when 'D', 'R'
      'bg-danger-subtle'
    when 'C'
      'bg-success-subtle'
    end
  end

  def text_for_status(ticket_request)
    case ticket_request.status
    when 'P'
      'Pending Approval'
    when 'A'
      'Awaiting Payment'
    when 'D'
      'Declined'
    when 'R'
      'Refunded'
    when 'C'
      'Completed'
    else
      'Unknown. Please contact support'
    end
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
      list of staff allowed to arrive early, you'll need to purchase a pass for
      each person in your vehicle.
      HELP
    when :late_departure
      <<-HELP
      If you need to leave after Sunday @ 2PM and are not on the authorized
      list of staff allowed to leave late, you'll need to purchase a pass for
      each person in your vehicle.
      HELP
    when :kids
      # HACK: This copy is specific for TicketBooth--we'll have to add a
      # customization so that this can be set on a per-event basis
      <<-HELP
      Babes in arms are free.
      Kids need to be registered with name and age on the ticket request form.
      Reach out to tickets@fnf.org if you have any questions.
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
      Your donation to the CFAEA general fund goes toward preserving the culture
      of our community by enabling Art! Music! Fun! Donating is entirely
      voluntary, but anything you can provide helps.
      HELP
    end
  end
end
