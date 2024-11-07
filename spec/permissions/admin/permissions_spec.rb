# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome::Admin
  describe Permissions do
    subject { described_class.new(user, permission_action, context).permissions.allowed? }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization: organization) }
    let(:context) do
      {
        current_organization: organization,
        private_data: private_data,
        global: global,
        handler: handler
      }
    end
    let(:handler) { nil }
    let(:global) { nil }
    let(:private_data) { nil }
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

          it_behaves_like "permission is not set"
        end
      end
    end

    context "when is scoped admin accessing" do
      let(:user) { create(:user, organization: organization) }

      before do
        allow(user).to receive_messages(admin: true, admin?: true)
      end

      it_behaves_like "permission is not set"
    end

    context "when accessing admin_accountability" do
      let(:feature) { :admin_accountability }
      let(:status) { [:participatory_space_roles, :admin_roles] }

      before do
        allow(Decidim::DecidimAwesome.config).to receive(feature).and_return(status)
      end

      it { is_expected.to be true }

      context "when admin_accountability does not include participatory_space_roles" do
        let(:status) { [:admin_roles] }

        it_behaves_like "permission is not set"
      end

      context "when admin_accountability is global" do
        let(:global) { true }

        it { is_expected.to be true }

        context "when admin_accountability does not include admin_roles" do
          let(:status) { [:participatory_space_roles] }

          it_behaves_like "permission is not set"
        end
      end

      context "when admin_accountability is disabled" do
        let(:status) { :disabled }

        it_behaves_like "permission is not set"
      end
    end

    context "when accessing private_data" do
      let(:feature) { :private_data }
      let(:status) { true }

      before do
        allow(Decidim::DecidimAwesome.config).to receive(:proposal_private_custom_fields).and_return(status)
      end

      it { expect(subject).to be true }

      context "when proposal private fields is disabled" do
        let(:status) { :disabled }

        it_behaves_like "permission is not set"
      end

      context "when private_data is present" do
        let(:private_data) { double(destroyable?: true) }

        it { is_expected.to be true }

        context "when private_data is not destroyable" do
          let(:private_data) { double(destroyable?: false) }

          it_behaves_like "permission is not set"
        end
      end
    end

    context "when accessing admins_available_authorizations" do
      let(:feature) { :admins_available_authorizations }
      let(:handler) { "dummy_authorization_handler" }
      let(:awesome_handler) { "dummy_authorization_handler" }
      let!(:awesome_config) { create(:awesome_config, organization: organization, var: :admins_available_authorizations, value: [awesome_handler]) }

      context "when organization has no handlers" do
        it_behaves_like "permission is not set"
      end

      context "when organization has handlers" do
        let(:organization) { create(:organization, available_authorizations: [handler]) }

        it { is_expected.to be true }

        context "and awesome_config does not exist" do
          let(:awesome_config) { nil }

          it_behaves_like "permission is not set"

          context "and feature is disabled" do
            let(:status) { :disabled }

            it_behaves_like "permission is not set"
          end
        end

        context "and awesome_config is not registered" do
          let(:awesome_handler) { "another_dummy_authorization_handler" }

          it_behaves_like "permission is not set"
        end
      end
    end
  end
end
