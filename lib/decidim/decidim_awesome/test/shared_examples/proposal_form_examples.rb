# frozen_string_literal: true

shared_context "with a custom fields enabled" do
  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:proposal_component, participatory_space:) }
  let(:title) { "More sidewalks and less roads" }
  let(:body) { nil }
  let(:private_body) { nil }
  let(:body_template) { nil }
  let(:author) { create(:user, organization:) }

  let(:form) do
    described_class.from_params(params).with_context(
      current_component: component,
      current_organization: component.organization,
      current_participatory_space: participatory_space
    )
  end

  let(:data) { '{"type":"text","label":"Full Name","subtype":"text","className":"form-control","name":"text-1476748004559"}' }
  let(:private_data) { '{"type":"text","label":"Email","subtype":"text","className":"form-control","name":"text-1476748004569"}' }
  let(:custom_fields) do
    {
      "foo" => "[#{data}]"
    }
  end
  let(:private_custom_fields) do
    {
      "bar" => "[#{private_data}]"
    }
  end
  let!(:config) { create(:awesome_config, organization:, var: :proposal_custom_fields, value: custom_fields) }
  let!(:private_config) { create(:awesome_config, organization:, var: :proposal_private_custom_fields, value: private_custom_fields) }
  let(:config_helper) { create(:awesome_config, organization:, var: :proposal_custom_field_foo, value: nil) }
  let(:private_config_helper) { create(:awesome_config, organization:, var: :proposal_private_custom_field_bar, value: nil) }
  let!(:constraint) do
    create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug })
  end
  let!(:private_constraint) { create(:config_constraint, awesome_config: private_config_helper, settings: { "participatory_space_manifest" => "participatory_processes" }) }
  let(:slug) { participatory_space.slug }
end
shared_examples "starts with caps" do |prop|
  let!(:config) { create(:awesome_config, organization:, var: "validate_#{prop}_start_with_caps", value: enabled) }
  let!(:constraint) do
    create(:config_constraint, awesome_config: config, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug })
  end

  let(:enabled) { false }
  let(prop.to_sym) { "í don't start with caps" }

  it { is_expected.to be_valid }

  context "when scoped under different context" do
    let(:slug) { "another-slug" }

    it { is_expected.not_to be_valid }

    context "when starts with caps" do
      let(prop.to_sym) { "Í start with caps" }

      it { is_expected.to be_valid }
    end
  end

  context "when enabled" do
    let(:enabled) { true }

    it { is_expected.not_to be_valid }

    context "when starts with caps" do
      let(prop.to_sym) { "Í start with caps" }

      it { is_expected.to be_valid }
    end
  end
end

shared_examples "minimum length" do |prop|
  let!(:config) { create(:awesome_config, organization:, var: "validate_#{prop}_min_length", value: min_length) }
  let!(:constraint) do
    create(:config_constraint, awesome_config: config, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug })
  end

  let(:min_length) { 10 }
  let(prop.to_sym) { "I am 10 yo" }

  it { is_expected.to be_valid }

  context "when scoped under different context" do
    let(:slug) { "another-slug" }

    it { is_expected.not_to be_valid }

    context "when has more than 15 chars" do
      let(prop.to_sym) { "I am 17 years old" }

      it { is_expected.to be_valid }
    end
  end

  context "when less than allowed" do
    let(:min_length) { 11 }

    it { is_expected.not_to be_valid }
  end

  context "when min_length is zero" do
    let(:min_length) { 0 }
    let(prop.to_sym) { "" }

    if prop == :body
      it { is_expected.to be_valid }
    else
      it { is_expected.not_to be_valid }
    end
  end
end

shared_examples "max caps percent" do |prop|
  let!(:config) { create(:awesome_config, organization:, var: "validate_#{prop}_max_caps_percent", value: percent) }
  let!(:constraint) do
    create(:config_constraint, awesome_config: config, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug })
  end

  let(:percent) { 90 }
  let(prop.to_sym) { "Í ÁM A SÈMI-CÁPS text" }

  it { is_expected.to be_valid }

  shared_examples "invalid percentage" do |per|
    it "error message returns percentage" do
      expect(form).not_to be_valid
      expect(form.errors.messages.values.flatten.first).to include("over #{per}% of the text")
    end
  end

  context "when scoped under different context" do
    let(:slug) { "another-slug" }

    it_behaves_like "invalid percentage", 25

    context "when has less than 25% caps" do
      let(prop.to_sym) { "Í only have some CÁPS" }

      it { is_expected.to be_valid }
    end
  end

  context "when less than allowed" do
    let(:percent) { 11 }

    it_behaves_like "invalid percentage", 11
  end
end

shared_examples "max marks together" do |prop|
  let!(:config) { create(:awesome_config, organization:, var: "validate_#{prop}_max_marks_together", value: max_marks) }
  let!(:constraint) do
    create(:config_constraint, awesome_config: config, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug })
  end

  let(:max_marks) { 5 }
  let(prop.to_sym) { "Am I a little bit noisy??!!!" }

  it { is_expected.to be_valid }

  context "when scoped under different context" do
    let(:slug) { "another-slug" }

    it { is_expected.not_to be_valid }

    context "when has only 1 mark" do
      let(prop.to_sym) { "I am not noisy!" }

      it { is_expected.to be_valid }
    end

    context "when has 2 marks" do
      let(prop.to_sym) { "I am not noisy!?" }

      it { is_expected.not_to be_valid }
    end
  end

  context "when less than allowed" do
    let(:max_marks) { 4 }

    it { is_expected.not_to be_valid }
  end
end
