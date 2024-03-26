# frozen_string_literal: true

require "spec_helper"

describe EtiquetteValidator do
  subject { validatable.new(title:, body:) }

  let(:validatable) do
    Class.new do
      def self.model_name
        ActiveModel::Name.new(self, nil, "Validatable")
      end

      include Decidim::AttributeObject::Model
      include ActiveModel::Validations

      attribute :title
      attribute :body

      validates :title, :body, etiquette: true

      def awesome_config
        Decidim::DecidimAwesome::Config.new(Decidim::Organization.first)
      end
    end
  end

  let(:title) { "A valid title" }
  let(:body) { "A valid body" }
  let(:organization) { create(:organization) }
  let(:title_max_caps_percent) { 20 }
  let(:title_max_marks_together) { 2 }
  let(:title_start_with_caps) { true }
  let!(:validate_title_max_caps_percent) { create(:awesome_config, organization:, var: :validate_title_max_caps_percent, value: title_max_caps_percent) }
  let!(:validate_title_max_marks_together) { create(:awesome_config, organization:, var: :validate_title_max_marks_together, value: title_max_marks_together) }
  let!(:validate_title_start_with_caps) { create(:awesome_config, organization:, var: :validate_title_start_with_caps, value: title_start_with_caps) }
  let(:body_max_caps_percent) { 20 }
  let(:body_max_marks_together) { 2 }
  let(:body_start_with_caps) { true }
  let!(:validate_body_max_caps_percent) { create(:awesome_config, organization:, var: :validate_body_max_caps_percent, value: body_max_caps_percent) }
  let!(:validate_body_max_marks_together) { create(:awesome_config, organization:, var: :validate_body_max_marks_together, value: body_max_marks_together) }
  let!(:validate_body_start_with_caps) { create(:awesome_config, organization:, var: :validate_body_start_with_caps, value: body_start_with_caps) }

  it { is_expected.to be_valid }

  shared_examples "attribute caps validation" do |attribute|
    context "when #{attribute} has too much caps" do
      let(attribute) { "A SCREAMING PIECE of text" }

      it { is_expected.not_to be_valid }

      context "and is allowed" do
        let("#{attribute}_max_caps_percent".to_sym) { 100 }

        it { is_expected.to be_valid }
      end
    end
  end

  shared_examples "attribute marks validation" do |attribute|
    context "when #{attribute} has too many marks" do
      let(attribute) { "I am screaming!!?" }

      it { is_expected.not_to be_valid }

      context "and is allowed" do
        let("#{attribute}_max_marks_together".to_sym) { 3 }

        it { is_expected.to be_valid }
      end
    end
  end

  shared_examples "attribute start with caps validation" do |attribute|
    context "when #{attribute} must start with caps" do
      let(attribute) { "a valid text" }

      it { is_expected.not_to be_valid }

      context "and is allowed" do
        let("#{attribute}_start_with_caps".to_sym) { false }

        it { is_expected.to be_valid }
      end
    end
  end

  it_behaves_like "attribute caps validation", :title
  it_behaves_like "attribute caps validation", :body
  it_behaves_like "attribute marks validation", :title
  it_behaves_like "attribute marks validation", :body
  it_behaves_like "attribute start with caps validation", :title
  it_behaves_like "attribute start with caps validation", :body
end
