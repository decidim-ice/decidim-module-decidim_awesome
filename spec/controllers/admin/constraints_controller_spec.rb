# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/menu_hack_contexts"

module Decidim::DecidimAwesome
  module Admin
    describe ConstraintsController, type: :controller do
      include Decidim::TranslationsHelper
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
      let(:spaces) do
        [
          [process.slug, translated_attribute(process.title)]
        ].to_h
      end
      let(:components) do
        [
          [component.id, "#{component.id}: #{translated_attribute(component.name)}"]
        ].to_h
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

        it_behaves_like "forbids disabled feature" do
          let(:feature) { key }
          let(:action) { get :new, params: params }
        end

        it "has helper with participatory space manifests" do
          expect(controller.helpers.participatory_space_manifests).to include(:participatory_processes)
          expect(controller.helpers.participatory_space_manifests).to include(:assemblies)
        end

        it "has helper with component manifests" do
          expect(controller.helpers.component_manifests).to include(:proposals)
          expect(controller.helpers.component_manifests).to include(:meetings)
          expect(controller.helpers.component_manifests).to include(:awesome_map)
          expect(controller.helpers.component_manifests).to include(:awesome_iframe)
        end

        context "when participatory process exists" do
          let!(:process) { create :participatory_process, organization: organization }
          let!(:component) { create :component, participatory_space: process }

          it "has helper with existing participatory spaces" do
            expect(controller.helpers.participatory_spaces_list(:participatory_processes)).to eq(spaces)
          end

          it "has helper with existing components" do
            expect(controller.helpers.components_list(:participatory_processes, process.slug)).to eq(components)
          end
        end

        context "when process is in another organization" do
          let!(:process) { create :participatory_process }

          it "has empty helpers" do
            expect(controller.helpers.participatory_spaces_list(:participatory_processes)).to eq({})
            expect(controller.helpers.components_list(:participatory_processes, process.slug)).to eq({})
          end
        end
      end

      describe "POST #create" do
        it "returns a success response" do
          post :create, params: params
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "forbids disabled feature" do
          let(:feature) { key }
          let(:action) { post :create, params: params }
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

        it_behaves_like "forbids disabled feature" do
          let(:feature) { key }
          let(:action) { get :show, params: params }
        end
      end

      describe "PATCH #update" do
        let(:id) { constraint.id }

        it "redirects as success success" do
          patch :update, params: params
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "forbids disabled feature" do
          let(:feature) { key }
          let(:action) { patch :update, params: params }
        end

        context "when wrong params" do
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
          delete :destroy, params: params
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "forbids disabled feature" do
          let(:feature) { key }
          let(:action) { delete :destroy, params: params }
        end
      end
    end
  end
end
