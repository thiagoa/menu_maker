module MenuMaker
  class Path
    Methods = %i[get post put patch delete]

    def self.valid_method?(method)
      Methods.include? method
    end

    attr_reader :method, :path

    def initialize(method, path)
      method = method.to_sym.downcase

      unless self.class.valid_method? method
        fail PathError, "Method must be one of: #{Methods.join(', ')}"
      end

      @method = method
      @path   = path.to_s
    end

    def ==(other)
      other = Converter.convert(other)
      method == other.method && path == other.path
    end

    def to_s
      path
    end

    PathError = Class.new StandardError
  end
end
