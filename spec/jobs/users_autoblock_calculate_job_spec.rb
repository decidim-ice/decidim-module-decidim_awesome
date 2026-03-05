# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe UsersAutoblockCalculateJob do
    subject { described_class }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, organization:) }
    let(:users_autoblock) { create(:awesome_config, organization:, var: :users_autoblocks, value: { application_type: Faker.title, type: "about_blank", weight: 10, allowlist: "", blocklist: "" }) }
    let(:users_autoblock_config) { create(:awesome_config, organization:, var: :users_autoblocks_config, value: { threshold: 10, block_justification_message: {}, perform_block: false, allow_performing_block_from_task: true, notify_blocked_users: false }) }

    it "calculates the users to auto block" do
      exporter = instance_double(Decidim::DecidimAwesome::UsersAutoblocksScoresExporter)

      allow(Decidim::DecidimAwesome::UsersAutoblocksScoresExporter)
        .to receive(:new)
        .and_return(exporter)

      allow(exporter).to receive(:export)

      described_class.perform_now(user)

      expect(Decidim::DecidimAwesome::UsersAutoblocksScoresExporter)
        .to have_received(:new)

      expect(exporter).to have_received(:export)
    end

  end
end
