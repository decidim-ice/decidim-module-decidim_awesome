# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/menu_hack_contexts"

module Decidim::DecidimAwesome
  module Admin
    describe DestroyMenuHack do
      subject { described_class.new(item, menu_name, organization) }

      include_context "with menu hacks params"

      let(:item) { OpenStruct.new(attributes) }
      let(:previous_menu) do
        { "url" => "/another-link", "position" => 10 }
      end
      let!(:config) { create(:awesome_config, organization:, var: menu_name, value: [attributes, previous_menu]) }

      describe "when valid" do
        it "broadcasts :ok and removes the item" do
          expect { subject.call }.to broadcast(:ok)

          items = AwesomeConfig.find_by(organization:, var: menu_name).value

          expect(items).to be_a(Array)
          expect(items.count).to eq(1)
          expect(items.first).to eq(previous_menu)
        end
      end

      describe "when invalid" do
        let(:item) { OpenStruct.new("url" => "/not-in-the-menu") }

        it "broadcasts :invalid and does not modifiy the config options" do
          expect { subject.call }.to broadcast(:invalid)

          items = AwesomeConfig.find_by(organization:, var: menu_name).value
          expect(items).to be_a(Array)
          expect(items.count).to eq(2)
        end
      end
    end
  end
end
