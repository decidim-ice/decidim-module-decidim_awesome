# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CreateScopedStyle do
      subject { described_class.new(organization) }

      let(:organization) { create(:organization) }

      describe "when valid" do
        it "broadcasts :ok and creates a Hash" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization: organization, var: :scoped_styles).value).to be_a(Hash)
          expect(AwesomeConfig.find_by(organization: organization, var: :scoped_styles).value.keys.count).to eq(1)
        end

        context "and entries already exist" do
          let!(:config) { create :awesome_config, organization: organization, var: :scoped_styles, value: { test: ".body {background: red;}" } }

          it "do not removes previsous entries" do
            expect { subject.call }.to broadcast(:ok)

            expect(AwesomeConfig.find_by(organization: organization, var: :scoped_styles).value.keys.count).to eq(2)
            expect(AwesomeConfig.find_by(organization: organization, var: :scoped_styles).value.values).to include(".body {background: red;}")
          end
        end
      end

      describe "when invalid" do
        subject { described_class.new("nonsense") }

        it "broadcasts :invalid and does not modifiy the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization: organization, var: :scoped_styles)).to eq(nil)
        end
      end
    end
  end
end
