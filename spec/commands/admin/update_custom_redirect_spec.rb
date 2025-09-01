# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/custom_redirects_contexts"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateCustomRedirect do
      subject { described_class.new(form, item) }

      include_context "with custom redirects params"

      let(:item) { double(params) }
      let(:previous_value) do
        { origin => { "destination" => "/previous-redirection", "active" => true } }
      end
      let!(:config) { create(:awesome_config, organization:, var: :custom_redirects, value: previous_value) }

      describe "when valid" do
        it "broadcasts :ok and modifies the config options" do
          expect { subject.call }.to broadcast(:ok)

          items = AwesomeConfig.find_by(organization:, var: :custom_redirects).value
          expect(items).to be_a(Hash)
          expect(items.count).to eq(1)
          expect(items.first).to eq(attributes)
        end
      end

      describe "when invalid" do
        before do
          allow(form).to receive(:valid?).and_return(false)
        end

        it "broadcasts :invalid and does not modify the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization:, var: :custom_redirects).value).to eq(previous_value)
        end
      end

      context "when other config are created" do
        let!(:config) { create(:awesome_config, organization:, var: :custom_redirects, value: attributes) }

        it "modifies the other config" do
          expect { another_config.call }.to broadcast(:ok)
          expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_editors).value).to be(true)
          expect(AwesomeConfig.find_by(organization:, var: :allow_videos_in_editors).value).to be(true)
        end

        it "do not modify current config" do
          expect(AwesomeConfig.find_by(organization:, var: :custom_redirects).value).to eq(attributes)
          expect { another_config.call }.to broadcast(:ok)
          expect(AwesomeConfig.find_by(organization:, var: :custom_redirects).value).to eq(attributes)
        end
      end

      context "when updating an non existing redirection" do
        let(:previous_value) do
          { "/another-origin" => { "destination" => "/another-redirection", "active" => true } }
        end

        it "do not modify current config" do
          expect { subject.call }.to broadcast(:invalid)

          items = AwesomeConfig.find_by(organization:, var: :custom_redirects).value
          expect(items).to be_a(Hash)
          expect(items.count).to eq(1)
          expect(items).to eq(previous_value)
        end
      end

      context "when there's several items" do
        let(:previous_value) do
          {
            "/another-origin" => { "destination" => "/another-redirection", "active" => true },
            origin => { "destination" => "/some-place-to-go", "active" => true }
          }
        end

        it "modifies the intended item" do
          expect { subject.call }.to broadcast(:ok)

          items = AwesomeConfig.find_by(organization:, var: :custom_redirects).value
          expect(items).to be_a(Hash)
          expect(items.count).to eq(2)
          expect(items).not_to eq(previous_value)
          expect(items["/another-origin"]).to eq(previous_value["/another-origin"])
          expect(items[attributes[0]]).to eq(attributes[1])
        end

        context "when changing the origin" do
          let(:item) do
            double(
              origin:,
              destination:,
              active:,
              pass_query:
            )
          end
          let(:params) do
            {
              origin: "/a-new-origin",
              destination: "/a-new-destination",
              active:,
              pass_query:
            }
          end

          it "removes the old, puts the new" do
            expect { subject.call }.to broadcast(:ok)

            items = AwesomeConfig.find_by(organization:, var: :custom_redirects).value
            expect(items).to be_a(Hash)
            expect(items.count).to eq(2)
            expect(items).not_to eq(previous_value)
            expect(items["/another-origin"]).to eq(previous_value["/another-origin"])
            expect(items["/a-new-origin"]["destination"]).to eq(params[:destination])
          end
        end
      end
    end
  end
end
