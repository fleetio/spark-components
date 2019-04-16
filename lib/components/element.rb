module Components
  class Element
    include ActiveModel::Validations

    attr_accessor :yield
    attr_reader :parents, :attr

    def self.model_name
      ActiveModel::Name.new(Components::Element)
    end

    def self.attributes
      @attributes ||= {}
    end

    def self.attribute(name, default: nil)
      attributes[name] = { default: default }

      define_method_or_raise(name) do
        get_instance_variable(name)
      end
    end

    def self.tag_attributes
      @tag_attributes ||= {
        class: Attributes::Classname.new,
        root:  Attributes::Hash.new,
        data:  Attributes::Data.new,
        aria:  Attributes::Aria.new
      }
    end

    def self.set_attr(name, *args)
      tag_attributes[name].add(add_attributes(*args))
    end

    def self.base_class(name)
      tag_attributes[:class].base = name
    end

    def self.class_attr(*args)
      tag_attributes[:class].add(*args)
    end

    def self.data_attr(*args)
      set_attr(:data, *args)
    end

    def self.aria_attr(*args)
      set_attr(:aria, *args)
    end

    def self.root_attr(*args)
      set_attr(:root, *args)
    end

    def self.add_attributes(*args)
      args.each_with_object({}) do |arg, obj|
        if arg.is_a?(Hash)
          arg.each do |attr, default|
            obj[attr.to_sym] = default
            attribute(attr.to_sym, default: default)
          end
        else
          obj[arg.to_sym] = nil
          attribute(arg.to_sym)
        end
      end
    end

    def self.elements
      @elements ||= {}
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def self.element(name, multiple: false, component: nil, &config)
      plural_name = name.to_s.pluralize.to_sym if multiple

      # Extend components by string or class; e.g., "core/header" or Core::HeaderComponent
      component = "#{component}_component".classify.constantize if component.is_a?(String)

      elements[name] = {
        multiple: plural_name || false, class: Class.new(component || Element, &config)
      }

      define_method_or_raise(name) do |attributes = nil, &block|
        return get_instance_variable(multiple ? plural_name : name) unless attributes || block

        element = self.class.elements[name][:class].new(@view, attributes, &block)
        element.parent = self
        element.yield = element.render if element.respond_to?(:render)

        if multiple
          get_instance_variable(plural_name) << element
        else
          set_instance_variable(name, element)
        end
      end

      return if !multiple || name == plural_name

      define_method_or_raise(plural_name) do
        get_instance_variable(plural_name)
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity

    def self.define_method_or_raise(method_name, &block)
      # Select instance methods but not those which are intance methods received by extending a class
      methods = (instance_methods - superclass.instance_methods(false))
      raise(Components::Error, "Method '#{method_name}' already exists.") if methods.include?(method_name.to_sym)

      define_method(method_name, &block)
    end
    private_class_method :define_method_or_raise

    def self.inherited(subclass)
      attributes.each { |name, options| subclass.attribute(name, options) }
      elements.each   { |name, options| subclass.elements[name] = options }
    end

    def initialize(view, attributes = nil, &block)
      @view = view
      @tag_attributes = self.class.tag_attributes
      initialize_attributes(attributes || {})
      initialize_elements
      @yield = block_given? ? @view.capture(self, &block) : nil
      validate!
      after_init
    end

    def after_init; end

    def parent=(obj)
      @parents = [obj.parents, obj].flatten.compact
    end

    def parent
      parents.last
    end

    # Set tag attribute values from from parameters
    def update_attr(name)
      %i[aria data root].each do |el|
        @tag_attributes[el][name] = get_instance_variable(name) if @tag_attributes[el].has_key?(name)
      end
    end

    def classname
      @tag_attributes[:class]
    end

    def base_class
      classname.base
    end

    def data
      @tag_attributes[:data]
    end

    def aria
      @tag_attributes[:aria]
    end

    def root_attributes
      @tag_attributes[:root]
    end

    def to_s
      @yield
    end

    protected

    def initialize_attributes(attributes)
      # support default data, class, and aria attribute names
      @tag_attributes[:data].add(attributes.delete(:data)) if attributes[:data]
      @tag_attributes[:aria].add(attributes.delete(:aria)) if attributes[:aria]
      @tag_attributes[:class].add(*attributes.delete(:class)) if attributes[:class]

      self.class.attributes.each do |name, options|
        set_instance_variable(name, attributes[name] || (options[:default] && options[:default].dup))
        update_attr(name)       
      end
    end

    def initialize_elements
      self.class.elements.each do |name, options|
        if (plural_name = options[:multiple])
          set_instance_variable(plural_name, [])
        else
          set_instance_variable(name, nil)
        end
      end
    end

    private

    def get_instance_variable(name)
      instance_variable_get(:"@#{name}")
    end

    def set_instance_variable(name, value)
      instance_variable_set(:"@#{name}", value)
    end
  end
end
