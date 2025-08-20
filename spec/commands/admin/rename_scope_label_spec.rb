# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe RenameScopeLabel do
      subject { described_class.new(params, organization) }

      let(:organization) { create(:organization) }
      let(:context) do
        {
          current_user: create(:user, organization:),
          current_organization: organization,
          setting: config
        }
      end
      let(:config) { create(:awesome_config, organization:, var: attribute, value:) }
      let!(:another_config) { create(:awesome_config, var: attribute, value:) }
      let!(:constraint) { create(:config_constraint, awesome_config: config, settings: { "test" => 1 }) }
      let!(:scoped_config) { create(:awesome_config, organization:, var: scope) }
      let!(:another_scoped_config) { create(:awesome_config, var: scope) }
      let(:value) do
        {
          key => "something"
        }
      end
      let(:after_value) do
        {
          text => "something"
        }
      end
      let(:params) do
        {
          text:,
          key:,
          attribute:,
          scope:
        }
      end
      let(:text) { "bar" }
      let(:key) { "foo" }
      let(:attribute) { "scoped_something" }
      let(:scope) { "#{attribute}_#{key}" }
      let(:after_scope) { "#{attribute}_#{text}" }

      it "broadcasts :ok and modifies the config options" do
        expect { subject.call }.to broadcast(:ok)

        expect(AwesomeConfig.find_by(organization:, var: attribute).value).to eq(after_value)
        expect(AwesomeConfig.find_by(organization:, var: after_scope).id).to eq(scoped_config.id)
        expect(AwesomeConfig.find_by(organization:, var: scope)).to be_nil
        expect(AwesomeConfig.find(another_config.id).value).to eq(value)
        expect(AwesomeConfig.find(another_scoped_config.id).var).to eq(scope)
      end

      describe "when empty" do
        let(:text) { "  " }

        it "broadcasts :invalid and does not modify the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization:, var: attribute).value).to eq(value)
          expect(AwesomeConfig.find_by(organization:, var: scope).id).to eq(scoped_config.id)
          expect(AwesomeConfig.find_by(organization:, var: after_scope)).to be_nil
        end
      end

      describe "when key repeated" do
        let(:text) { "foo" }

        it "broadcasts :invalid and does not modify the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization:, var: attribute).value).to eq(value)
          expect(AwesomeConfig.find_by(organization:, var: scope).id).to eq(scoped_config.id)
        end
      end

      describe "when no config" do
        let(:config) { nil }
        let(:constraint) { nil }

        it "broadcasts :invalid and does not modify the config options" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      describe "when no scoped_config" do
        let(:scoped_config) { nil }

        it "broadcasts :invalid and does not modify the config options" do
          expect { subject.call }.to broadcast(:ok)
        end
      end
    end
  end
end
