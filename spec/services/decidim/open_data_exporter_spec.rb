# frozen_string_literal: true

require "spec_helper"

describe Decidim::OpenDataExporter do
  describe "export proposals" do
    context "with private proposals" do
      subject { described_class.new(organization, path) }

      let(:organization) { create(:organization) }
      let(:path) { File.join(Dir.tmpdir, "test-open-data.zip") }
      let(:csv_file) { Zip::File.open(path).glob("*open-data-proposals.csv").first }
      let(:csv_data) { csv_file.get_input_stream.read }

      let(:participatory_process) { create(:participatory_process, organization: organization) }
      let(:component) { create(:proposal_component, participatory_space: participatory_process) }

      let(:public_data) do
        { "foo" => '[{"type":"text","label":"Full Name","subtype":"text","className":"form-control","name":"text-1476748004559"}]' }
      end
      let(:private_data) do
        { "bar" => '[{"type":"text","subtype":"text","label":"Phone Number","className":"form-control","name":"text-1476748007461"}]' }
      end
      let(:body) do
        {
          "en" => '<xml><dl class="decidim_awesome-custom_fields" data-generator="decidim_awesome" data-version="0.7.2"><dt name="text-1476748004559">Full Name</dt><dd id="text-1476748004559" name="text"><div>Tiffany Woods</div></dd></dl></xml>'
        }
      end
      let(:private_body) { '<xml><dl class="decidim_awesome-custom_fields" data-generator="decidim_awesome" data-version="0.7.2"><dt name="text-1476748007461">Phone Number</dt><dd id="text-1476748007461" name="text"><div>021 xxx xx 641</div></dd></dl></xml>' }
      let(:config_helper) { create(:awesome_config, organization: organization, var: :proposal_custom_field_foo) }
      let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => participatory_process.slug }) }
      let!(:config) do
        create(:awesome_config, organization: organization, var: :proposal_custom_fields, value: public_data)
        create(:awesome_config, organization: organization, var: :proposal_private_custom_fields, value: private_data)
      end

      let!(:proposal) { create(:proposal, component: component, body: body, private_body: private_body) }

      before do
        subject.export
      end

      it "includes proposal body fields" do
        expect(csv_data).to include("body/full-name/en")
        expect(csv_data).to include("Tiffany Woods")
      end

      it "ignores proposal private body fields" do
        expect(csv_data).not_to include("private_body/")
        expect(csv_data).not_to include("021 xxx xx 641")
      end
    end
  end
end
