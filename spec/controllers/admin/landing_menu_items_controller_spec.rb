# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe LandingMenuItemsController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage, settings:) }
      let(:settings) { { "menu_items" => menu_items_json } }
      let(:menu_items_json) { [{ "name" => { "en" => "About" }, "url" => "#about", "visible" => true }].to_json }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
      end

      describe "GET #new" do
        it "returns http success" do
          get :new, params: { content_block_id: content_block.id }
          expect(response).to have_http_status(:success)
        end
      end

      describe "POST #create" do
        let(:params) { { content_block_id: content_block.id, landing_menu_item: { name_en: "Contact", url: "/contact" } } }

        it "adds item to content block settings" do
          post :create, params: params
          expect(response).to have_http_status(:success)

          content_block.reload
          items = MenuItemsParser.parse_json(content_block.settings.menu_items)
          expect(items.length).to eq(2)
          expect(items.last["url"]).to eq("/contact")
        end

        context "with invalid URL" do
          let(:params) { { content_block_id: content_block.id, landing_menu_item: { name_en: "Bad", url: "javascript:alert(1)" } } }

          it "returns unprocessable entity" do
            post :create, params: params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      describe "GET #show" do
        it "returns http success" do
          get :show, params: { id: 0, content_block_id: content_block.id }
          expect(response).to have_http_status(:success)
        end

        context "with invalid index" do
          it "returns not found" do
            get :show, params: { id: 99, content_block_id: content_block.id }
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      describe "PATCH #update" do
        let(:params) { { id: 0, content_block_id: content_block.id, landing_menu_item: { name_en: "Updated", url: "#updated" } } }

        it "updates the item" do
          patch :update, params: params
          expect(response).to have_http_status(:success)

          content_block.reload
          items = MenuItemsParser.parse_json(content_block.settings.menu_items)
          expect(items.first["url"]).to eq("#updated")
        end

        context "with invalid URL" do
          let(:params) { { id: 0, content_block_id: content_block.id, landing_menu_item: { name_en: "Bad", url: "javascript:x" } } }

          it "returns unprocessable entity" do
            patch :update, params: params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "with invalid index" do
          it "returns not found" do
            patch :update, params: { id: 99, content_block_id: content_block.id, landing_menu_item: { name_en: "X", url: "#x" } }
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      describe "DELETE #destroy" do
        it "removes the item and redirects" do
          delete :destroy, params: { id: 0, content_block_id: content_block.id }
          expect(response).to have_http_status(:redirect)

          content_block.reload
          items = MenuItemsParser.parse_json(content_block.settings.menu_items)
          expect(items).to be_empty
        end

        context "with invalid index" do
          it "returns not found" do
            delete :destroy, params: { id: 99, content_block_id: content_block.id }
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      describe "PATCH #toggle_visible" do
        it "toggles visible from true to false" do
          patch :toggle_visible, params: { id: 0, content_block_id: content_block.id }
          expect(response).to have_http_status(:redirect)

          content_block.reload
          items = MenuItemsParser.parse_json(content_block.settings.menu_items)
          expect(items.first["visible"]).to be(false)
        end

        context "with invalid index" do
          it "returns not found" do
            patch :toggle_visible, params: { id: 99, content_block_id: content_block.id }
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      describe "PUT #reorder" do
        let(:menu_items_json) do
          [{ "name" => { "en" => "First" }, "url" => "#first", "visible" => true },
           { "name" => { "en" => "Second" }, "url" => "#second", "visible" => true }].to_json
        end

        it "reorders items" do
          put :reorder, params: { content_block_id: content_block.id, order_ids: %w(1 0) }, as: :json
          expect(response).to have_http_status(:ok)

          content_block.reload
          items = MenuItemsParser.parse_json(content_block.settings.menu_items)
          expect(items.first["url"]).to eq("#second")
          expect(items.last["url"]).to eq("#first")
        end

        context "with invalid params" do
          it "returns bad request" do
            put :reorder, params: { content_block_id: content_block.id, order_ids: "invalid" }, as: :json
            expect(response).to have_http_status(:bad_request)
          end
        end
      end
    end
  end
end
