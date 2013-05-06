require 'live_resource/rails'
require "live_resource/rails/controller_dsl"

require 'action_controller'

ActionController::Base.class_eval do
  include LiveResource::Rails::ControllerDSL
end