# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/config_examples"

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

        it_behaves_like "forbids disabled feature" do
          let(:features) { Decidim::DecidimAwesome.config.keys }
          let(:action) { get :show, params: params }
        end

        context "when params var is empty" do
          let(:params) { {} }
          let(:editors) { [:allow_images_in_full_editor, :allow_images_in_small_editor, :use_markdown_editor, :allow_images_in_markdown_editor] }
          let(:disabled) { [] }

          before do
            skip "Unskip this examples after enabling all features"

            disabled.each do |feat|
              allow(Decidim::DecidimAwesome.config).to receive(feat).and_return(:disabled)
            end
          end

          it "returns editors" do
            expect(controller.helpers.config_var).to eq(:editors)
          end

          context "when editors is disabled" do
            let(:disabled) { editors }

            it "returns proposals" do
              expect(controller.helpers.config_var).to eq(:proposals)
            end

            context "and proposals is disabled" do
              let(:disabled) do
                editors + [:allow_images_in_proposals,
                           :validate_title_min_length,
                           :validate_title_max_caps_percent,
                           :validate_title_max_marks_together,
                           :validate_title_start_with_caps,
                           :validate_body_min_length,
                           :validate_body_max_caps_percent,
                           :validate_body_max_marks_together,
                           :validate_body_start_with_caps]
              end

              it "returns surveys" do
                expect(controller.helpers.config_var).to eq(:surveys)
              end
            end
          end
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

        it_behaves_like "forbids disabled feature" do
          let(:features) { config.keys }
          let(:action) { get :show, params: params }
        end
      end

      describe "GET #users" do
        let(:params) do
          {}
        end

        it "raises unkown format" do
          expect do
            get :users, params: params
          end.to raise_exception(ActionController::UnknownFormat)
        end

        context "when format is json" do
          it "retuns a list of users" do
            get :users, params: params, format: :json
            expect(response).to have_http_status(:ok)
          end
        end
      end

      describe "POST #rename_scope_label" do
        let(:params) do
          {}
        end

        it "returns invalid" do
          post :rename_scope_label, params: params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        context "when data is present" do
          let(:params) do
            {
              text: "bar",
              key: "foo",
              scope: "scoped_something_foo",
              attribute: "scoped_something"
            }
          end

          it "returns invalid" do
            post :rename_scope_label, params: params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          context "and config exists" do
            let!(:config) { create :awesome_config, organization: organization, var: "scoped_something", value: { "foo" => "something" } }

            it "retuns ok" do
              post :rename_scope_label, params: params
              expect(response).to have_http_status(:ok)
            end

            context "and is in another organization" do
              let!(:config) { create :awesome_config, var: "scoped_something", value: { "foo" => "something" } }

              it "returns invalid" do
                post :rename_scope_label, params: params
                expect(response).to have_http_status(:unprocessable_entity)
              end
            end
          end
        end
      end
    end
  end
end
