# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/custom_redirects_contexts"

module Decidim::DecidimAwesome
  module Admin
    describe CreateCustomRedirect do
      subject { described_class.new(form) }

      include_context "with custom redirects params"

      describe "when valid" do
        it "broadcasts :ok and creates a hash" do
          expect { subject.call }.to broadcast(:ok)

          items = AwesomeConfig.find_by(organization:, var: :custom_redirects).value
          expect(items).to be_a(Hash)
          expect(items.count).to eq(1)
          expect(items.first).to eq(attributes)
        end

        context "and origin includes organization host" do
          let(:origin) { "http://#{organization.host}/some-path" }

          it "leaves only the path" do
            expect { subject.call }.to broadcast(:ok)

            items = AwesomeConfig.find_by(organization:, var: :custom_redirects).value
            expect(items.first[0]).to eq("/some-path")
          end
        end

        context "and destination includes organization host" do
          let(:destination) { "http://#{organization.host}/some-path" }

          it "do not remove the host" do
            expect { subject.call }.to broadcast(:ok)

            items = AwesomeConfig.find_by(organization:, var: :custom_redirects).value
            expect(items.first[1]["destination"]).to eq(destination)
          end
        end

        context "and origin is malformed" do
          let(:origin) { " Some-path " }

          it "is sanitized" do
            expect { subject.call }.to broadcast(:ok)

            items = AwesomeConfig.find_by(organization:, var: :custom_redirects).value
            expect(items.first[0]).to eq("/Some-path")
          end
        end

        context "and destination is malformed" do
          let(:destination) { " sOme-path " }

          it "is sanitized" do
            expect { subject.call }.to broadcast(:ok)

            items = AwesomeConfig.find_by(organization:, var: :custom_redirects).value
            expect(items.first[1]["destination"]).to eq("/sOme-path")
          end
        end

        context "and entries already exist" do
          let!(:config) do
            create(:awesome_config,
                   organization:,
                   var: :custom_redirects,
                   value: { "/another-redirection" => { destination: "/another-destination", active: true } })
          end

          shared_examples "has redirection content" do
            it "do not removes previous entries" do
              expect { subject.call }.to broadcast(:ok)

              items = AwesomeConfig.find_by(organization:, var: :custom_redirects).value
              expect(items.count).to eq(2)
              expect(items[attributes[0]]).to eq(attributes[1])
              expect(items["/another-redirection"]).to eq("destination" => "/another-destination", "active" => true)
            end
          end

          it_behaves_like "has redirection content"

          context "and another configuration is created" do
            before do
              another_config.call
            end

            it "modifies the other config" do
              expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_full_editor).value).to be(true)
              expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_small_editor).value).to be(true)
            end

            it_behaves_like "has redirection content"
          end

          context "and another configuration is updated" do
            let!(:existing_config) { create(:awesome_config, organization:, var: :allow_images_in_full_editor, value: false) }

            before do
              another_config.call
            end

            it "modifies the other config" do
              expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_full_editor).value).to be(true)
              expect(AwesomeConfig.find_by(organization:, var: :allow_images_in_small_editor).value).to be(true)
            end

            it_behaves_like "has redirection content"
          end
        end
      end

      describe "when same redirection exists" do
        let(:previous_redirection) do
          { "/some-path" => { "destination" => "/another-path", "active" => true } }
        end
        let!(:config) { create(:awesome_config, organization:, var: :custom_redirects, value: previous_redirection) }
        let(:origin) { "/some-path" }

        it "broadcasts :invalid and does not modifiy the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization:, var: :custom_redirects).value).to eq(previous_redirection)
        end
      end
    end
  end
end
