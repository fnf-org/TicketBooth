# frozen_string_literal: true

module ApplicationHelper
  def datetimepicker(name, datetime)
    content_tag :div, class: 'date', data: { date: datetime.try(:rfc2822) } do
      text_field_tag(name, datetime, class: 'flatpickr', placeholder: 'Select Date...') +
        content_tag(:i, nil, class: 'icon-calendar')
    end
  end

  def tooltip_box(content, title: nil, **options, &block)
    css_class = 'tooltip-box ' unless block
    css_class += options[:class] if options[:class]
    block ||= proc { content_tag :strong, nil, class: 'bi bi-question-square' }

    content_tag(:a,
                tabindex: 0,
                role:     'button',
                class:    css_class,
                title:,
                data:     { 'bs-toggle': 'popover', 'bs-content': content, 'bs-trigger': 'focus', 'bs-placement': 'right' },
                &block)
  end

  def alert_class(alert_type)
    case alert_type
    when 'notice' then 'alert-info'
    when 'error', 'alert' then 'alert-danger'
    when 'warning' then 'alert-warning'
    else 'alert-primary'
    end
  end

  def devise_mapping
    Devise.mappings[:user]
  end

  def resource_name
    devise_mapping.name
  end

  def resource_class
    devise_mapping.to
  end

  # def log_in_options
  #   redirect_path = instance_variable_get(:@redirect_path)
  #
  #   redirect_path ? { redirect_to: redirect_path } : {}
  # end
end
