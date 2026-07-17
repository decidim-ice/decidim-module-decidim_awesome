# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CreateAwesomeAuthorizationMembers do
      subject { described_class.new(form) }

      let(:authorization_group) { create(:awesome_authorization_group) }
      let(:emails) { ["alice@example.org", "bob@example.org"] }
      let(:form_params) do
        {
          emails: emails.join("\n"),
          remove_previous_members: false
        }
      end
      let(:form) do
        AwesomeAuthorizationMembersForm.from_params(form_params).with_context(
          authorization_group:
        )
      end

      describe "when valid" do
        it "broadcasts :ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "creates missing members" do
          expect { subject.call }.to change(Decidim::DecidimAwesome::AuthorizationMember, :count).by(2)
        end

        context "when some members already exist" do
          before do
            create(:awesome_authorization_member, authorization_group:, email: "alice@example.org")
          end

          it "creates only new members" do
            expect { subject.call }.to change(Decidim::DecidimAwesome::AuthorizationMember, :count).by(1)
          end
        end
      end

      describe "when saving fails" do
        before { allow(authorization_group.members).to receive(:insert_all).and_raise(ActiveRecord::RecordNotSaved.new("boom")) }

        it "broadcasts :invalid with the error message" do
          expect { subject.call }.to broadcast(:invalid, "boom")
        end
      end

      describe "when invalid" do
        let(:emails) { ["not-an-email"] }

        it "broadcasts :invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end

        it "does not create members" do
          expect { subject.call }.not_to change(Decidim::DecidimAwesome::AuthorizationMember, :count)
        end

        context "when emails are nil" do
          let(:form_params) do
            {
              emails: nil,
              remove_previous_members: false
            }
          end

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "does not create members" do
            expect { subject.call }.not_to change(Decidim::DecidimAwesome::AuthorizationMember, :count)
          end
        end
      end
    end
  end
end
