# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/menu_hack_contexts"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateMenuHack do
      subject { described_class.new(form, menu_name) }

      include_context "with menu hacks params"

      let(:previous_menu) do
        [{ "url" => url, "position" => 10 }]
      end
      let!(:config) { create(:awesome_config, organization:, var: menu_name, value: previous_menu) }
      let(:menu_name) { :menu }

      describe "when valid" do
        it "broadcasts :ok and modifies the config options" do
          expect { subject.call }.to broadcast(:ok)

          items = AwesomeConfig.find_by(organization:, var: menu_name).value
          expect(items).to be_a(Array)
          expect(items.count).to eq(1)
          expect(items.first).to eq(attributes)
          expect(items.first["url"]).to eq(url)
        end
      end

      describe "when invalid" do
        before do
          allow(form).to receive(:valid?).and_return(false)
        end

        it "broadcasts :invalid and does not modify the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization:, var: menu_name).value).to eq(previous_menu)
        end
      end

      context "when other config are created" do
        let!(:config) { create(:awesome_config, organization:, var: menu_name, value: attributes) }

        it "modifies the other config" do
          expect { another_config.call }.to broadcast(:ok)
          expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_editors).value).to be(true)
          expect(AwesomeConfig.find_by(organization:, var: :allow_videos_in_editors).value).to be(true)
        end

        it "do not modify current config" do
          expect(AwesomeConfig.find_by(organization:, var: menu_name).value).to eq(attributes)
          expect { another_config.call }.to broadcast(:ok)
          expect(AwesomeConfig.find_by(organization:, var: menu_name).value).to eq(attributes)
        end
      end

      context "when updating an non existing menu" do
        let(:previous_menu) do
          [{ "url" => "/another-menu", "position" => 10 }]
        end

        it "adds a new menu entry" do
          expect { subject.call }.to broadcast(:ok)

          items = AwesomeConfig.find_by(organization:, var: menu_name).value.sort_by { |i| i["position"] }
          expect(items).to be_a(Array)
          expect(items.count).to eq(2)
          expect(items.first).to eq(attributes)
          expect(items.first["url"]).to eq(url)
          expect(items.second).to eq(previous_menu.first)
        end
      end

      context "when updating an native menu" do
        let(:previous_menu) do
          [{ "url" => "/another-menu", "position" => 10 }]
        end
        let(:url) { "/another-menu?querystring" }
        let(:params) do
          {
            raw_label: label,
            url:,
            position:,
            target:,
            visibility:,
            native?: true
          }
        end

        it "adds a new menu entry" do
          expect { subject.call }.to broadcast(:ok)

          items = AwesomeConfig.find_by(organization:, var: menu_name).value.sort_by { |i| i["position"] }
          expect(items).to be_a(Array)
          expect(items.count).to eq(2)
          expect(items.first["url"]).to eq(url)
          expect(items.second["url"]).to eq("/another-menu")
        end
      end
    end
  end
end
