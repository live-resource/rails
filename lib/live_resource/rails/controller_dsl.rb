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

          builder = Builder.new(resource_identifier, protocol, dependency_types)
          block.call(builder)

          self.instance_eval do
            define_method(builder.method_name, builder.resource_method)
          end

          resource = builder.resource

          ActionController::Base.helper do
            define_method(:"live_#{builder.resource.name}_id") do |*context|
              resource.identifier(*context)
            end
          end
        end
      end

    end
  end
end