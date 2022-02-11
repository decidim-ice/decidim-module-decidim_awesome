# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe MigrateLegacyImagesJob do
    subject { described_class }

    let!(:organization) { create :organization }
    let!(:another_organization) { create :organization }
    let!(:user) { create :user, organization: organization }
    let!(:new_image) { create :editor_image, organization: organization }
    let!(:old_image) { create :editor_image, organization: organization, file: nil, image: "city.jpeg" }
    let(:path) { "/uploads/decidim/decidim_awesome/editor_image/image/#{old_image.id}" }
    let(:text) do
      { "en" => body }
    end
    let(:body) { "<img src=\"#{path}/city.jpeg\">" }
    let(:logger) { Logger.new($stdout) }

    before do
      FileUtils.mkdir_p "#{__dir__}/../decidim_dummy_app/public/#{path}"
      FileUtils.cp_r Decidim::Dev.asset("city.jpeg"), "#{__dir__}/../decidim_dummy_app/public/#{path}/city.jpeg"
      organization.welcome_notification_body = text
      organization.save!
    end

    after do
      FileUtils.rm_r "#{__dir__}/../decidim_dummy_app/public/uploads", force: true
    end

    it "sends an email with the result of the export" do
      mappings = []
      expect(new_image.file.attached?).to be true
      expect(old_image.file.attached?).to be false
      expect(organization.welcome_notification_body["en"]).to include("#{path}/city.jpeg")

      subject.perform_now(organization.id, mappings, logger)
      expect(new_image.reload.file.attached?).to be true
      expect(old_image.reload.file.attached?).to be true
      expect(organization.reload.welcome_notification_body["en"]).not_to include("#{path}/city.jpeg")
      expect(organization.welcome_notification_body["en"]).to include(old_image.attached_uploader(:file).path)
    end
  end
end
