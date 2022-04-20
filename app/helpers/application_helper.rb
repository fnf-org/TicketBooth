# frozen_string_literal: true

module ApplicationHelper
  def datetimepicker(name, datetime)
    content_tag :div, class: 'input-datetimepicker input-append date',
                      data: { date: datetime.try(:rfc2822) } do
      text_field_tag(name, nil) +
        content_tag(:span, nil, class: 'add-on icon-calendar')
    end
  end

  def help_mark(help_text, options = {})
    extra_classes = options[:class] || ''
    content_tag :a, class: "help-popover help-inline #{extra_classes}",
                    data: { placement: 'right', content: help_text } do
      content_tag :i, nil, class: 'icon-question-sign'
    end
  end
end
