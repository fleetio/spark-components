# frozen_string_literal: true

require "test_helper"

class ComponentsTest < ActiveSupport::TestCase
  test "SparkComponents::Error class is defined" do
    assert defined?(SparkComponents::Error)
  end

  test ".components_path returns the components root path" do
    assert_equal Rails.root.join("app", "components"), SparkComponents.components_path
  end

  test ".component_names returns an array of components" do
    assert_equal ["card", "comment", "objects/media_object"], SparkComponents.component_names
  end
end
