require "live_resource/builder"

module LiveResource
  module Rails
    module ControllerDSL

      def self.included(base)
        base.extend(InstanceMethods)
      end

      module InstanceMethods
        def live_resource(resource_identifier, &block)
          protocol = ::Rails.configuration.live_resource.protocol
          dependency_types = ::Rails.configuration.live_resource.dependency_types

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