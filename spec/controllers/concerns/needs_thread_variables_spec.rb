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

      describe "#set_thread_variables" do
        it "sets Thread.current[:awesome_authorization_handler] to nil when no config exists" do
          controller.organization = organization
          controller.send(:set_thread_variables)

          expect(Thread.current[:awesome_authorization_handler]).to be_nil
        end

        it "does not set when current_organization is not available" do
          controller.organization = nil
          controller.send(:set_thread_variables)

          expect(Thread.current[:awesome_authorization_handler]).to be_nil
        end

        context "when config exists" do
          before do
            create(:awesome_config, organization:, var: :awesome_authorization_handler, value: { name: "Custom Name", explanation: "Custom Explanation" })
          end

          it "sets the config value" do
            controller.organization = organization
            controller.send(:set_thread_variables)

            expect(Thread.current[:awesome_authorization_handler]).to eq({ "name" => "Custom Name", "explanation" => "Custom Explanation" })
          end
        end
      end

      describe "#clear_thread_variables" do
        before do
          Thread.current[:awesome_authorization_handler] = { name: "Test" }
        end

        it "clears Thread.current[:awesome_authorization_handler]" do
          controller.send(:clear_thread_variables)

          expect(Thread.current[:awesome_authorization_handler]).to be_nil
        end
      end

      context "when included in a controller" do
        it "adds around_action callback" do
          expect(controller_class._process_action_callbacks.map(&:filter)).to include(:with_thread_variables)
        end

        it "clears thread variable even when action raises" do
          controller.organization = organization
          Thread.current[:awesome_authorization_handler] = { name: "Test" }

          expect { controller.send(:with_thread_variables) { raise StandardError, "test error" } }.to raise_error(StandardError)

          expect(Thread.current[:awesome_authorization_handler]).to be_nil
        end
      end
    end
  end
end
