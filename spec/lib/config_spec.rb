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

    let(:request) { double(url: "/processes/some-slug/f/12") }

    it "has a basic config" do
      expect(subject.config).to eq(config)
    end

    it "converts url to context" do
      subject.context_from_request(request)
      expect(subject.context).to eq(participatory_space_manifest: "participatory_processes", participatory_space_slug: "some-slug", component_id: "12")
    end

    context "when url is in the admin" do
      let(:request) { double(url: "/admin/participatory_processes/natus-molestias/edit") }

      it "converts url to context" do
        subject.context_from_request(request)
        expect(subject.context).to eq(participatory_space_manifest: "participatory_processes", participatory_space_slug: "natus-molestias")
      end

      context "and url manages component" do
        let(:request) { double(url: "/admin/participatory_processes/natus-molestias/components/9/manage/") }

        it "converts url to context" do
          subject.context_from_request(request)
          expect(subject.context).to eq(participatory_space_manifest: "participatory_processes", participatory_space_slug: "natus-molestias", component_id: "9")
        end
      end

      context "and url is not a participatory space" do
        let(:request) { double(url: "/admin/newsletters/new") }

        it "converts url to context" do
          subject.context_from_request(request)
          expect(subject.context).to eq(participatory_space_manifest: "system")
        end
      end
    end

    context "when url does not match anything" do
      let(:request) { double(url: "/newsletters") }

      it "returns empty context" do
        subject.context_from_request(request)
        expect(subject.context).to be_empty
      end
    end

    it "converts component to context" do
      subject.context_from_component(component)
      expect(subject.context).to eq(
        participatory_space_manifest: participatory_process.manifest.name.to_s,
        participatory_space_slug: participatory_process.slug,
        component_id: component.id.to_s,
        component_manifest: component.manifest.name.to_s
      )
    end

    it "converts participatory_space to context" do
      subject.context_from_participatory_space(participatory_process)
      expect(subject.context).to eq(
        participatory_space_manifest: participatory_process.manifest.name.to_s,
        participatory_space_slug: participatory_process.slug
      )
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

    context "when some config is disabled" do
      before do
        subject.defaults = Decidim::DecidimAwesome.config.merge(allow_images_in_full_editor: :disabled)
        # de-memoize
        subject.instance_variable_set :@config, nil
      end

      let!(:awesome_config) { create :awesome_config, organization: organization, var: :allow_images_in_full_editor, value: true }

      it "always defaults to false" do
        expect(subject.config[:allow_images_in_full_editor]).to eq(false)
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
