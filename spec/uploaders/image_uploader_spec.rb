# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ImageUploader do
    subject { uploader }

    let(:uploader) { described_class.new(model, mounted_as) }
    let(:model) { create(:organization, file_upload_settings:) }
    let(:mounted_as) { :favicon }
    let(:file_upload_settings) do
      Decidim::OrganizationSettings.default(:upload).deep_merge(
        "allowed_file_extensions" => { "image" => extensions }
      )
    end
    let(:extensions) { %w(jpg jpeg png) }

    describe "#extension_allowlist" do
      subject { uploader.extension_allowlist }

      it "returns the allowed image extensions" do
        expect(subject).to eq(extensions)
      end
    end

    describe "#content_type_allowlist" do
      subject { uploader.content_type_allowlist }

      it "returns the correct MIME types" do
        expect(subject).to eq(%w(image/jpeg image/png))
      end
    end

    describe "#max_image_height_or_width" do
      subject { uploader.max_image_height_or_width }

      it "returns the maximum allowed image height or width" do
        expect(subject).to eq(8000)
      end
    end
  end
end
