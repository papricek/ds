ActionView::Base.field_error_proc = proc do |html_tag, instance|
  html = ""

  form_fields = [
    "textarea",
    "input",
    "select"
  ]

  elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css "label, #{form_fields.join(", ")}"
  elements.each do |element|
    if element.node_name.eql? "label"
      if element["class"]&.include?("Form__role-btn")
        html = element.to_html
      else
        element["class"] = "#{element["class"]} text-danger"
        html = element.to_html
      end
    elsif form_fields.include? element.node_name
      if element["type"] == "radio" && (element["class"]&.include?("btn-check") || element["class"]&.include?("Form__role-input"))
        html = element.to_html
      else
        element["class"] = "#{element["class"]} is-invalid"
        html = element.to_html
        if instance.error_message.kind_of?(Array)
          html << "<div class='invalid-feedback'>#{instance.error_message.uniq.join(', ')}</div>"
        else
          html << "<div class='invalid-feedback'>#{instance.error_message}</div>"
        end
      end
    end
  end
  html.html_safe
end
