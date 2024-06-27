# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ProposalSerializerDecorator do
    subject { serializer_class.new(proposal) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:proposal_component, participatory_space: participatory_process) }
    let(:proposal) { create(:proposal, component:) }
    let(:data) do
      '<xml><dl class="decidim_awesome-custom_fields" data-generator="decidim_awesome" data-version="0.7.2"><dt name="text-1476748007461">Age</dt><dd id="text-1476748007461" name="text"><div>14</div></dd></dl></xml>'
    end
    let(:awesome_proposal_custom_fields) do
      { foo: "[#{data}]" }.to_json
    end

    let(:serializer_class) do
      klass = Class.new do
        def initialize(proposal)
          @proposal = proposal
        end

        def serialize
          {
            propertyA: "a"
          }
        end

        private

        attr_reader :proposal
      end

      klass.include(Decidim::DecidimAwesome::ProposalSerializerDecorator)
      klass
    end

    before do
      # Assuming `awesome_proposal_custom_fields` is somehow populated for the test environment
      allow(proposal).to receive(:awesome_proposal_custom_fields).and_return(awesome_proposal_custom_fields)
    end

    describe "#serialize" do
      let(:expected_custom_field) { { "field/age": "12" } }

      it "keep the original class's serialize method" do
        expect(subject.serialize).to include({ propertyA: "a" })
      end

      it "includes custom fields in the serialization" do
        expect(subject.serialize).to include(expected_custom_field)
      end
    end

    describe "#awesome_config_instance" do
      it "Get a config instance based on the proposal's organization and component" do
        config = subject.awesome_config_instance
        expect(config).to be_a(Config)
        expect(config.organization).to eq(proposal.organization)
        expect(config.component).to eq(proposal.component)
      end
    end
  end
end
