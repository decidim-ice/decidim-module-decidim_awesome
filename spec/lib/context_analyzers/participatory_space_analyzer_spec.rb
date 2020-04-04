# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module ContextAnalyzers
    describe ParticipatorySpaceAnalyzer do
      subject { described_class.context_for space }

      let(:space) { double(manifest: "some-manifest") }
      let(:context) { {} }

      it "returns empty context" do
        expect(subject).to eq(context)
      end

      context "when participatory_space exists" do
        let!(:space) { create :participatory_process }
        let(:context) do
          {
            participatory_space_manifest: space.manifest.name.to_s,
            participatory_space_slug: space.slug
          }
        end

        it "returns matching context" do
          expect(subject).to eq(context)
        end
      end
    end
  end
end
