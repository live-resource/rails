require "spec_helper"
require "action_controller/base"
require 'live_resource/protocol'
require 'live_resource/dependency'
require 'rails'

include LiveResource::Rails

describe LiveResource::Rails::ControllerDSL do

  let(:controller_class) do
    class DummyController < ActionController::Base
      include ControllerDSL
    end
  end

  describe "#live_resource" do

    subject do
      b = block # let'ed methods are lost in the scope of the proc
      controller_class.class_eval(&Proc.new { live_resource(:some_thing, &b) })
    end

    let(:controller) { DummyController.new }
    let(:builder) do
      double(LiveResource::Builder,
             method_name:     method_name,
             resource_method: resource_method,
             resource:        resource)
    end
    let(:block) { Proc.new {} }
    let(:method_name) { :some_method }
    let(:resource_method) { Proc.new {} }
    let(:resource) { double(LiveResource::Resource, name: resource_name) }
    let(:resource_name) { :some_method }

    before do
      LiveResource::Builder.stub(:new).and_return(builder)
      ActionController::Base.stub(:helper)
    end

    context 'when live resource is not configured' do
      before do
        Rails.stub(:configuration)
      end

      it 'should raise an error' do
        expect(-> { subject }).to raise_error('You must configure config.live_resource (e.g. in application.rb)')
      end
    end

    context 'when live resource is configured' do
      let(:protocol) {}
      let(:dependency_types) {}

      let(:live_resource_configuration) do
        {
            protocol:         protocol,
            dependency_types: dependency_types
        }
      end

      before do
        Rails.stub_chain(:configuration, :live_resource).and_return(live_resource_configuration)
      end

      context 'when the protocol is not configured' do
        it 'should raise an error' do
          expect(-> { subject }).to raise_error('You must set config.live_resource.protocol (e.g. in application.rb)')
        end
      end

      context 'when the protocol is configured' do
        let(:protocol) { double(LiveResource::Protocol) }

        context 'but the supported dependency types are not set' do
          it 'should raise an error' do
            expected_error = 'You must set config.live_resource.dependency_types (e.g. in application.rb)'
            expect(-> { subject }).to raise_error(expected_error)
          end
        end

        context 'and the supported dependency types are set' do
          let(:dependency_types) { [double(LiveResource::Dependency)] }

          it "should instantiate a new builder" do
            LiveResource::Builder.should_receive(:new).with(:some_thing, protocol, dependency_types)
            subject
          end

          it "should call the block with the builder" do
            block.should_receive(:call).with(builder)
            subject
          end

          it "should define a new method on the controller" do
            controller_class.should_receive(:define_method).with(method_name, resource_method)
            subject
          end

          it "should define a helper method for the identifier" do
            ActionController::Base.should_receive(:helper)
            subject
          end
        end
      end
    end

  end
end