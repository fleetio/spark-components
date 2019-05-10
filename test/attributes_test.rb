# frozen_string_literal: true

require "test_helper"

class AttributesTest < ActiveSupport::TestCase
  test "Hash attribute generates html attribute format on to_s" do
    attr = Components::Attributes::Hash.new
    attr.add foo: :bar

    assert_equal %(foo="bar"), attr.to_s
  end

  test "Data attribute hash generates html data- format on to_s" do
    attr = Components::Attributes::Data.new
    attr.add foo_bar: :baz

    assert_equal %(data-foo-bar="baz"), attr.to_s
  end

  test "Aria attribute hash generates html aria- format on to_s" do
    attr = Components::Attributes::Aria.new
    attr.add foo_bar: :baz

    assert_equal %(aria-foo-bar="baz"), attr.to_s
  end

  test "Classname attribute outputs space separated classnames on to_s" do
    attr = Components::Attributes::Classname.new
    attr.add :foo, :bar, :baz

    assert_equal "foo bar baz", attr.to_s
  end

  test "Classname are unique" do
    attr = Components::Attributes::Classname.new
    attr.add :foo, :bar, :baz, :bar
    attr.add :foo
    assert_equal "foo bar baz", attr.to_s

    attr.base = :bar
    assert_equal "bar foo baz", attr.to_s
  end

  test "Classname tracks base classes and modifiers separately" do
    attr = Components::Attributes::Classname.new

    attr.add :foo, :bar
    assert_nil attr.base
    assert_equal "foo bar", attr.to_s

    attr.base = :baz
    assert_equal "baz", attr.base.to_s
    assert_equal "baz foo bar", attr.to_s
    assert_equal "foo bar", attr.modifiers.to_s

    attr.base = :blast
    assert_equal "blast", attr.base.to_s
    assert_equal "blast foo bar", attr.to_s
  end
end
