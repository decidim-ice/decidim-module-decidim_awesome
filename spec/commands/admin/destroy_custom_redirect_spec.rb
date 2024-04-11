# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/custom_redirects_contexts"

module Decidim::DecidimAwesome
  module Admin
    describe DestroyCustomRedirect do
      subject { described_class.new(item, organization) }

      include_context "with custom redirects params"

      let(:item) { OpenStruct.new({ origin: attributes[0] }.merge(attributes[1])) }
      let(:previous_value) do
        { "/previous-route" => { "destination" => "/another-place", "active" => true } }
      end
      let!(:config) { create(:awesome_config, organization:, var: :custom_redirects, value: [attributes].to_h.merge(previous_value)) }

      describe "when valid" do
        it "broadcasts :ok and removes the item" do
          expect { subject.call }.to broadcast(:ok)

          items = AwesomeConfig.find_by(organization:, var: :custom_redirects).value

          expect(items).to be_a(Hash)
          expect(items.count).to eq(1)
          expect(items["/previous-route"]).to eq(previous_value["/previous-route"])
        end
      end

      describe "when invalid" do
        let(:item) { OpenStruct.new({ origin: "/not-in-the-list" }.merge(attributes[1])) }

        it "broadcasts :invalid and does not modifiy the config options" do
          expect { subject.call }.to broadcast(:invalid)

          items = AwesomeConfig.find_by(organization:, var: :custom_redirects).value
          expect(items).to be_a(Hash)
          expect(items.count).to eq(2)
        end
      end
    end
  end
end
