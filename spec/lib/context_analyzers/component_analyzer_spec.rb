# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module ContextAnalyzers
    describe ComponentAnalyzer do
      subject { described_class.context_for component }

      let!(:participatory_process) { create :participatory_process }
      let(:component) { double(participatory_space: participatory_process) }
      let(:context) do
        {
          participatory_space_manifest: participatory_process.manifest.name.to_s,
          participatory_space_slug: participatory_process.slug
        }
      end

      it "returns participatory_space" do
        expect(subject).to eq(context)
      end

      context "when analyzing a bare component" do
        let!(:component) { create(:dummy_component, participatory_space: participatory_process) }
        let(:context) do
          {
            participatory_space_manifest: participatory_process.manifest.name.to_s,
            participatory_space_slug: participatory_process.slug,
            component_id: component.id.to_s,
            component_manifest: component.manifest_name.to_s
          }
        end

        it "returns matching context" do
          expect(subject).to eq(context)
        end
      end

      context "when analyzing a named component" do
        let(:proposal_component) { create :component, manifest_name: :proposals, participatory_space: participatory_process }
        let!(:component) { create :proposal, component: proposal_component }
        let(:context) do
          {
            participatory_space_manifest: participatory_process.manifest.name.to_s,
            participatory_space_slug: participatory_process.slug,
            component_id: proposal_component.id.to_s,
            component_manifest: proposal_component.manifest_name.to_s
          }
        end

        it "returns matching context" do
          expect(subject).to eq(context)
        end
      end
    end
  end
end
