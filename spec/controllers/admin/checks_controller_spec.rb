# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe ChecksController, type: :controller do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) { create(:organization) }

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
      end

      shared_examples "valid decidim version" do
        it "is a valid Decidim version" do
          expect(controller.helpers.decidim_version_valid?).to eq(true)
        end
      end

      shared_examples "invalid decidim version" do
        it "is not a valid Decidim version" do
          expect(controller.helpers.decidim_version_valid?).to eq(false)
        end
      end

      describe "GET #index" do
        it "returns http success" do
          get :index, params: {}
          expect(response).to have_http_status(:success)
        end

        it_behaves_like "valid decidim version"

        context "when other Decidim versions" do
          before do
            allow(Decidim).to receive(:version).and_return(version)
          end

          context "and is lower than supported" do
            let(:version) { "0.20" }

            it_behaves_like "invalid decidim version"
          end

          context "and is higher than supported" do
            let(:version) { "0.23" }

            it_behaves_like "invalid decidim version"
          end

          describe "supports 0.21.1" do
            let(:version) { "0.21.1" }

            it_behaves_like "valid decidim version"
          end

          describe "supports 0.22.1" do
            let(:version) { "0.22.1" }

            it_behaves_like "valid decidim version"
          end
        end
      end
    end
  end
end
