# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateConfig do
      subject { described_class.new(form) }

      let(:organization) { create(:organization) }
      let(:context) do
        {
          current_user: create(:user, organization: organization),
          current_organization: organization
        }
      end
      let(:params) do
        {
          allow_images_in_full_editor: true,
          allow_images_in_small_editor: true
        }
      end
      let(:form) do
        ConfigForm.from_params(params).with_context(context)
      end

      describe "when valid" do
        before do
          allow(form).to receive(:valid?).and_return(true)
        end

        it "broadcasts :ok and modifies the config options" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization: organization, var: :allow_images_in_full_editor).value).to eq(true)
          expect(AwesomeConfig.find_by(organization: organization, var: :allow_images_in_small_editor).value).to eq(true)
        end
      end

      describe "when invalid" do
        before do
          allow(form).to receive(:valid?).and_return(false)
        end

        let!(:config) do
          create(:awesome_config, organization: organization, var: :allow_images_in_full_editor, value: false)
        end

        it "broadcasts :invalid and does not modifiy the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization: organization, var: :allow_images_in_full_editor).value).to eq(false)
        end
      end
    end
  end
end
