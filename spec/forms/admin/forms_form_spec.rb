# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe ConfigForm do
      subject { described_class.from_params(attributes) }

      let(:attributes) do
        {
          allow_images_in_full_editor: true,
          allow_images_in_small_editor: true
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end
    end
  end
end
