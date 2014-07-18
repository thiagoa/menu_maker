module MenuMaker
  class MenuRenderer
    attr_accessor :menu
    attr_reader   :current_path, :helpers

    alias_method :h, :helpers

    def self.render(&block)
      define_method :render do
        build_html do
          instance_eval(&block)
        end
      end
    end

    def initialize(helpers, path = nil)
      @helpers      = helpers
      @current_path = find_current_path(path)
    end

    def build_menu
      build_html do
        menu.items.inject('') do |out, item|
          out + yield(item, [])
        end
      end
    end

    def build_html
      output = yield ''

      if output.respond_to? :html_safe
        output.html_safe
      else
        output
      end
    end

    def call(menu)
      self.menu = menu
      render
    end

    private

    def find_current_path(current_path)
      Path.convert(current_path || request || '')
    end

    def helpers_has_request?
      helpers.respond_to?(:request)
    end

    def request
      helpers.request if helpers_has_request?
    end
  end
end
