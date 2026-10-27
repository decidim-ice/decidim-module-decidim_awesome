# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/proposal_form_examples"

module Decidim::Proposals
  describe ProposalForm do
    subject { form }

    let(:params) do
      {
        title:,
        body:,
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

      context "and body is invalid" do
        let(:body) { "aa" }

        it { is_expected.not_to be_valid }
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

        it { is_expected.not_to be_valid }

        context "when the template and the body are the same" do
          let(:body) { body_template }

          it { is_expected.not_to be_valid }
        end
      end
    end

    context "when is a participatory text" do
      let(:component) { create(:proposal_component, :with_participatory_texts_enabled, participatory_space:) }

      it { is_expected.not_to be_valid }
    end

    context "when the body exceeds the permitted length" do
      let(:component) { create(:proposal_component, :with_proposal_length, participatory_space:, proposal_length: allowed_length) }
      let(:allowed_length) { 15 }
      let(:body) { "A body longer than the permitted" }

      context "when not scoped under custom fields" do
        let(:slug) { "another-slug" }

        it { is_expected.not_to be_valid }
      end

      context "when is scoped under custom fields" do
        it { is_expected.to be_valid }
      end
    end

    context "when custom fields have constraints" do
      let(:data) { '{"type":"text","label":"Full Name","name":"full-name","required":true,"maxlength":"10"}' }
      let(:private_data) { '{"type":"text","label":"Email","name":"email","required":true}' }
      let(:body) { %(<xml><dl><dt name="full-name">Full Name</dt><dd id="full-name"><div>#{name}</div></dd></dl></xml>) }
      let(:private_body) { '<xml><dl><dt name="email">Email</dt><dd id="email"><div>lucky@example.org</div></dd></dl></xml>' }
      let(:name) { "Lucky Luke" }

      it { is_expected.to be_valid }

      context "and required fields are empty" do
        let(:body) { nil }
        let(:private_body) { nil }

        it "adds the errors to each body" do
          expect(form).not_to be_valid
          expect(form.errors[:body]).to eq(["The field 'Full Name' can't be blank"])
          expect(form.errors[:private_body]).to eq(["The field 'Email' can't be blank"])
        end
      end

      context "and a value is too long" do
        let(:name) { "John Barleycorn" }

        it "adds the error to the body" do
          expect(form).not_to be_valid
          expect(form.errors[:body]).to eq(["The field 'Full Name' is too long (maximum is 10 characters)"])
        end
      end

      context "and is a participatory text" do
        let(:component) { create(:proposal_component, :with_participatory_texts_enabled, participatory_space:) }
        let(:body) { nil }

        it "does not validate the custom fields" do
          form.valid?
          expect(form.errors[:body]).not_to include("The field 'Full Name' can't be blank")
        end
      end
    end

    describe "etiquette validations" do
      let(:body) { "A body longer than the permitted" }

      it_behaves_like "minimum length", :title
      it_behaves_like "minimum length", :body
      it_behaves_like "starts with caps", :title
      it_behaves_like "starts with caps", :body
      it_behaves_like "max caps percent", :title
      it_behaves_like "max caps percent", :body
      it_behaves_like "max marks together", :title
      it_behaves_like "max marks together", :body
    end
  end
end
