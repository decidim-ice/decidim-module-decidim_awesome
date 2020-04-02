# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe EditorImageForm do
    subject { described_class.from_params(attributes) }

    let(:user) { create :user }

    let(:attributes) do
      {
        image: image,
        path: "/somepath",
        author_id: user.id
      }
    end
    let(:image) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when everything no image" do
      let(:image) { nil }

      it { is_expected.not_to be_valid }
    end
  end
end
