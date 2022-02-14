# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe EditorImage do
    subject { editor_image }

    let(:organization) { create(:organization) }
    let(:user) { create(:user) }
    let(:editor_image) { create(:awesome_editor_image, organization: organization, author: user) }

    it { is_expected.to be_valid }

    it "editor_image is associated with user and organization" do
      expect(subject).to eq(editor_image)
      expect(subject.organization).to eq(organization)
      expect(subject.author).to eq(user)
    end
  end
end
