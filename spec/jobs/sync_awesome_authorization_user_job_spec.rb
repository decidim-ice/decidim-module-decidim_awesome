# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe SyncAwesomeAuthorizationUserJob do
    describe "#perform" do
      context "when the user exists" do
        let!(:user) { create(:user, :confirmed) }

        it "delegates to authorization group user sync" do
          expect(Decidim::DecidimAwesome::AuthorizationGroup).to receive(:sync_user_authorization).with(user)

          described_class.perform_now(user.id)
        end
      end

      context "when the user does not exist" do
        it "does not attempt to sync authorizations" do
          expect(Decidim::DecidimAwesome::AuthorizationGroup).not_to receive(:sync_user_authorization)

          described_class.perform_now(-1)
        end
      end
    end
  end
end
