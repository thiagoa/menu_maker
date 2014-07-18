module MenuMaker
  class Path
    METHODS = %i[get post put patch delete]

    attr_reader :method, :address

    def self.convert(path)
      method = path.class.name.to_s.split('::').last.to_s.downcase
      method = :other unless Path.respond_to? "from_#{method}"

      Path.send "from_#{method}", path
    end

    def self.from_string(address)
      Path.new(:get, address.to_s)
    end

    def self.from_array(path)
      has_method = proc { |el| METHODS.include? el }

      method  = path.find(&has_method) || :get
      address = path.delete_if(&has_method).first

      new method, address
    end

    def self.from_other(object)
      fail PathError unless %i[path method].all? { |m| object.respond_to?(m) }

      new(object.method.to_sym.downcase, object.path)
    end

    def self.from_path(path)
      path if path.is_a?(Path) or fail PathError
    end

    def initialize(method, address)
      fail PathError unless METHODS.include? method

      @method  = method
      @address = address.to_s
    end

    def ==(other)
      other = self.class.convert(other)
      method == other.method && address == other.address
    end

    def to_s
      address
    end

    PathError = Class.new StandardError
  end
end
