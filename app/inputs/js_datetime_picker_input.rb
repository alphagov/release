class JsDatetimePickerInput < FormtasticBootstrap::Inputs::StringInput
  def input_content(&block)
    content = [
      add_on_content(options[:prepend]),
      options[:prepend_content],
      yield,
      add_on_content(options[:append]),
      options[:append_content]
    ].compact.join("\n").html_safe

    if prepended_or_appended?(options)
      wrapper_options = options[:wrapper_options] || {}
      classes = add_on_wrapper_classes(options)
      extra_classes = wrapper_options.delete(:class)
      classes << extra_classes if extra_classes
      wrapper_options[:class] = classes.join(" ")
      template.content_tag(:div, content, wrapper_options)
    else
      content
    end
  end
end
