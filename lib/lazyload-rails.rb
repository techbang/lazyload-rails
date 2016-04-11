require "nokogiri"
require "action_view"

require "lazyload-rails/version"
require 'lazyload-rails/engine' if defined?(Rails::Engine)

ActionView::Helpers::AssetTagHelper.module_eval do
  alias :rails_image_tag :image_tag

  def image_tag(*attrs)
    options, args = extract_options_and_args(*attrs)
    image_html = rails_image_tag(*args)

    if options[:lazy]
      to_lazy_image(image_html)
    else
      image_html
    end
  end

  private

  def to_lazy_image(image_html)
    img = Nokogiri::HTML::DocumentFragment.parse(image_html).at_css("img")

    img["data-original"] = img["src"]
    img["src"] = image_path("lazyload/loading.gif")
    img["class"] = img["class"].to_s.split.push(:lazy).join(" ")

    img.to_s.html_safe
  end

  def extract_options_and_args(*attrs)
    args = attrs

    if args.size > 1
      options = attrs.last.dup
      args.last.delete(:lazy)
    else
      options = {}
    end

    [options, args]
  end

end
