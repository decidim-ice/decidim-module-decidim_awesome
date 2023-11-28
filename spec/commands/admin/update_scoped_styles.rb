# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateConfig do
      subject { described_class.new(form) }

      let(:organization) { create(:organization) }
      let(:context) do
        {
          current_organization: organization
        }
      end
      let(:params) do
        {
          scoped_styles: styles
        }
      end
      let(:styles) do
        {
          "foo" => ".body {background: red;}",
          "bar" => ".body {background: blue;}"
        }
      end
      let(:oldstyles) do
        {
          "foo" => "",
          "bar" => ""
        }
      end
      let(:form) do
        ConfigForm.from_params(params).with_context(context)
      end
      let!(:config) { create(:awesome_config, organization:, var: :scoped_styles, value: oldstyles) }
      let(:params2) do
        {
          allow_images_in_full_editor: true,
          allow_images_in_small_editor: true
        }
      end
      let(:form2) do
        ConfigForm.from_params(params2).with_context(context)
      end
      let(:another_config) { UpdateConfig.new(form2) }

      describe "when valid" do
        before do
          allow(form).to receive(:valid?).and_return(true)
        end

        it "broadcasts :ok and modifies the config options" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles).value).to eq(styles)
        end
      end

      describe "when invalid" do
        before do
          allow(form).to receive(:valid?).and_return(false)
        end

        it "broadcasts :invalid and does not modifiy the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles).value).to eq(oldstyles)
        end
      end

      context "when other config are created" do
        let!(:config) { create(:awesome_config, organization:, var: :scoped_styles, value: styles) }

        it "modifies the other config" do
          expect { another_config.call }.to broadcast(:ok)
          expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_full_editor).value).to be(true)
          expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_small_editor).value).to be(true)
        end

        it "do not modifiy current config" do
          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles).value).to eq(styles)
          expect { another_config.call }.to broadcast(:ok)
          expect(AwesomeConfig.find_by(organization:, var: :scoped_styles).value).to eq(styles)
        end
      end
    end
  end
end
