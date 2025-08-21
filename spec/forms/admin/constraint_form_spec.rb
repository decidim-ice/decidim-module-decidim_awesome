# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe ConstraintForm do
      subject { described_class.from_params(attributes) }

      let(:attributes) do
        {
          participatory_space_manifest: "some-manifest"
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when component manifest specified" do
        let(:attributes) do
          {
            component_manifest: "some-manifest"
          }
        end

        it { is_expected.to be_valid }

        context "and component_id is specified" do
          let(:attributes) do
            {
              component_manifest: "some-manifest",
              component_id: 123
            }
          end

          it { is_expected.not_to be_valid }
        end

        context "and space manifest is not a participatory space" do
          let(:attributes) do
            {
              participatory_space_manifest: "system",
              component_manifest: "some-manifest"
            }
          end

          it { is_expected.not_to be_valid }
        end
      end

      context "when component ID specified" do
        let(:attributes) do
          {
            component_id: 123
          }
        end

        it { is_expected.to be_valid }

        context "and component manifest is specified" do
          let(:attributes) do
            {
              component_manifest: "some-manifest",
              component_id: 123
            }
          end

          it { is_expected.not_to be_valid }
        end
      end

      context "when context is specified" do
        let(:attributes) do
          {
            application_context: "anonymous"
          }
        end

        it { is_expected.to be_valid }

        context "and context is not included" do
          let(:attributes) do
            {
              application_context: "unknown"
            }
          end

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
