# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe Config do
    subject { described_class.new organization }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
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

      context "and url is process group" do
        let(:request) { double(url: "/participatory_process_groups/123") }

        it "converts url to context" do
          subject.context_from_request(request)
          expect(subject.context).to eq(participatory_space_manifest: "process_groups", participatory_space_slug: "123")
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
        config.merge(allow_images_in_editors: true)
      end
      let!(:awesome_config) { create(:awesome_config, organization:, var: :allow_images_in_editors, value: true) }

      it "differs from the basic config" do
        expect(subject.config).not_to eq(config)
      end

      it "matches personalized config" do
        expect(subject.config).to eq(custom_config)
      end

      context "and some value is a hash" do
        let(:settings) do
          {
            "chat_id" => "-1234",
            :color => "red",
            :use_floating_button => true
          }
        end
        let!(:awesome_config) { create(:awesome_config, organization:, var: :intergram_for_public_settings, value: settings) }

        it "returns the config normalized" do
          expect(subject.config[:intergram_for_public_settings][:chat_id]).to eq("-1234")
          expect(subject.config[:intergram_for_public_settings][:color]).to eq("red")
          expect(subject.config[:intergram_for_public_settings][:require_login]).to be(true)
          expect(subject.config[:intergram_for_public_settings][:use_floating_button]).to be(true)
        end
      end
    end

    context "when some config is disabled" do
      before do
        subject.defaults = Decidim::DecidimAwesome.config.merge(allow_images_in_editors: :disabled)
        # de-memoize
        subject.instance_variable_set :@config, nil
      end

      let!(:awesome_config) { create(:awesome_config, organization:, var: :allow_images_in_editors, value: true) }

      it "always defaults to false" do
        expect(subject.config[:allow_images_in_editors]).to be(false)
      end
    end

    context "when there are constraints" do
      let!(:awesome_config) { create(:awesome_config, organization:, var: :allow_images_in_editors, value: true) }
      let!(:constraint1) { create(:config_constraint, awesome_config:, settings: settings1) }
      let!(:constraint2) { create(:config_constraint, awesome_config:, settings: settings2) }
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
        config.merge(allow_images_in_editors: true)
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

    context "when there are subconfigs" do
      let!(:awesome_config) { create(:awesome_config, organization:, var: :scoped_styles, value: values) }
      let(:config_helper_foo) { create(:awesome_config, organization:, var: :scoped_style_foo, value: nil) }
      let(:config_helper_bar) { create(:awesome_config, organization:, var: :scoped_style_bar, value: nil) }
      let!(:constraint_foo) { create(:config_constraint, awesome_config: config_helper_foo, settings: settings_foo) }
      let!(:constraint_bar) { create(:config_constraint, awesome_config: config_helper_bar, settings: settings_bar) }
      let(:values) do
        {
          "foo" => "{ color: red; }",
          "bar" => "{ color: blue; }"
        }
      end
      let(:settings_foo) do
        {
          "participatory_space_manifest" => participatory_process.manifest.name.to_s,
          "participatory_space_slug" => participatory_process.slug
        }
      end
      let(:settings_bar) do
        {
          "participatory_space_manifest" => "assemblies"
        }
      end
      let(:all_subconfigs) do
        {
          foo: config_helper_foo,
          bar: config_helper_bar
        }
      end
      let(:request) { double(url: "/processes/#{participatory_process.slug}") }
      let(:subconfigs) { subject.sub_configs_for("scoped_style") }
      let(:collected_values) { subject.collect_sub_configs_values("scoped_style") }
      let(:unfiltered_collected_values) do
        subject.collect_sub_configs_values("scoped_style") { true }
      end
      let(:additional_constraints) do
        [double(settings: { "participatory_space_manifest" => "none" })]
      end

      it "gathers subconfigs" do
        expect(subconfigs).to eq(all_subconfigs)
        expect(collected_values).to eq([])
      end

      it "filters subconfig values in the current context" do
        subject.context_from_request(request)
        expect(collected_values).to eq([values["foo"]])
      end

      it "can collect all subconfig values" do
        subject.context_from_request(request)
        expect(unfiltered_collected_values).to match_array(values.values)
      end

      it "can dynamically add constraints" do
        subject.inject_sub_config_constraints("scoped_style", "foo", additional_constraints)
        expect(subconfigs[:foo].constraints).not_to include(additional_constraints.first)
        expect(subconfigs[:foo].all_constraints).to include(additional_constraints.first)
      end

      context "when several results" do
        let(:settings_bar) do
          {
            "participatory_space_manifest" => participatory_process.manifest.name.to_s
          }
        end

        before do
          subject.context_from_request(request)
        end

        it "callects all matching values" do
          expect(collected_values).to match_array(values.values)
        end

        it "dynamically added constraints affectes evaluated subconfig values" do
          subject.inject_sub_config_constraints("scoped_style", "bar", additional_constraints)
          expect(collected_values).to eq([values["foo"]])
        end
      end
    end
  end
end
