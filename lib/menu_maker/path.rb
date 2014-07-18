module MenuMaker
  class Path
    METHODS = %i[get post put patch delete]

    def self.valid_method?(method)
      METHODS.include? method
    end

    attr_reader :method, :address

    def initialize(method, address)
      fail PathError unless self.class.valid_method? method

      @method  = method
      @address = address.to_s
    end

    def ==(other)
      other = Converter.convert(other)
      method == other.method && address == other.address
    end

    def to_s
      address
    end

    module Converter
      def self.convert(path)
        type = path.class.name.to_s.split('::').last.to_s

        const_get("#{type}Converter").convert path
      rescue NameError
        GenericConverter.convert path
      end

      class ArrayConverter
        def self.convert(path)
          has_method = proc { |el| Path.valid_method? el }

          method  = path.find(&has_method) || :get
          address = path.delete_if(&has_method).first

          Path.new method, address
        end
      end

      class StringConverter
        def self.convert(path)
          Path.new(:get, path.to_s)
        end
      end

      class GenericConverter
        def self.convert(path)
          return path if path.is_a?(Path)

          unless %i[path method].all? { |m| path.respond_to?(m) }
            fail PathError
          end

          Path.new path.method.to_sym.downcase, path.path
        end
      end
    end

    PathError = Class.new StandardError
  end
end

module Kernel
  def Path(*args)
    ::MenuMaker::Path::Converter.convert(args)
  end
end
