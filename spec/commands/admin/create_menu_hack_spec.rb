# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/menu_hack_contexts"

module Decidim::DecidimAwesome
  module Admin
    describe CreateMenuHack do
      subject { described_class.new(form, menu_name) }

      include_context "with menu hacks params"

      let(:menu_name) { :menu }

      describe "when valid" do
        it "broadcasts :ok and creates an array" do
          expect { subject.call }.to broadcast(:ok)

          items = AwesomeConfig.find_by(organization:, var: menu_name).value
          expect(items).to be_a(Array)
          expect(items.count).to eq(1)
          expect(items.first).to eq(attributes)
        end

        context "and url includes organization host" do
          let(:url) { "http://#{organization.host}/some-path" }

          it "leaves only the path" do
            expect { subject.call }.to broadcast(:ok)

            items = AwesomeConfig.find_by(organization:, var: menu_name).value
            expect(items.first["url"]).to eq("/some-path")
          end
        end

        context "and entries already exist" do
          let!(:config) { create(:awesome_config, organization:, var: menu_name, value: [{ url: "/another-menu", position: 10 }]) }

          shared_examples "has menu content" do
            it "do not removes previous entries" do
              expect { subject.call }.to broadcast(:ok)

              items = AwesomeConfig.find_by(organization:, var: menu_name).value.sort_by { |i| i["position"] }
              expect(items.count).to eq(2)
              expect(items.first).to eq(attributes)
              expect(items.second).to eq("url" => "/another-menu", "position" => 10)
            end
          end

          it_behaves_like "has menu content"

          context "and another configuration is created" do
            before do
              another_config.call
            end

            it "modifies the other config" do
              expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_editors).value).to be(true)
              expect(AwesomeConfig.find_by(organization:, var: :allow_videos_in_editors).value).to be(true)
            end

            it_behaves_like "has menu content"
          end

          context "and another configuration is updated" do
            let!(:existing_config) { create(:awesome_config, organization:, var: :allow_images_in_editors, value: false) }

            before do
              another_config.call
            end

            it "modifies the other config" do
              expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_editors).value).to be(true)
              expect(AwesomeConfig.find_by(organization:, var: :allow_videos_in_editors).value).to be(true)
            end

            it_behaves_like "has menu content"
          end
        end
      end

      describe "when same menu exists" do
        let(:previous_menu) do
          [{ "url" => "/some-path", "position" => 10 }]
        end
        let!(:config) { create(:awesome_config, organization:, var: menu_name, value: previous_menu) }
        let(:url) { "/some-path?querystring" }

        it "broadcasts :invalid and does not modify the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization:, var: menu_name).value).to eq(previous_menu)
        end
      end
    end
  end
end
