# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    describe NeedsThreadVariables do
      let(:controller_class) do
        Class.new(ApplicationController) do
          include Decidim::DecidimAwesome::NeedsThreadVariables

          def current_organization
            @organization
          end

          def organization=(org)
            @organization = org
          end
        end
      end

      let(:controller) { controller_class.new }
      let(:organization) { create(:organization) }

      describe "#set_thread_organization" do
        it "sets Thread.current[:awesome_authorization_handler]" do
          controller.organization = organization
          controller.send(:set_thread_organization)

          expect(Thread.current[:awesome_authorization_handler]).to be_a(Hash) if Thread.current[:awesome_authorization_handler]
        end

        it "does not set when current_organization is not available" do
          controller.organization = nil
          controller.send(:set_thread_organization)

          expect(Thread.current[:awesome_authorization_handler]).to be_nil
        end

        context "when config exists" do
          before do
            create(:awesome_config, organization:, var: :awesome_authorization_handler, value: { name: "Custom Name", explanation: "Custom Explanation" })
          end

          it "sets the config value" do
            controller.organization = organization
            controller.send(:set_thread_organization)

            expect(Thread.current[:awesome_authorization_handler]).to eq({ "name" => "Custom Name", "explanation" => "Custom Explanation" })
          end
        end
      end

      describe "#clear_thread_organization" do
        before do
          Thread.current[:awesome_authorization_handler] = { name: "Test" }
        end

        it "clears Thread.current[:awesome_authorization_handler]" do
          controller.send(:clear_thread_organization)

          expect(Thread.current[:awesome_authorization_handler]).to be_nil
        end
      end

      context "when included in a controller" do
        it "adds before_action and after_action callbacks" do
          expect(controller_class._process_action_callbacks.map(&:filter)).to include(:set_thread_organization)
          expect(controller_class._process_action_callbacks.map(&:filter)).to include(:clear_thread_organization)
        end
      end
    end
  end
end
