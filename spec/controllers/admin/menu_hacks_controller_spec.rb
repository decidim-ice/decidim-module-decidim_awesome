# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/config_examples"
require "decidim/decidim_awesome/test/shared_examples/menu_hack_contexts"

module Decidim::DecidimAwesome
  module Admin
    describe MenuHacksController, type: :controller do
      include Decidim::TranslationsHelper
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      include_context "with menu hacks params"

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) { create(:organization) }

      before do
        Decidim::MenuRegistry.register :menu do |menu|
          menu.add_item :native_menu,
                        "Native",
                        "/processes?locale=ca",
                        position: 1
        end
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
      end

      after do
        Decidim::MenuRegistry.find(:menu).configurations.pop
      end

      describe "GET #new" do
        it "returns http success" do
          get :new
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "forbids disabled feature" do
          let(:action) { get :new }
        end
      end

      describe "POST #create" do
        let(:action) { post :create, params: params }

        it "returns http success" do
          action
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:redirect)
        end

        it_behaves_like "forbids disabled feature"

        it "creates the new menu entry" do
          action

          items = AwesomeConfig.find_by(organization: organization, var: menu_name).value
          expect(items).to be_a(Array)
          expect(items.count).to eq(1)
          expect(items.first).to eq(attributes)
        end

        context "when invalid parameters" do
          let(:label) { { en: "" } }

          it "returns error" do
            action
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:ok)
          end

          it "do not create the new menu entry" do
            action

            expect(AwesomeConfig.find_by(organization: organization, var: menu_name)).not_to be_present
          end
        end

        context "when same url exists" do
          let(:previous_menu) do
            [{ "url" => "/some-path", "position" => 10 }]
          end
          let!(:config) { create :awesome_config, organization: organization, var: menu_name, value: previous_menu }
          let(:url) { "/some-path?querystring" }

          it "returns error" do
            action
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:ok)
          end

          it "do not create the new menu entry" do
            action

            expect(AwesomeConfig.find_by(organization: organization, var: menu_name).value.count).to eq(1)
          end
        end
      end

      describe "GET #edit" do
        let(:action) { get :edit, params: params }
        let(:previous_menu) do
          [{ "url" => url, "position" => 10 }]
        end
        let!(:config) { create :awesome_config, organization: organization, var: menu_name, value: previous_menu }
        let(:params) do
          {
            id: Digest::MD5.hexdigest(previous_menu.first["url"])
          }
        end

        it "returns http success" do
          action
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "forbids disabled feature"

        context "when editing a non existing menu" do
          let(:params) do
            {
              id: "nonsense"
            }
          end

          it "returns error" do
            expect { action }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context "when editing a native menu" do
          let(:url) { "/processes?locale=ca" }
          let(:params) do
            {
              id: Digest::MD5.hexdigest(url)
            }
          end

          it "removes the querystring" do
            action

            expect(controller.instance_variable_get(:@form).url).to eq("/processes")
            expect(response).to have_http_status(:success)
          end
        end
      end

      describe "PATCH #update" do
        let(:action) { patch :update, params: params.merge(id) }
        let(:previous_menu) do
          [{ "url" => url, "position" => 10 }]
        end
        let!(:config) { create :awesome_config, organization: organization, var: menu_name, value: previous_menu }
        let(:id) do
          {
            id: Digest::MD5.hexdigest(previous_menu.first["url"])
          }
        end

        it_behaves_like "forbids disabled feature"

        it "returns http success" do
          action
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:redirect)
        end

        it "updates the menu entry" do
          action

          items = AwesomeConfig.find_by(organization: organization, var: menu_name).value
          expect(items).to be_a(Array)
          expect(items.count).to eq(1)
          expect(items.first).to eq(attributes)
        end

        context "when updating a non existing menu" do
          let(:previous_menu) do
            [{ "url" => "/another-menu", "position" => 10 }]
          end

          it "creates a new item" do
            action
            items = AwesomeConfig.find_by(organization: organization, var: menu_name).value

            expect(items).to be_a(Array)
            expect(items.count).to eq(2)
          end
        end

        context "when invalid parameters" do
          let(:label) { { en: "" } }

          it "returns error" do
            action
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:ok)
          end

          it "do not create the new menu entry" do
            action

            expect(AwesomeConfig.find_by(organization: organization, var: menu_name).value).to eq(previous_menu)
          end
        end
      end

      describe "DELETE #destroys" do
        let(:action) { delete :destroy, params: params }
        let(:previous_menu) do
          [{ "url" => url, "position" => 10 }]
        end
        let!(:config) { create :awesome_config, organization: organization, var: menu_name, value: previous_menu }
        let(:params) do
          {
            id: Digest::MD5.hexdigest(previous_menu.first["url"])
          }
        end

        it "returns ok" do
          action
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:redirect)
        end

        it_behaves_like "forbids disabled feature"

        it "destroy the task" do
          action
          expect(AwesomeConfig.find_by(organization: organization, var: menu_name).value).to eq([])
        end

        context "when invalid parameters" do
          let(:params) do
            {
              id: "nonsense"
            }
          end

          it "returns error" do
            expect { action }.to raise_error(ActiveRecord::RecordNotFound)
            expect(AwesomeConfig.find_by(organization: organization, var: menu_name).value).to eq(previous_menu)
          end
        end
      end
    end
  end
end
