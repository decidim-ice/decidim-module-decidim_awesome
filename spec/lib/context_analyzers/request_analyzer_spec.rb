# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module ContextAnalyzers
    describe RequestAnalyzer do
      subject { described_class.context_for request }

      let(:request) { double(url: url) }
      let(:url) { "" }
      let(:context) { {} }

      it "returns no context" do
        expect(subject).to eq(context)
      end

      paths = {
        "/" => {},
        "/processes" => { participatory_space_manifest: "participatory_processes" },
        "/processes_groups" => { participatory_space_manifest: "process_groups" },
        "/processes_groups/123" => { participatory_space_manifest: "process_groups", participatory_space_slug: "123" },
        "https://www.decidim.barcelona/processes/" => { participatory_space_manifest: "participatory_processes" },
        "https://www.decidim.barcelona/processes/PressupostosParticipatius" => {
          participatory_space_manifest: "participatory_processes",
          participatory_space_slug: "PressupostosParticipatius"
        },
        "/assemblies" => { participatory_space_manifest: "assemblies" },
        "/assemblies/some-assembly" => {
          participatory_space_manifest: "assemblies",
          participatory_space_slug: "some-assembly"
        },
        "/assemblies/some-assembly/f/12" => {
          participatory_space_manifest: "assemblies",
          participatory_space_slug: "some-assembly",
          component_id: "12"
        },
        "/assemblies/some-assembly/f/12/" => {
          participatory_space_manifest: "assemblies",
          participatory_space_slug: "some-assembly",
          component_id: "12"
        }
      }

      admin_paths = {
        "/admin" => {},
        "/admin/participatory_processes" => { participatory_space_manifest: "participatory_processes" },
        "/admin/participatory_process_groups" => { participatory_space_manifest: "process_groups" },
        "/admin/assemblies" => { participatory_space_manifest: "assemblies" },
        "/admin/assemblies_types" => { participatory_space_manifest: "assemblies" },
        "/admin/assemblies/some-assembly" => {
          participatory_space_manifest: "assemblies",
          participatory_space_slug: "some-assembly"
        },
        "http://localhost:3000/admin/participatory_processes/some-process/components/12/manage/" => {
          participatory_space_manifest: "participatory_processes",
          participatory_space_slug: "some-process",
          component_id: "12"
        }
      }

      paths.each do |path, ctx|
        context "when #{path}" do
          let(:url) { path }
          let(:context) { ctx }

          it "detects context in public #{path}" do
            expect(subject).to eq(context)
          end
        end
      end

      admin_paths.each do |path, ctx|
        context "when #{path}" do
          let(:url) { path }
          let(:context) { ctx }

          it "detects context in admin #{path}" do
            expect(subject).to eq(context)
          end
        end
      end

      context "when component is found" do
        let!(:participatory_process) { create :participatory_process }
        let!(:component) { create(:dummy_component, participatory_space: participatory_process) }
        let(:context) do
          {
            participatory_space_manifest: participatory_process.manifest.name.to_s,
            participatory_space_slug: participatory_process.slug,
            component_id: component.id.to_s,
            component_manifest: component.manifest_name.to_s
          }
        end

        context "and is frontend url" do
          let(:url) { "/processes/#{participatory_process.slug}/f/#{component.id}" }

          it "returns the component manifest" do
            expect(subject).to eq(context)
          end
        end

        context "and is admin url" do
          let(:url) { "/admin/participatory_processes/#{participatory_process.slug}/components/#{component.id}" }

          it "returns the component manifest" do
            expect(subject).to eq(context)
          end
        end
      end
    end
  end
end
