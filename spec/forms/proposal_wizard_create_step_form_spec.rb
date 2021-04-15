# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalWizardCreateStepForm do
    subject { form }

    let(:params) do
      {
        title: title,
        body: body,
        body_template: body_template
      }
    end

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
    let(:component) { create(:proposal_component, participatory_space: participatory_space) }
    let(:title) { "More sidewalks and less roads" }
    let(:body) { nil }
    let(:body_template) { nil }
    let(:author) { create(:user, organization: organization) }

    let(:form) do
      described_class.from_params(params).with_context(
        current_component: component,
        current_organization: component.organization,
        current_participatory_space: participatory_space
      )
    end

    let(:data) { '{"type":"text","label":"Full Name","subtype":"text","className":"form-control","name":"text-1476748004559"}' }
    let(:custom_fields) do
      {
        "foo" => "[#{data}]"
      }
    end
    let!(:config) { create :awesome_config, organization: organization, var: :proposal_custom_fields, value: custom_fields }
    let(:config_helper) { create :awesome_config, organization: organization, var: :proposal_custom_field_foo }
    let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug }) }
    let(:slug) { participatory_space.slug }

    context "when is scoped under custom fields" do
      it { is_expected.to be_valid }
    end

    context "when not scoped under custom fields" do
      let(:slug) { "another-slug" }

      context "and body is not present" do
        it { is_expected.to be_invalid }
      end

      context "and body is invalid" do
        let(:body) { "aa" }

        it { is_expected.to be_invalid }
      end
    end

    context "when there's a body template set" do
      let(:body_template) { "This is the template" }

      context "when is scoped under custom fields" do
        it { is_expected.to be_valid }

        context "when the template and the body are the same" do
          let(:body) { body_template }

          it { is_expected.to be_valid }
        end
      end

      context "when not scoped under custom fields" do
        let(:slug) { "another-slug" }

        it { is_expected.to be_invalid }

        context "when the template and the body are the same" do
          let(:body) { body_template }

          it { is_expected.to be_invalid }
        end
      end
    end

    context "when is a participatory text" do
      let(:component) { create(:proposal_component, :with_participatory_texts_enabled, participatory_space: participatory_space) }

      it { is_expected.to be_invalid }
    end
  end
end
