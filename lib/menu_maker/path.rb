module MenuMaker
  METHODS = %i[get post put patch delete]

  class Path
    attr_reader :method, :address

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

    module Converter
      def self.convert(path)
        type      = path.class.name.to_s.split('::').last.to_s
        converter = "#{type}PathConverter"

        const_get(converter).convert path
      rescue NameError
        GenericPathConverter.convert path
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
    end
  end

  def Path.convert(path)
    Path::Converter.convert path
  end

  PathError = Class.new StandardError
end

module Kernel
  def Path(*args)
    ::MenuMaker::Path.convert(args)
  end
end
