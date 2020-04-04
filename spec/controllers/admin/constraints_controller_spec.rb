# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe ConstraintsController, type: :controller do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) { create(:organization) }
      let(:config) { create(:awesome_config, organization: organization, var: key) }
      let(:constraint) { create(:config_constraint, awesome_config: config) }
      let(:key) { :allow_images_in_full_editor }
      let(:id) { nil }
      let(:params) do
        {
          key: key,
          id: id,
          participatory_space_manifest: "assemblies"
        }
      end

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
      end

      describe "GET #new" do
        it "returns http success" do
          get :new, params: params
          expect(response).to have_http_status(:success)
        end
      end

      describe "PATCH #create" do
        it "redirects as success success" do
          get :create, params: params
          expect(response).to have_http_status(:success)
        end

        context "when wrong params" do
          before do
            allow(controller).to receive(:current_setting).and_return(double(var: "some-var"))
          end

          it "returns error" do
            get :create, params: params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      describe "GET #show" do
        let(:id) { constraint.id }

        it "returns http success" do
          get :show, params: params
          expect(response).to have_http_status(:success)
        end
      end

      describe "PATCH #update" do
        let(:id) { constraint.id }

        it "redirects as success success" do
          get :update, params: params
          expect(response).to have_http_status(:success)
        end

        context "when wrong params" do
          # before do
          #   allow(controller).to receive(:current_setting).and_return(double(var: "some-var"))
          # end
          let!(:prev_constraint) { create :config_constraint, awesome_config: config, settings: { participatory_space_manifest: "assemblies" } }

          it "returns error" do
            get :update, params: params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      describe "PATCH #destroy" do
        let(:id) { constraint.id }

        it "redirects as success success" do
          get :destroy, params: params
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
