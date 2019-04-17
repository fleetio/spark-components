require "test_helper"

class ComponentTest < ActiveSupport::TestCase
  test "initialize with nothing" do
    component_class = Class.new(Components::Component)
    component = component_class.new(view_class.new)
    assert_nil component.to_s
  end

  test "initialize with block" do
    component_class = Class.new(Components::Component)
    component = component_class.new(view_class.new) { "foo" }
    assert_equal "foo", component.to_s
  end

  test "initialize by overwriting existing method with attribute" do
    e = assert_raises(Components::Error) do
      Class.new(Components::Component) do
        attribute :to_s
      end
    end
    assert_equal "Method 'to_s' already exists.", e.message
  end

  test "initialize attribute with no value" do
    component_class = Class.new(Components::Component) do
      attribute :foo
    end
    component = component_class.new(view_class.new)
    assert_nil component.foo
  end

  test "initialize attribute with value" do
    component_class = Class.new(Components::Component) do
      attribute :foo
    end
    component = component_class.new(view_class.new, foo: "foo")
    assert_equal "foo", component.foo
  end

  test "initialize attribute with default value" do
    component_class = Class.new(Components::Component) do
      attribute :foo, default: "foo"
    end
    component = component_class.new(view_class.new)
    assert_equal "foo", component.foo
  end

  test "initialize by overwriting existing method with element" do
    e = assert_raises(Components::Error) do
      Class.new(Components::Component) do
        def foo
          "foo"
        end

        element :foo
      end
    end
    assert_equal "Method 'foo' already exists.", e.message
  end

  test "initialize element with block" do
    component_class = Class.new(Components::Component) do
      element :foo
    end
    component = component_class.new(view_class.new)
    component.foo { "foo" }
    assert_equal "foo", component.foo.to_s
  end

  test "initialize element with attribute with value" do
    component_class = Class.new(Components::Component) do
      element :foo do
        attribute :bar
      end
    end
    component = component_class.new(view_class.new)
    component.foo bar: "baz"
    assert_equal "baz", component.foo.bar
  end

  test "initialize element with block with nested element with block" do
    component_class = Class.new(Components::Component) do
      element :foo do
        element :bar
      end
    end
    component = component_class.new(view_class.new)
    component.foo do |cc|
      cc.bar do
        "bar"
      end
      "foo"
    end
    assert_equal "foo", component.foo.to_s
    assert_equal "bar", component.foo.bar.to_s
  end

  test "initialize element with multiple true" do
    component_class = Class.new(Components::Component) do
      element :foo, multiple: true
    end
    component = component_class.new(view_class.new)
    component.foo { "foo" }
    component.foo { "bar" }
    assert_equal 2, component.foos.length
    assert_equal "foo", component.foos[0].to_s
    assert_equal "bar", component.foos[1].to_s
  end

  test "initialize element with multiple true when singular and plural name are the same" do
    component_class = Class.new(Components::Component) do
      element :foos, multiple: true
    end
    component = component_class.new(view_class.new)
    component.foos { "foo" }
    component.foos { "bar" }
    assert_equal 2, component.foos.length
    assert_equal "foo", component.foos[0].to_s
    assert_equal "bar", component.foos[1].to_s
  end

  test "get element when not set" do
    component_class = Class.new(Components::Component) do
      element :foo
    end
    component = component_class.new(view_class.new)
    assert_nil component.foo
  end

  test "get element with multiple true when not set" do
    component_class = Class.new(Components::Component) do
      element :foo, multiple: true
    end
    component = component_class.new(view_class.new)
    assert_equal [], component.foos
  end

  test "initialize with given attribute and successfull validation" do
    component_class = Class.new(Components::Component) do
      attribute :foo
      validates :foo, presence: true
    end
    assert_nothing_raised { component_class.new(view_class.new, foo: "bar") }
  end

  test "initialize without attribute and failing validation" do
    component_class = Class.new(Components::Component) do
      attribute :foo
      validates :foo, presence: true
    end
    e = assert_raises(ActiveModel::ValidationError) { component_class.new(view_class.new) }
    assert_equal "Validation failed: Foo can't be blank", e.message
  end

  test "initialize with default value and successfull validation" do
    component_class = Class.new(Components::Component) do
      attribute :foo, default: "bar"
      validates :foo, presence: true
    end
    assert_nothing_raised { component_class.new(view_class.new) }
  end

  test "initialize element and successfull element validation" do
    component_class = Class.new(Components::Component) do
      element :foo
      validates :foo, presence: true
    end
    assert_nothing_raised do
      component_class.new(view_class.new, {}) do |c|
        c.foo { "lalala" }
      end
    end
  end

  test "initialize element and failing element validation" do
    component_class = Class.new(Components::Component) do
      element :foo
      validates :foo, presence: true
    end
    e = assert_raises(ActiveModel::ValidationError) do
      component_class.new(view_class.new, {})
    end
    assert_equal "Validation failed: Foo can't be blank", e.message
  end

  test "initialize element and successfull element attribute validation" do
    component_class = Class.new(Components::Component) do
      element :foo do
        attribute :bar
        validates :bar, presence: true
      end
    end
    assert_nothing_raised do
      component_class.new(view_class.new, {}) do |c|
        c.foo(bar: "lalal") { "something" }
      end
    end
  end

  test "initialize element and failing element attribute validation" do
    component_class = Class.new(Components::Component) do
      element :foo do
        attribute :bar
        validates :bar, presence: true
      end
    end
    e = assert_raises(ActiveModel::ValidationError) do
      component_class.new(view_class.new, {}) do |c|
        c.foo { "something" }
      end
    end
    assert_equal "Validation failed: Bar can't be blank", e.message
  end

  test "element can render a component" do
    base_component_class = Class.new(Components::Component) do
      attribute :tag, default: :h1

      def render
        "<#{tag}>#{self}</#{tag}>"
      end
    end

    component_class = Class.new(Components::Component) do
      element :header, component: base_component_class
    end

    component = component_class.new(view_class.new)

    component.header(tag: :h2) { "test" }
    assert_equal "<h2>test</h2>", component.header.to_s
  end

  test "elements should be able to interact with their parent component" do
    list_component = Class.new(Components::Component) do
      element :item, multiple: true

      element :group do
        element :item, multiple: true

        def render
          parent.items << "(#{items.join(', ')})"
        end
      end
    end

    list = list_component.new(view_class.new)
    list.item { "1" }
    list.group do |group|
      group.item { "1.1" }
      group.item { "1.2" }
    end
    list.item { "2" }

    assert_equal "1, (1.1, 1.2), 2", list.items.join(", ")
  end

  test "class_attr and base_class modify the default classname attribute" do
    component_class = Class.new(Components::Component) do
      base_class :one
      add_class :two, :three
    end
    component = component_class.new(view_class.new, class: "four five")

    assert_equal "one two three four five", component.classnames.to_s
    assert_equal :one, component.classnames.base
    assert_equal 'one-two', component.child_class('two')
  end

  test "tag_attr defines component attributes which can modify root tag attributes" do
    component_class = Class.new(Components::Component) do
      tag_attr :foo, :bar, a: "b"
    end
    component = component_class.new(view_class.new, foo: "baz")
    assert_equal %(foo="baz" a="b"), component.tag_attr.to_s

    component.tag_attr.add bar: true
    assert_equal %(foo="baz" bar="true" a="b"), component.tag_attr.to_s
  end

  test "data_attr defines component attributes which can modify data- attributes" do
    component_class = Class.new(Components::Component) do
      data_attr :foo, :bar, a: "b"
    end
    component = component_class.new(view_class.new, foo: "baz")
    assert_equal %(data-foo="baz" data-a="b"), component.data_attr.to_s

    component.data_attr bar: true
    assert_equal %(data-foo="baz" data-bar="true" data-a="b"), component.data_attr.to_s
  end

  test "aria_attr defines component attributes which can modify aria- attributes" do
    component_class = Class.new(Components::Component) do
      aria_attr :foo, :bar, a: "b"
    end
    component = component_class.new(view_class.new, foo: "baz")
    assert_equal %(aria-foo="baz" aria-a="b"), component.aria_attr.to_s

    component.aria_attr bar: true
    assert_equal %(aria-foo="baz" aria-bar="true" aria-a="b"), component.aria_attr.to_s
  end

  test "data, class, and aria component options sets default attributes" do
    component_class = Class.new(Components::Component)
    component = component_class.new(view_class.new, data: { foo: "bar" }, class: "one two", aria: { three: "four" })

    assert_equal %(data-foo="bar"), component.data_attr.to_s
    assert_equal "one two", component.classnames.to_s
    assert_equal %(aria-three="four"), component.aria_attr.to_s
  end

  test "all_attr outputs data, class, aria, and tag attributes" do
    component_class = Class.new(Components::Component) do
      tag_attr role: "nav"
    end
    component = component_class.new(view_class.new, data: { foo: "bar" }, class: "one two", aria: { three: "four" })

    assert_equal %(class="one two" data-foo="bar" aria-three="four" role="nav"), component.all_attr
    assert_equal %(data-foo="bar" aria-three="four" role="nav"), component.all_attr(add_class: false)
  end

  test "tag attributes are isolated across components" do
    component_class = Class.new(Components::Component) do
      add_attributes type: "default"

      def after_init
        add_class "type-#{@type}"
        data_attr type: type
        aria_attr type: type
        tag_attr type: type
      end
    end

    component = component_class.new(view_class.new)
    component_2 = component_class.new(view_class.new, type: "alert")

    assert_equal "type-default", component.classnames.to_s
    assert_equal "type-alert", component_2.classnames.to_s

    assert_equal %(data-type="default"), component.data_attr.to_s
    assert_equal %(data-type="alert"), component_2.data_attr.to_s

    assert_equal %(aria-type="default"), component.aria_attr.to_s
    assert_equal %(aria-type="alert"), component_2.aria_attr.to_s

    assert_equal %(type="default"), component.tag_attr.to_s
    assert_equal %(type="alert"), component_2.tag_attr.to_s
  end

  private

  def view_class
    Class.new do
      def capture(element)
        yield(element)
      end
    end
  end
end
