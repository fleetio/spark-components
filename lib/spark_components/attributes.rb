# frozen_string_literal: true

module SparkComponents
  module Attributes
    class Hash < Hash
      def prefix; end

      def add(obj = nil)
        merge!(obj) unless obj.nil?
        self
      end

      # Output all attributes as [base-]name="value"
      def to_s
        each_with_object([]) do |(name, value), array|
          name = [prefix, name].compact.join("-")
          array << %(#{name.dasherize}="#{value}") unless value.nil?
        end.join(" ").html_safe
      end

      def collapse
        each_with_object({}) do |(name, value), obj|
          name = [prefix, name].compact.join("-")
          name = name.downcase.gsub(/[\W_]+/, "-")
          obj[name] = value unless value.nil? || value.is_a?(String) && value.empty?
        end
      end
    end

    class Data < Hash
      def prefix
        :data
      end
    end

    class Aria < Hash
      def prefix
        :aria
      end
    end

    class Classname < Array
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

        uniq!
      end

      def base
        first if @base_set
      end

      # Returns clasess which are not defined as a base class
      def modifiers
        @base_set ? self[1..size] : self
      end

      def add(*args)
        push(*args.uniq.reject { |a| a.nil? || include?(a) })
      end

      def to_s
        join(" ").html_safe
      end
    end
  end
end
