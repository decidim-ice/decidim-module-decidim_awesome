# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe PrivateDataController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:organization) { create(:organization) }
      let!(:component) { create(:proposal_component, organization:) }
      let!(:proposal) { create(:proposal, component:) }
      let!(:extra_fields) { create(:awesome_proposal_extra_fields, private_body: "private", proposal:) }
      let(:time_ago) { 4.months.ago }

      before do
        # rubocop:disable Rails/SkipsModelValidations
        extra_fields.update_column(:private_body_updated_at, time_ago)
        # rubocop:enable Rails/SkipsModelValidations
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
      end

      describe "GET #index" do
        it "returns http success" do
          get(:index)
          expect(response).to have_http_status(:success)
        end

        context "when format is json" do
          it "returns json" do
            get(:index)
            expect(response).to have_http_status(:success)
          end
        end
      end

      describe "DELETE #destroy" do
        let(:params) do
          { id: component.id }
        end

        it "returns http success" do
          perform_enqueued_jobs do
            delete(:destroy, params:)
          end
          expect(response).to have_http_status(:redirect)
          expect(flash[:notice]).to include("is set to be destroyed")
          expect(Decidim::DecidimAwesome::ProposalExtraField.find(extra_fields.id).private_body).to be_nil
        end

        context "when private data is not present" do
          let(:time_ago) { 2.months.ago }

          it "returns http success" do
            perform_enqueued_jobs do
              delete(:destroy, params:)
            end
            expect(response).to have_http_status(:redirect)
            expect(Decidim::DecidimAwesome::ProposalExtraField.find(extra_fields.id).private_body).to eq("private")
          end
        end

        context "when no permissions" do
          let(:user) { create(:user, :confirmed, organization:) }

          it "returns http success" do
            perform_enqueued_jobs do
              delete(:destroy, params:)
            end
            expect(response).to have_http_status(:redirect)
            expect(Decidim::DecidimAwesome::ProposalExtraField.find(extra_fields.id).private_body).to eq("private")
          end
        end
      end
    end
  end
end
