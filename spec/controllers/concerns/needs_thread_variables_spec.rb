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
        it "sets Thread.current[:current_organization]" do
          controller.organization = organization
          controller.send(:set_thread_organization)

          expect(Thread.current[:current_organization]).to eq(organization)
        end

        it "does not set when current_organization is not available" do
          controller.organization = nil
          controller.send(:set_thread_organization)

          expect(Thread.current[:current_organization]).to be_nil
        end
      end

      describe "#clear_thread_organization" do
        before do
          Thread.current[:current_organization] = organization
        end

        it "clears Thread.current[:current_organization]" do
          controller.send(:clear_thread_organization)

          expect(Thread.current[:current_organization]).to be_nil
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
