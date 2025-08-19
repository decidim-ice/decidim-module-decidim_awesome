# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateConfig do
      subject { described_class.new(form) }

      let(:organization) { create(:organization) }
      let(:context) do
        {
          current_user: create(:user, organization:),
          current_organization: organization
        }
      end
      let(:params) do
        {
          allow_images_in_editors: true,
          allow_videos_in_editors: true
        }
      end
      let(:form) do
        ConfigForm.from_params(params).with_context(context)
      end

      context "when valid" do
        before do
          allow(form).to receive(:valid?).and_return(true)
        end

        it "broadcasts :ok and modifies the config options" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_editors).value).to be(true)
          expect(AwesomeConfig.find_by(organization:, var: :allow_videos_in_editors).value).to be(true)
        end
      end

      context "when invalid" do
        before do
          allow(form).to receive(:valid?).and_return(false)
        end

        let!(:config) do
          create(:awesome_config, organization:, var: :allow_images_in_editors, value: false)
        end

        it "broadcasts :invalid and does not modifiy the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_editors).value).to be(false)
        end
      end

      context "when updating a hash" do
        let!(:config) { create(:awesome_config, organization:, var: "scoped_styles", value: { test: ".body {background: red;}" }) }
        let(:params) do
          {
            scoped_styles: { test: ".body {background: blue;}" }
          }
        end

        it "updates the value" do
          expect { subject.call }.to change { AwesomeConfig.find_by(organization:, var: "scoped_styles").value }.from({ "test" => ".body {background: red;}" }).to({ "test" => ".body {background: blue;}" })
        end
      end

      context "when the value is another form" do
        before do
          allow(form).to receive(:attributes).and_return({ "allow_images_in_editors" => double(attributes: { "test" => "some value" }) })
        end

        it "uses the attributes from the form" do
          expect { subject.call }.to change(AwesomeConfig, :count).by(1)
          expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_editors).value).to eq({ "test" => "some value" })
        end
      end

      context "when a custom attributes method is defined" do
        before do
          allow(form).to receive(:allow_images_in_editors_attributes).and_return({ "test" => "some value" })
        end

        it "uses the custom attributes from the form" do
          expect { subject.call }.to change(AwesomeConfig, :count).by(2)
          expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_editors).value).to eq({ "test" => "some value" })
          expect(AwesomeConfig.find_by(organization:, var: :allow_videos_in_editors).value).to be(true)
        end
      end
    end
  end
end
