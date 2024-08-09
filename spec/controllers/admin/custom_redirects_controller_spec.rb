# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/config_examples"
require "decidim/decidim_awesome/test/shared_examples/custom_redirects_contexts"

module Decidim::DecidimAwesome
  module Admin
    describe CustomRedirectsController, type: :controller do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      include_context "with custom redirects params"

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) { create(:organization) }

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
      end

      describe "GET #new" do
        it "returns http success" do
          get :new
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "forbids disabled feature with redirect" do
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

        it_behaves_like "forbids disabled feature with redirect"

        it "creates the new redirection entry" do
          action

          items = AwesomeConfig.find_by(organization: organization, var: :custom_redirects).value
          expect(items).to be_a(Hash)
          expect(items.count).to eq(1)
          expect(items.first).to eq(attributes)
        end

        context "when invalid parameters" do
          let(:origin) { "" }

          it "returns error" do
            action
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:ok)
          end

          it "do not create the new redirection entry" do
            action

            expect(AwesomeConfig.find_by(organization: organization, var: :custom_redirects)).not_to be_present
          end
        end

        context "when same url exists" do
          let(:previous_value) do
            { "/some-path" => { "destination" => "/assemblies", "active" => true } }
          end
          let!(:config) { create :awesome_config, organization: organization, var: :custom_redirects, value: previous_value }
          let(:origin) { "/some-path" }

          it "returns error" do
            action
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:ok)
          end

          it "do not create the new redirection entry" do
            action

            expect(AwesomeConfig.find_by(organization: organization, var: :custom_redirects).value.count).to eq(1)
          end
        end
      end

      describe "GET #edit" do
        let(:action) { get :edit, params: params }
        let(:previous_value) do
          { origin => { "destination" => "/assemblies", "active" => true } }
        end
        let!(:config) { create :awesome_config, organization: organization, var: :custom_redirects, value: previous_value }
        let(:params) do
          {
            id: Digest::MD5.hexdigest(origin)
          }
        end

        it "returns http success" do
          action
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "forbids disabled feature with redirect"

        context "when editing a non existing redirection" do
          let(:params) do
            {
              id: "nonsense"
            }
          end

          it "returns error" do
            expect { action }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      describe "PATCH #update" do
        let(:action) { patch :update, params: params.merge(id) }
        let(:previous_value) do
          { origin => { "destination" => "/assemblies", "active" => true } }
        end
        let!(:config) { create :awesome_config, organization: organization, var: :custom_redirects, value: previous_value }
        let(:id) do
          {
            id: Digest::MD5.hexdigest(origin)
          }
        end

        it_behaves_like "forbids disabled feature with redirect"

        it "returns http success" do
          action
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:redirect)
        end

        it "updates the redirection entry" do
          action

          items = AwesomeConfig.find_by(organization: organization, var: :custom_redirects).value
          expect(items).to be_a(Hash)
          expect(items.count).to eq(1)
          expect(items.first).to eq(attributes)
        end

        context "when updating a non existing redirection" do
          let(:previous_value) do
            { "/another-redirection" => { "destination" => "/assemblies", "active" => true } }
          end

          it "returns error" do
            expect { action }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context "when invalid parameters" do
          let(:origin) { "" }

          it "returns error" do
            action
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:ok)
          end

          it "do not create the new redirection entry" do
            action

            expect(AwesomeConfig.find_by(organization: organization, var: :custom_redirects).value).to eq(previous_value)
          end
        end
      end

      describe "DELETE #destroy" do
        let(:action) { delete :destroy, params: params }
        let(:previous_value) do
          { origin => { "destination" => "/assemblies", "active" => true } }
        end
        let!(:config) { create :awesome_config, organization: organization, var: :custom_redirects, value: previous_value }
        let(:params) do
          {
            id: Digest::MD5.hexdigest(origin)
          }
        end

        it "returns ok" do
          action
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:redirect)
        end

        it_behaves_like "forbids disabled feature with redirect"

        it "destroy the task" do
          action
          expect(AwesomeConfig.find_by(organization: organization, var: :custom_redirects).value).to eq({})
        end

        context "when invalid parameters" do
          let(:params) do
            {
              id: "nonsense"
            }
          end

          it "returns error" do
            expect { action }.to raise_error(ActiveRecord::RecordNotFound)
            expect(AwesomeConfig.find_by(organization: organization, var: :custom_redirects).value).to eq(previous_value)
          end
        end
      end
    end
  end
end
