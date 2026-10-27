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

    context "when custom fields have constraints" do
      let(:data) { '{"type":"text","label":"Full Name","name":"full-name","required":true,"maxlength":"10"}' }
      let(:private_data) { '{"type":"text","label":"Email","name":"email","required":true}' }
      let(:body) { '<xml><dl><dt name="full-name">Full Name</dt><dd id="full-name"><div>Lucky Luke</div></dd></dl></xml>' }
      let(:private_body) { '<xml><dl><dt name="email">Email</dt><dd id="email"><div>lucky@example.org</div></dd></dl></xml>' }

      it { is_expected.to be_valid }

      context "and required fields are empty" do
        let(:body) { nil }
        let(:private_body) { nil }

        it "adds the errors to the default locale and the private body" do
          expect(form).not_to be_valid
          expect(form.errors[:body_en]).to eq(["The field 'Full Name' can't be blank"])
          expect(form.errors[:private_body]).to eq(["The field 'Email' can't be blank"])
        end
      end

      context "and the organization has more locales" do
        let(:organization) { create(:organization, available_locales: [:en, :ca], default_locale: :en) }
        let(:params) { super().merge(body_ca:) }
        let(:body_ca) { nil }

        it "does not require the fields in other locales" do
          expect(form).to be_valid
        end

        context "and a value is too long in another locale" do
          let(:body_ca) { '<xml><dl><dt name="full-name">Full Name</dt><dd id="full-name"><div>John Barleycorn</div></dd></dl></xml>' }

          it "adds the error to that locale" do
            expect(form).not_to be_valid
            expect(form.errors[:body_ca]).to eq(["The field 'Full Name' is too long (maximum is 10 characters)"])
          end
        end
      end
    end

    describe "etiquette validations" do
      let(:body) { "Some body" }

      it_behaves_like "minimum length", :title
    end
  end
end
