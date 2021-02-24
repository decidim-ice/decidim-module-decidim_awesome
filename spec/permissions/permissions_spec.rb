# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe Permissions do
    subject { described_class.new(user, permission_action, context).permissions.allowed? }

    let(:organization) { create :organization }
    let(:user) { create :user, organization: organization }
    let(:context) do
      {
        current_organization: organization,
        awesome_config: config
      }
    end
    let(:config) do
      {
        allow_images_in_proposals: in_proposals,
        allow_images_in_small_editor: in_small,
        allow_images_in_full_editor: in_full,
        allow_images_in_markdown_editor: in_markdown
      }
    end
    let(:in_proposals) { true }
    let(:in_small) { true }
    let(:in_full) { true }
    let(:in_markdown) { true }
    let(:permission_action) { Decidim::PermissionAction.new(action) }
    let(:action) do
      { scope: :public, action: :create, subject: :editor_image }
    end

    context "when scope is admin" do
      let(:action) do
        { scope: :admin, action: :create, subject: :editor_image }
      end

      it_behaves_like "permission is not set"
    end

    context "when no user present" do
      let(:user) { nil }

      it_behaves_like "permission is not set"
    end

    context "when user is no an admin" do
      context "and images in proposals are allowed" do
        it { is_expected.to eq true }
      end

      context "and images in proposals are no allowed" do
        let(:in_proposals) { false }

        it_behaves_like "permission is not set"
      end
    end

    context "when user is an admin" do
      let(:user) { create :user, :admin, organization: organization }

      context "and images in proposals are allowed" do
        it { is_expected.to eq true }
      end

      context "and images in proposals are no allowed" do
        let(:in_proposals) { false }

        it { is_expected.to eq true }
      end

      context "and images are no allowed" do
        let(:in_proposals) { false }
        let(:in_small) { false }
        let(:in_full) { false }
        let(:in_markdown) { false }

        it_behaves_like "permission is not set"
      end
    end
  end
end
