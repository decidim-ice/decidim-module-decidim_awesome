# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/config_examples"

module Decidim::DecidimAwesome
  module Admin
    describe ConstraintsController do
      include Decidim::TranslationsHelper
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:organization) { create(:organization) }
      let(:config) { create(:awesome_config, organization:, var: key) }
      let(:constraint) { create(:config_constraint, awesome_config: config) }
      let(:key) { :allow_images_in_editors }
      let(:id) { nil }
      let(:params) do
        {
          key:,
          id:,
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

        allow(Decidim::DecidimAwesome.config).to receive(key).and_return(true)
      end

      describe "GET #new" do
        it "returns http success" do
          get(:new, params:)
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "forbids disabled feature without redirect" do
          let(:feature) { key }
          let(:action) { get :new, params: }
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
          let!(:process) { create(:participatory_process, organization:) }
          let!(:component) { create(:component, participatory_space: process) }

          it "has helper with existing participatory spaces" do
            expect(controller.helpers.participatory_spaces_list(:participatory_processes)).to eq(spaces)
          end

          it "has helper with existing components" do
            expect(controller.helpers.components_list(:participatory_processes, process.slug)).to eq(components)
          end
        end

        context "when process is in another organization" do
          let!(:process) { create(:participatory_process) }

          it "has empty helpers" do
            expect(controller.helpers.participatory_spaces_list(:participatory_processes)).to eq({})
            expect(controller.helpers.components_list(:participatory_processes, process.slug)).to eq({})
          end
        end

        context "when key is scoped_style" do
          let(:key) { :scoped_style_test }

          before do
            allow(Decidim::DecidimAwesome.config).to receive(:scoped_styles).and_return(true)
          end

          it "returns http success" do
            get(:new, params:)
            expect(response).to have_http_status(:success)
          end
        end
      end

      describe "POST #create" do
        it "returns a success response" do
          post(:create, params:)
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "forbids disabled feature without redirect" do
          let(:feature) { key }
          let(:action) { post :create, params: }
        end

        context "when wrong params" do
          before do
            allow(controller).to receive(:current_setting).and_return(double(var: "some-var"))
          end

          it "returns error" do
            get(:create, params:)
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      describe "GET #show" do
        let(:id) { constraint.id }

        it "returns http success" do
          get(:show, params:)
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "forbids disabled feature without redirect" do
          let(:feature) { key }
          let(:action) { get :show, params: }
        end
      end

      describe "PATCH #update" do
        let(:id) { constraint.id }

        it "redirects as success success" do
          patch(:update, params:)
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "forbids disabled feature without redirect" do
          let(:feature) { key }
          let(:action) { patch :update, params: }
        end

        context "when wrong params" do
          let!(:prev_constraint) { create(:config_constraint, awesome_config: config, settings: { participatory_space_manifest: "assemblies" }) }

          it "returns error" do
            get(:update, params:)
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      describe "PATCH #destroy" do
        let(:id) { constraint.id }

        it "redirects as success success" do
          delete(:destroy, params:)
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "forbids disabled feature without redirect" do
          let(:feature) { key }
          let(:action) { delete :destroy, params: }
        end
      end
    end
  end
end
