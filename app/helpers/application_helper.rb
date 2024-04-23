# frozen_string_literal: true

module ApplicationHelper
  def datetimepicker(name, datetime)
    content_tag :div, class: 'date', data: { date: datetime.try(:rfc2822) } do
      text_field_tag(name, datetime, class: 'flatpickr', placeholder: 'Select Date...') +
        content_tag(:i, nil, class: 'icon-calendar')
    end
  end

  def help_mark(help_text, options = {})
    extra_classes = options[:class] || ''
    content_tag :a, class: "help-popover help-inline #{extra_classes}",
                    data: { placement: 'right', content: help_text } do
      content_tag :i, nil, class: 'icon-question-sign'
    end
  end

  def stripe_publishable_api_key
    TicketBooth::Application.config.x.stripe.public_key
  end

  def alert_class(alert_type)
    case alert_type
    when 'notice' then 'alert-info'
    when 'error', 'alert' then 'alert-danger'
    when 'warning' then 'alert-warning'
    else 'alert-primary'
    end
  end

  def alert_log_level(alert_type)
    case alert_type
    when 'notice' then :info
    when 'error', 'alert' then :error
    when 'warning' then :warn
    else :debug
    end
  end
end
