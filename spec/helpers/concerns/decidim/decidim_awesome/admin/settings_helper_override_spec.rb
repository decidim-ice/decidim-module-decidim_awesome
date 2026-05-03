# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe SettingsHelper do
      describe "#form_method_for_attribute" do
        subject { helper.form_method_for_attribute(attribute, {}) }

        context "when the attribute is :array with choices" do
          let(:attribute) do
            Decidim::SettingsManifest::Attribute.new(type: :array, choices: ->(_ctx) { [%w(Foo 1)] })
          end

          it { is_expected.to eq(:awesome_multiselect) }
        end

        context "when the attribute is :array without choices" do
          let(:attribute) { Decidim::SettingsManifest::Attribute.new(type: :array, default: []) }

          it "delegates to the original implementation" do
            expect(subject).to be_nil
          end
        end

        context "when the attribute is :boolean" do
          let(:attribute) { Decidim::SettingsManifest::Attribute.new(type: :boolean) }

          it { is_expected.to eq(:check_box) }
        end

        context "when the attribute is :select" do
          let(:attribute) do
            Decidim::SettingsManifest::Attribute.new(type: :select, choices: ->(_ctx) { %w(a b) })
          end

          it { is_expected.to eq(:select_field) }
        end

        context "when the attribute is :text with editor option" do
          let(:attribute) { Decidim::SettingsManifest::Attribute.new(type: :text) }

          it "delegates to the original implementation" do
            expect(helper.form_method_for_attribute(attribute, editor: true)).to eq(:editor)
          end
        end
      end

      describe "#render_field_form_method" do
        let(:attribute) do
          Decidim::SettingsManifest::Attribute.new(type: :array, choices: ->(_ctx) { [%w(First 1), %w(Second 2)] })
        end
        let(:settings_class) { Class.new { attr_accessor :picks, :awesome_votes_enabled_states } }
        let(:settings_object) do
          settings_class.new.tap do |s|
            s.picks = []
            s.awesome_votes_enabled_states = []
          end
        end
        let(:form) { Decidim::Admin::FormBuilder.new("settings", settings_object, helper, {}) }

        context "when the form method is :awesome_multiselect" do
          it "renders a multi-select listing all choices" do
            html = helper.send(:render_field_form_method, :awesome_multiselect, form, attribute, :picks, "scope", { label: "Pick" })
            expect(html).to include('multiple="multiple"')
            expect(html).to include("First")
            expect(html).to include("Second")
          end

          it "wires the Stimulus controller for the awesome_votes_enabled_states attribute" do
            html = helper.send(:render_field_form_method, :awesome_multiselect, form, attribute, :awesome_votes_enabled_states, "scope", { label: "Pick" })
            expect(html).to include('data-controller="awesome-votes-by-status"')
          end
        end

        context "when the form method is anything else" do
          let(:string_attribute) { Decidim::SettingsManifest::Attribute.new(type: :string) }

          it "delegates to the original implementation" do
            html = helper.send(:render_field_form_method, :text_field, form, string_attribute, :picks, "scope", { label: "Pick" })
            expect(html).to include('type="text"')
          end
        end
      end
    end
  end
end
