# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/verification_visibility_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:organization) { create(:organization) }
  let(:path) { File.join(Dir.tmpdir, "test-open-data.zip") }
  let(:csv_file) { Zip::File.open(path).glob("*open-data-proposals.csv").first }
  let(:csv_data) { csv_file.get_input_stream.read }
  let(:comment_csv_file) { Zip::File.open(path).glob("*open-data-proposal_comments.csv").first }
  let(:comment_csv_data) { comment_csv_file.get_input_stream.read }
  let(:assembly_csv_file) { Zip::File.open(path).glob("*open-data-assemblies.csv").first }
  let(:assembly_csv_data) { assembly_csv_file.get_input_stream.read }
  let(:process_csv_file) { Zip::File.open(path).glob("*open-data-participatory_processes.csv").first }
  let(:process_csv_data) { process_csv_file.get_input_stream.read }

  describe "export proposals" do
    context "with private proposals" do
      let(:participatory_process) { create(:participatory_process, organization:) }
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
      let(:config_helper) { create(:awesome_config, organization:, var: :proposal_custom_field_foo) }
      let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => participatory_process.slug }) }
      let!(:config) do
        create(:awesome_config, organization:, var: :proposal_custom_fields, value: public_data)
        create(:awesome_config, organization:, var: :proposal_private_custom_fields, value: private_data)
      end

      let!(:proposal) { create(:proposal, component:, body:, private_body:) }

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

  describe "export with verification restrictions" do
    subject { described_class.new(organization, path) }

    include_context "verification visibility examples setup"

    it "do not include invisible resources in the export" do
      create(:config_constraint, awesome_config: sub_config, settings: { "component_manifest" => "proposals", "participatory_space_manifest" => "assemblies" })
      subject.export
      expect(process_csv_data).to include("Visible process")
      expect(assembly_csv_data).to include("Invisible assembly")
      expect(csv_data).to include("Process proposal")
      expect(csv_data).not_to include("Assembly proposal")
      expect(comment_csv_data).to include("Process comment")
      expect(comment_csv_data).not_to include("Assembly comment")
    end

    it "does not include invisible resources in the export if restriction is on the space" do
      create(:config_constraint, awesome_config: sub_config, settings: { "participatory_space_manifest" => "assemblies" })
      subject.export
      expect(process_csv_data).to include("Visible process")
      expect(assembly_csv_data).not_to include("Invisible assembly")
      expect(csv_data).to include("Process proposal")
      expect(csv_data).not_to include("Assembly proposal")
      expect(comment_csv_data).to include("Process comment")
      expect(comment_csv_data).not_to include("Assembly comment")
    end
  end
end
