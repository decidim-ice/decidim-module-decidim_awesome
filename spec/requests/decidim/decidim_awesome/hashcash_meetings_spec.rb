# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    describe NeedsHashcash do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:participatory_process) { create(:participatory_process, :published, organization:) }
      let(:component) { create(:meeting_component, :published, participatory_space: participatory_process) }
      let(:meeting) { create(:meeting, :published, :with_registrations_enabled, component:) }
      let!(:hashcash_signup) { create(:awesome_config, organization:, var: :hashcash_signup, value: true) }
      let!(:hashcash_signup_bits) { create(:awesome_config, organization:, var: :hashcash_signup_bits, value: 4) }

      before do
        host! organization.host
        login_as user, scope: :user
      end

      # Decidim::Meetings::RegistrationsController is also named "registrations"
      it "does not require a hashcash mark to join a meeting" do
        expect do
          post Decidim::EngineRouter.main_proxy(component).meeting_registration_path(meeting)
        end.to change(Decidim::Meetings::Registration, :count).by(1)
      end
    end
  end
end
