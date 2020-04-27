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
      render_html_with_lazyload(image_html)
    else
      image_html
    end
  end

  def render_html_with_lazyload(html)
    content_html = Nokogiri::HTML(html).css("body")
    content_html.css("img").each { |img| to_lazy_image!(img) }

    content_html.inner_html.html_safe
  end

  private

  def to_lazy_image!(img)
    img["data-original"] = img["src"]
    img["src"] = loading_image_path unless browser.ie?
    img["class"] = img["class"].to_s.split.push(:lazy).join(" ")
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

  def loading_image_path
    @loading_image_path ||= image_path("lazyload/loading.gif")
  end
end
