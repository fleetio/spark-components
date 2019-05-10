# frozen_string_literal: true

require "spark_components/attributes"
require "spark_components/element"
require "spark_components/component"
require "spark_components/engine"

module SparkComponents
  class Error < StandardError; end

  def self.components_path
    Rails.root.join("app", "components")
  end

  def self.component_names
    return [] unless Dir.exist?(components_path)

    Dir.chdir(components_path) do
      Dir.glob("**/*_component.rb").map { |component| component.chomp("_component.rb") }.sort
    end
  end
end
