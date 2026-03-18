# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe LandingMenuItemsController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      subject { controller.landing_menu_item_presets_options(block_scope: :homepage) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:first_preset) { subject[0] }
      let(:second_preset) { subject[1] }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
      end

      describe "#landing_menu_item_presets_options" do
        it "returns empty presets when no content blocks exist" do
          expect(first_preset).to be_an(Array)
          expect(second_preset).to be_an(Array)
          expect(first_preset[0]).to eq(I18n.t("decidim.decidim_awesome.admin.landing_menu_items.form.preset_global_menu"))
          expect(second_preset[0]).to eq(I18n.t("decidim.decidim_awesome.admin.landing_menu_items.form.preset_content_blocks"))
          expect(first_preset[1][0][0]).to eq("Home")
          expect(first_preset[1][0][1]).to eq("/")
          expect(first_preset[1][0][2]).to have_key("data-label-en")
          expect(second_preset[1]).to eq([])
        end

        context "when content blocks exist" do
          let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage) }
          let!(:sibling_block) { create(:content_block, organization:, manifest_name: :html, scope_name: :homepage) }

          it "includes anchors for sibling content blocks" do
            anchors = second_preset[1]
            expect(anchors.count).to eq(1)
            expect(anchors.first[0]).to eq(I18n.t(sibling_block.manifest.public_name_key, default: sibling_block.manifest_name.humanize))
            expect(anchors.first[1]).to eq("#html-block-html")
          end
        end
      end
    end
  end
end
