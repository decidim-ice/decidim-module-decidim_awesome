# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    describe NeedsHashcash do
      let(:organization) { create(:organization) }
      let!(:user) { create(:user, :confirmed, organization:) }
      let!(:hashcash_login) { create(:awesome_config, organization:, var: :hashcash_login, value: true) }
      let!(:hashcash_login_bits) { create(:awesome_config, organization:, var: :hashcash_login_bits, value: bits) }
      let(:bits) { 4 }
      let(:credentials) { { user: { email: user.email, password: "decidim123456789" } } }

      before do
        host! organization.host
      end

      it "rejects a login submitted without a valid hashcash mark" do
        post decidim.user_session_path, params: credentials

        # Rejected login stays anonymous: the account page bounces to the login form.
        get decidim.account_path
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include("/users/sign_in")
      end

      it "lets a user in with a valid hashcash mark" do
        stamp = ActiveHashcash::Stamp.mint(organization.host, bits:)
        post decidim.user_session_path, params: credentials.merge(hashcash: stamp.to_s)

        # Signed in: the authenticated-only account page is reachable.
        get decidim.account_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
