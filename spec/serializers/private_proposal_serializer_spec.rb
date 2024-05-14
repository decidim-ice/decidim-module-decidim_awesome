# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe PrivateProposalSerializer do
    subject do
      described_class.new(proposal)
    end
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization: organization) }
    let(:public_data) do
      { "foo" => '[{"type":"text","label":"Full Name","subtype":"text","className":"form-control","name":"text-1476748004559"}]' }
    end
    let(:private_data) do
      { "foo" => '[{"type":"text","label":"Phone Number","subtype":"text","className":"form-control","name":"text-1476748007461"}]' }
    end
    let(:public_xml) do
      '<xml><dl class="decidim_awesome-custom_fields" data-generator="decidim_awesome" data-version="0.7.2"><dt name="text-1476748004559">Full Name</dt><dd id="text-1476748004559" name="text"><div>Tiffany Woods</div></dd></dl></xml>'
    end
    let(:private_xml) do
      '<xml><dl class="decidim_awesome-custom_fields" data-generator="decidim_awesome" data-version="0.7.2"><dt name="text-1476748007461">Phone Number</dt><dd id="text-1476748007461" name="text"><div>021 xxx xx 641</div></dd></dl></xml>'
    end
    let(:config_helper) { create :awesome_config, organization: organization, var: :proposal_custom_field_foo }
    let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => participatory_process.slug }) }
    let!(:config) do
      create(:awesome_config, organization: organization, var: :proposal_custom_fields, value: public_data)
      create(:awesome_config, organization: organization, var: :private_proposal_custom_fields, value: private_data)
    end
    let(:component) { create(:proposal_component, manifest_name: "proposals", participatory_space: participatory_process) }
    let!(:proposal) do
      prop = build(:proposal, component: component, body: { en: public_xml })
      prop.build_awesome_private_proposal_field(private_body: private_xml)
      prop.save
      prop
    end

    describe "#serialize" do
      let(:serialized) { subject.serialize }

      it "serializes each body's custom fields" do
        expect(serialized).to include("field/full-name/en": ["Tiffany Woods"])
      end

      it "serializes each private_body's custom fields" do
        expect(serialized).to include("secret/phone-number": ["021 xxx xx 641"])
      end

      context "when there are no private fields" do
        # No private data provided
        let(:private_data) { { "foo" => "[]" } }

        it "does not include private field keys in the serialized output" do
          expect(serialized.keys).not_to include(match(%r{secret/}))
        end
      end
    end
  end
end
