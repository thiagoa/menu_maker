module MenuMaker
  METHODS = %i[get post put patch delete]

  class Path
    attr_reader :method, :address

    def self.convert(path)
      method = path.class.name.to_s.split('::').last.to_s.downcase
      method = :other unless Path.respond_to? "from_#{method}"

      Path.send "from_#{method}", path
    end

    def self.from_string(address)
      StringPathConverter.convert address
    end

    def self.from_array(path)
      ArrayPathConverter.convert path
    end

    def self.from_other(path)
      GenericPathConverter.convert path
    end

    def self.from_path(path)
      GenericPathConverter.convert path
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
  end

  class ArrayPathConverter
    def self.convert(path)
      has_method = proc { |el| METHODS.include? el }

      method  = path.find(&has_method) || :get
      address = path.delete_if(&has_method).first

      Path.new method, address
    end
  end

  class StringPathConverter
    def self.convert(path)
      Path.new(:get, path.to_s)
    end
  end

  class GenericPathConverter
    def self.convert(path)
      return path if path.is_a?(Path)

      unless %i[path method].all? { |m| path.respond_to?(m) }
        fail PathError
      end

      Path.new path.method.to_sym.downcase, path.path
    end
  end

  PathError = Class.new StandardError
end

module Kernel
  def Path(*args)
    ::MenuMaker::Path.convert(args)
  end
end
