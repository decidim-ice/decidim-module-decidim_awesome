# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe Config do
    subject { described_class.new organization }

    let(:organization) { create :organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:component) { create(:dummy_component, participatory_space: participatory_process) }
    let(:config) do
      Decidim::DecidimAwesome.config
    end

    it "has a basic config" do
      expect(subject.config).to eq(config)
    end

    context "when some config is personalized" do
      let(:custom_config) do
        config.merge(allow_images_in_full_editor: true)
      end
      let!(:awesome_config) { create :awesome_config, organization: organization, var: :allow_images_in_full_editor, value: true }

      it "differs from the basic config" do
        expect(subject.config).not_to eq(config)
      end

      it "matches personalized config" do
        expect(subject.config).to eq(custom_config)
      end
    end

    context "when there are constraints" do
      let!(:awesome_config) { create :awesome_config, organization: organization, var: :allow_images_in_full_editor, value: true }
      let!(:constraint1) { create :config_constraint, awesome_config: awesome_config, settings: settings1 }
      let!(:constraint2) { create :config_constraint, awesome_config: awesome_config, settings: settings2 }
      let(:settings1) do
        {
          participatory_space_manifest: "assemblies"
        }
      end
      let(:settings2) do
        {
          participatory_space_manifest: manifest,
          participatory_slug: slug,
          component_id: id
        }
      end
      let(:manifest) { participatory_process.manifest.name.to_s }
      let(:slug) { participatory_process.slug }
      let(:id) { nil }
      let(:custom_config) do
        config.merge(allow_images_in_full_editor: true)
      end

      before do
        subject.context = {
          participatory_space_manifest: participatory_process.manifest.name.to_s,
          participatory_slug: participatory_process.slug
        }
      end

      it "differs from the basic config" do
        expect(subject.config).not_to eq(config)
      end

      it "matches personalized config" do
        expect(subject.config).to eq(custom_config)
      end

      context "and no constraints matches context" do
        let(:slug) { "another-slug" }

        it "matches basic config" do
          expect(subject.config).to eq(config)
        end

        it "differs from personalized config" do
          expect(subject.config).not_to eq(custom_config)
        end
      end
    end
  end
end
