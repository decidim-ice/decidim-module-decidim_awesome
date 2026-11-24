# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe EditorFileUploader do
    subject { described_class.new(model, :file) }

    let(:model) { create(:organization, file_upload_settings:) }
    let(:file_upload_settings) { Decidim::OrganizationSettings.default(:upload) }

    it "allows the images by default" do
      expect(subject.content_type_allowlist).to eq(%w(image/jpeg image/png image/gif image/webp))
      expect(subject.extension_allowlist).to match_array(%w(jpeg jpg png gif webp))
    end

    context "when the list has content types the organization does not accept from admins" do
      before do
        allow(Decidim::DecidimAwesome).to receive(:html_code_editor_allowed_mime).and_return(%w(image/png application/pdf application/zip))
      end

      it "skips them" do
        expect(subject.content_type_allowlist).to eq(%w(image/png application/pdf))
      end
    end

    context "when the organization accepts fewer content types from admins" do
      let(:file_upload_settings) { Decidim::OrganizationSettings.default(:upload).deep_merge("allowed_content_types" => { "admin" => %w(image/png) }) }

      it "keeps only the ones in both lists" do
        expect(subject.content_type_allowlist).to eq(%w(image/png))
      end
    end
  end
end
