# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateAwesomeAuthorizationGroup do
      subject { described_class.new(form, authorization_group) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization:) }
      let!(:authorization_group) { create(:awesome_authorization_group, organization:) }
      let(:name) { { "en" => "Updated Group Name" } }
      let(:purpose) { { "en" => "Updated Group Purpose" } }
      let(:form_params) do
        {
          name:,
          purpose:
        }
      end
      let(:form) do
        AwesomeAuthorizationGroupForm.from_params(form_params).with_context(
          current_organization: organization,
          current_user: user
        )
      end

      describe "when valid" do
        it "broadcasts :ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "updates the authorization group name" do
          subject.call
          expect(authorization_group.reload.name["en"]).to eq("Updated Group Name")
        end

        it "updates the authorization group purpose" do
          subject.call
          expect(authorization_group.reload.purpose["en"]).to eq("Updated Group Purpose")
        end

        it "does not create a new authorization group" do
          expect { subject.call }.not_to change(Decidim::DecidimAwesome::AuthorizationGroup, :count)
        end
      end

      describe "when saving fails" do
        before { allow(authorization_group).to receive(:update!).and_raise(ActiveRecord::RecordNotSaved.new("boom")) }

        it "broadcasts :invalid with the error message" do
          expect { subject.call }.to broadcast(:invalid, "boom")
        end
      end

      describe "when invalid" do
        context "when name is blank" do
          let(:name) { { "en" => "" } }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "does not update the authorization group" do
            original_name = authorization_group.name
            subject.call
            expect(authorization_group.reload.name).to eq(original_name)
          end
        end

        context "when purpose is blank" do
          let(:purpose) { { "en" => "" } }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "does not update the authorization group" do
            original_purpose = authorization_group.purpose
            subject.call
            expect(authorization_group.reload.purpose).to eq(original_purpose)
          end
        end
      end
    end
  end
end
