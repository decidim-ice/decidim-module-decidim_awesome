# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe EditorImageForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:user) { create(:user) }
    let(:organization) { user.organization }

    let(:attributes) do
      {
        file:,
        path: "/somepath",
        author_id: user.id
      }
    end
    let(:context) do
      {
        current_organization: organization,
        current_user: user
      }
    end
    let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when everything no image" do
      let(:file) { nil }

      it { is_expected.not_to be_valid }
    end
  end
end
