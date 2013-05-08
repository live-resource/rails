require "live_resource/builder"

module LiveResource
  module Rails
    module ControllerDSL

      def self.included(base)
        base.extend(InstanceMethods)
      end

      module InstanceMethods
        def live_resource(resource_identifier, &block)
          config = ::Rails.configuration.live_resource if ::Rails.configuration.respond_to?(:live_resource)
          raise 'You must configure config.live_resource (e.g. in application.rb)' unless config

          protocol = config[:protocol]
          raise 'You must set config.live_resource.protocol (e.g. in application.rb)' unless protocol

          dependency_types = ::Rails.configuration.live_resource[:dependency_types]
          raise 'You must set config.live_resource.dependency_types (e.g. in application.rb)' unless dependency_types

          # Set up the builder
          builder = Builder.new(resource_identifier, protocol, dependency_types, Module.new do
            # TODO: This is added for convenience, so that in the execution scope of the identifier block we'll have
            # access to path helpers. This needs to be refactored into something more elegant.
            include ::Rails.application.routes.url_helpers

            def default_url_options
              ::Rails.application.routes.default_url_options
            end
          end)

          block.call(builder)

          # Grab the result
          resource = builder.resource

          # Create a method on the controller to allow access to the Resource
          self.instance_eval do
            define_method(:"#{resource.name}_resource", Proc.new { resource })
          end

          # Create a helper method to allow views to access the resource ID
          ActionController::Base.helper do
            define_method(:"live_#{builder.resource.name}_id") do |*context|
              resource.identifier(*context)
            end
          end

          # Activate the dependencies
          resource.dependencies.each { |dependency| dependency.watch }
        end
      end

    end
  end
end