# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/proposal_form_examples"

module Decidim::Proposals::Admin
  describe ProposalForm do
    subject { form }

    let(:params) do
      {
        title_en: title,
        body_en: body,
        private_body:,
        body_template:
      }
    end

    include_context "with a custom fields enabled"

    context "when is scoped under custom fields" do
      it { is_expected.to be_valid }
    end

    context "when not scoped under custom fields" do
      let(:slug) { "another-slug" }

      it "does not return custom fields" do
        expect(form.custom_fields).to be_empty
      end

      context "and body is not present" do
        it { is_expected.not_to be_valid }
      end
    end

    describe "etiquette validations" do
      let(:body) { "Some body" }

      it_behaves_like "minimum length", :title
    end
  end
end
