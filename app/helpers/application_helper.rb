module ApplicationHelper
  def datetimepicker(name, datetime)
    content_tag :div, class: 'input-datetimepicker input-append date',
                      data: { date: datetime.try(:rfc2822) } do
      text_field_tag(name, nil) +
        content_tag(:span, nil, class: 'add-on icon-calendar')
    end
  end
end
