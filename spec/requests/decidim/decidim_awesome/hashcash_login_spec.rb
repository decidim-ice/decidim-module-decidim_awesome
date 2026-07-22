# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    describe NeedsHashcash do
      let(:organization) { create(:organization) }
      let!(:user) { create(:user, :confirmed, organization:) }
      let!(:hashcash_login) { create(:awesome_config, organization:, var: :hashcash_login, value: true) }
      let!(:hashcash_login_bits) { create(:awesome_config, organization:, var: :hashcash_login_bits, value: 20) }
      let(:credentials) { { user: { email: user.email, password: "decidim123456789" } } }

      before do
        host! organization.host
      end

      it "rejects a login submitted without a valid hashcash mark" do
        expect do
          post decidim.user_session_path, params: credentials
        end.to raise_error(ActionController::InvalidAuthenticityToken)
      end
    end
  end
end
