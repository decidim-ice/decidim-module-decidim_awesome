# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CreateAwesomeAuthorizationGroup do
      subject { described_class.new(form) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization:) }
      let(:name) { { "en" => "My Group Name" } }
      let(:purpose) { { "en" => "My Group Purpose" } }
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

        it "creates an authorization group" do
          expect { subject.call }.to change(Decidim::DecidimAwesome::AuthorizationGroup, :count).by(1)
        end

        it "sets the correct attributes on the group" do
          subject.call
          group = organization.awesome_authorization_groups.last
          expect(group.name["en"]).to eq("My Group Name")
          expect(group.purpose["en"]).to eq("My Group Purpose")
        end

        it "associates the group with the organization" do
          subject.call
          expect(organization.awesome_authorization_groups.last.organization).to eq(organization)
        end
      end

      describe "when saving fails" do
        before do
          groups = organization.awesome_authorization_groups
          allow(organization).to receive(:awesome_authorization_groups).and_return(groups)
          allow(groups).to receive(:create!).and_raise(ActiveRecord::RecordNotSaved.new("boom"))
        end

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

          it "does not create an authorization group" do
            expect { subject.call }.not_to change(Decidim::DecidimAwesome::AuthorizationGroup, :count)
          end
        end

        context "when purpose is blank" do
          let(:purpose) { { "en" => "" } }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "does not create an authorization group" do
            expect { subject.call }.not_to change(Decidim::DecidimAwesome::AuthorizationGroup, :count)
          end
        end
      end
    end
  end
end
