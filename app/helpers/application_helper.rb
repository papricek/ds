module ApplicationHelper
  def icon(name, text: nil, css_class: "", font_style: "fa", data: nil)
    icon_classes = "#{font_style} fa-#{name} #{css_class}"
    html = content_tag(:i, "", class: icon_classes, data: data)
    html += content_tag(:span, " #{text}") if text.present?
    html
  end

  def flash_to_alert(name)
    {
      success: "Alert--success",
      error: "Alert--danger",
      alert: "Alert--warning",
      notice: "Alert--info"
    }[name.to_sym] || "Alert--info"
  end

  def error_message_for(object, attribute)
    return unless object.errors[attribute].any?

    content_tag :div, object.errors[attribute].first, class: "invalid-feedback"
  end

  def error_class_for(object, attribute)
    return "" unless object.errors[attribute].any?

    "is-invalid"
  end

  def disable_with
    "<span class='spinner-border spinner-border-sm text-light'></span> #{t("common.saving")}".html_safe
  end

  def boolean_to_yes_no(value)
    return if value.nil?

    value ? t("common.yes") : t("common.no")
  end

  def app_logo_tag(css_class: "App__logo")
    if Current.account&.logo&.attached?
      image_tag Current.account.logo, alt: Current.account.name, class: css_class
    else
      image_tag "logo_white.svg", alt: "LiteLink", class: css_class, style: "height: 32px;"
    end
  end

  def active_if(controller_name)
    "active" if params[:controller].include?(controller_name.to_s)
  end

  def user_icon_class_for_role(role)
    case role
    when "manager" then "fa-shield-halved"
    when "user" then "fa-user"
    else "fa-circle-user"
    end
  end

  def copyable_field(value)
    return if value.blank?

    tag.span(class: "d-inline-flex align-items-center gap-1", data: { controller: "copy", copy_text_value: value.to_s }) do
      safe_join([
        value.to_s,
        tag.button(type: "button", class: "btn btn-link btn-sm p-0 text-decoration-none", data: { action: "click->copy#copy" }, title: t("common.copy"), aria: { label: t("common.copy") }) do
          tag.i(class: "fas fa-copy", style: "font-size: 0.75em; opacity: 0.4;")
        end
      ])
    end
  end

  def boolean_options_for_select
    [
      [ t("common.boolean.yes"), true ],
      [ t("common.boolean.no"), false ]
    ]
  end
end
