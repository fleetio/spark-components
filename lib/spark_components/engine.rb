# frozen_string_literal: true

module SparkComponents
  class Engine < ::Rails::Engine
    isolate_namespace SparkComponents

    initializer "components.asset_paths" do |app|
      app.config.assets.paths << SparkComponents.components_path if app.config.respond_to?(:assets)
    end

    initializer "components.view_helpers" do
      ActiveSupport.on_load :action_controller do
        helper SparkComponents::ComponentHelper
      end

      ActiveSupport.on_load :action_view do
        include SparkComponents::ComponentHelper
      end
    end

    initializer "components.view_paths" do
      ActiveSupport.on_load :action_controller do
        append_view_path SparkComponents.components_path
      end
    end
  end
end
