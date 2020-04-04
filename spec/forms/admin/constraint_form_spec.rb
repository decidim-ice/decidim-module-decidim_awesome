# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe ConstraintForm do
      subject { described_class.from_params(attributes) }

      let(:attributes) do
        {
          participatory_space_manifest: true
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end
    end
  end
end
