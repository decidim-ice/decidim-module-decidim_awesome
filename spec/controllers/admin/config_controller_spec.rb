# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe ConfigController, type: :controller do
      include Decidim::TranslationsHelper
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) { create(:organization) }
      let(:config) do
        {
          allow_images_in_full_editor: false,
          allow_images_in_small_editor: false
        }
      end
      let(:params) do
        {
          var: :editors
        }
      end

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
      end

      describe "GET #show" do
        it "returns http success" do
          get :show, params: params
          expect(response).to have_http_status(:success)
        end

        context "when constraint exists" do
          let(:key) { :allow_images_in_full_editor }
          let(:settings) do
            {
              participatory_space_manifest: manifest,
              participatory_space_slug: slug,
              component_manifest: component_manifest,
              component_id: id
            }
          end
          let(:manifest) { process.manifest.name }
          let(:slug) { process.slug }
          let(:component_manifest) { component.manifest.name }
          let(:id) { component.id }
          let!(:config) { create(:awesome_config, organization: organization, var: key) }
          let!(:constraint) { create(:config_constraint, awesome_config: config, settings: settings) }
          let!(:process) { create :participatory_process, organization: organization }
          let!(:component) { create :component, participatory_space: process }

          it "sumarizes the scope for process manifest" do
            expect(controller.helpers.translate_constraint_value(constraint, "participatory_space_manifest")).to eq("Processes")
          end

          it "sumarizes the scope for process slug" do
            expect(controller.helpers.translate_constraint_value(constraint, "participatory_space_slug")).to eq(translated_attribute(process.title))
          end

          it "sumarizes the scope for component manifest" do
            expect(controller.helpers.translate_constraint_value(constraint, "component_manifest")).to eq("Dummy Component")
          end

          it "sumarizes the scope for component id" do
            expect(controller.helpers.translate_constraint_value(constraint, "component_id")).to eq("#{id}: #{translated_attribute(component.name)}")
          end

          context "when unknown keys" do
            let(:id) { "dummy" }

            it "sumarizes the value" do
              expect(controller.helpers.translate_constraint_value(constraint, "component_id")).to eq("dummy")
            end
          end
        end
      end

      describe "PATCH #update" do
        let(:params) do
          {
            var: :editors,
            config: {
              allow_images_in_full_editor: true,
              allow_images_in_small_editor: true
            }
          }
        end

        it "redirects as success success" do
          get :update, params: params
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
