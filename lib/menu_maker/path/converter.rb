module MenuMaker
  class Path
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

          method = path.find(&has_method) || :get
          path   = path.delete_if(&has_method).first

          Path.new method, path
        end
      end

      class StringConverter
        def self.convert(path)
          Path.new(:get, path.to_s)
        end
      end

      class GenericConverter
        def self.convert(path)
          unless respond_to_protocol?(path)
            fail PathError, "Don't know how to create path with #{path}"
          end

          Path.new path.method, path.path
        end

        def self.respond_to_protocol?(path)
          path.respond_to?(:path) && path.respond_to?(:method)
        end
      end
    end
  end
end

module Kernel
  def Path(*args)
    ::MenuMaker::Path::Converter.convert(args)
  end
end
