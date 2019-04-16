module Components
  module Attributes
    class Hash < Hash
      alias add merge!

      def base; end

      # Output all attributes as [base-]name="value"
      def to_s
        each_with_object([]) do |(name, value), array|
          name = [base, name].compact.join('-')
          array << %(#{name.dasherize}="#{value}")
        end.join(" ")
      end
    end

    class Data < Hash
      def base
        :data
      end
    end

    class Aria < Hash
      def base
        :aria
      end
    end

    class Classname < Array
      alias add push

      def initialize(*args, &block)
        super(*args, &block)
        @base_set = false
      end

      # Many elements have a base class which defines core utlitiy
      # This classname may serve as a root for other element classnames
      # and should be distincly accessible
      #
      # For example:
      #   classes = Classname.new
      #   classes.base = 'nav__item'
      #   now generate a wrapper: "#{classes.base}__wrapper"
      #
      # Ensure base class is the first element in the classes array.
      #
      def base=(klass)
        return if klass.blank?

        if @base_set
          self[0] = klass
        else
          unshift klass
          @base_set = true
        end
      end

      def base
        first if @base_set
      end

      # Returns clasess which are not defined as a base class
      def modifiers
        @base_set ? self[1..size] : self
      end

      def to_s
        join(" ")
      end
    end
  end
end
