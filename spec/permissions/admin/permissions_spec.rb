# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome::Admin
  describe Permissions do
    subject { described_class.new(user, permission_action, context).permissions.allowed? }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:context) do
      {
        current_organization: organization
      }
    end
    let(:feature) { :allow_images_in_full_editor }
    let(:action) do
      { scope: :admin, action: :edit_config, subject: feature }
    end
    let(:permission_action) { Decidim::PermissionAction.new(**action) }

    before do
      allow(Decidim::DecidimAwesome.config).to receive(feature).and_return(true)
    end

    context "when scope is not admin" do
      let(:action) do
        { scope: :foo, action: :edit_config, subject: :some_feature }
      end

      it_behaves_like "permission is not set"
    end

    context "when permission action is not edit_config" do
      let(:action) do
        { scope: :admin, action: :another_action, subject: :some_feature }
      end

      it_behaves_like "permission is not set"
    end

    context "when accessing awesome config variables" do
      context "and config is enabled" do
        it { is_expected.to be true }
      end

      Decidim::DecidimAwesome.config.keys.each do |key|
        context "and config [#{key}] is disabled" do
          let(:feature) { key }

          before do
            allow(Decidim::DecidimAwesome.config).to receive(key).and_return(:disabled)
          end

          it { is_expected.to be false }
        end
      end
    end

    context "when is scoped admin accessing" do
      let(:user) { create(:user, organization:) }

      before do
        allow(user).to receive_messages(admin: true, admin?: true)
      end

      it_behaves_like "permission is not set"
    end

    context "when accessing admin_accountability" do
      let(:feature) { :admin_accountability }
      let(:status) { true }

      before do
        allow(Decidim::DecidimAwesome.config).to receive(feature).and_return(status)
      end

      it { is_expected.to be true }

      context "when admin_accountability is disabled" do
        let(:status) { :disabled }

        it { is_expected.to be false }
      end
    end
  end
end
