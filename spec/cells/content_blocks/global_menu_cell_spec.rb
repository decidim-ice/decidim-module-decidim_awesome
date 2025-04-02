# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentBlocks::GlobalMenuCell, type: :cell do
    subject { block_cell.call }
    let(:block_cell) { cell(content_block.cell, content_block) }
    let(:organization) { create(:organization) }
    let(:content_block) { create(:content_block, organization:, manifest_name: :global_menu, scope_name: :homepage) }
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:assembly) { create(:assembly, organization:) }
    let!(:config) { create(:awesome_config, organization:, var: :home_content_block_menu, value: menu) }
    let!(:authorization) { nil }
    let(:menu) { [overridden, added] }
    let(:original_visibility) { "default" }
    let(:visibility) { "default" }
    let(:initial_overridden) do
      {
        "url" => "/processes",
        "label" => {
          "en" => "Mastering projects"
        },
        "position" => 10,
        "visibility" => original_visibility
      }
    end
    let(:overridden) do
      initial_overridden.merge("visibility" => visibility)
    end
    let(:added) do
      {
        "url" => "http://external.blog",
        "label" => {
          "en" => "Blog"
        },
        "position" => 9
      }
    end
    let(:awesome_config) do
      {
        home_content_block_menu: [
          overridden,
          added
        ]
      }
    end
    let(:original_cache_hash) do
      [
        "decidim/content_blocks/global_menu",
        organization.cache_key_with_version,
        I18n.locale,
        [
          initial_overridden,
          added
        ].to_s,
        *extra_cache_keys
      ].join(Decidim.cache_key_separator)
    end
    let(:extra_cache_keys) { [] }
    let(:cache_hash) do
      block_cell.send :cache_hash
    end

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
      allow(block_cell).to receive(:awesome_config).and_return(awesome_config)
      block_cell.instance_variable_set(:@decidim_awesome_cache_hash, nil)
    end

    it "shows the menu" do
      expect(subject).to have_css("#home__menu")
      expect(subject).to have_content("Mastering projects")
      expect(subject).to have_content("Blog")
      expect(subject).to have_content("Assemblies")
      expect(subject).to have_no_content("Processes")
    end

    it "matches the cache hash" do
      expect(cache_hash).to eq(original_cache_hash)
    end

    context "when visibility hidden" do
      let(:visibility) { "hidden" }

      it "shows the menu" do
        expect(subject).to have_css("#home__menu")
        expect(subject).to have_no_content("Mastering projects")
        expect(subject).to have_content("Blog")
        expect(subject).to have_content("Assemblies")
        expect(subject).to have_no_content("Processes")
      end

      it "changes the cache hash" do
        expect(cache_hash).not_to eq(original_cache_hash)
      end
    end

    context "when visibility logged" do
      let(:visibility) { "logged" }

      it "shows the menu" do
        expect(subject).to have_css("#home__menu")
        expect(subject).to have_no_content("Mastering projects")
        expect(subject).to have_content("Blog")
        expect(subject).to have_content("Assemblies")
        expect(subject).to have_no_content("Processes")
      end

      it "changes the cache hash" do
        expect(cache_hash).not_to eq(original_cache_hash)
      end

      context "when the user is logged" do
        let(:user) { create(:user, :confirmed, organization:) }
        let(:original_visibility) { "logged" }
        let(:extra_cache_keys) { [user.id] }

        before do
          allow(controller).to receive(:current_user).and_return(user)
        end

        it "shows the menu" do
          expect(subject).to have_css("#home__menu")
          expect(subject).to have_content("Mastering projects")
          expect(subject).to have_content("Blog")
          expect(subject).to have_content("Assemblies")
          expect(subject).to have_no_content("Processes")
        end

        it "changes the cache hash" do
          expect(cache_hash).not_to eq(original_cache_hash)
        end
      end
    end

    context "when visibility non_logged" do
      let(:visibility) { "non_logged" }

      it "shows the menu" do
        expect(subject).to have_css("#home__menu")
        expect(subject).to have_content("Mastering projects")
        expect(subject).to have_content("Blog")
        expect(subject).to have_content("Assemblies")
        expect(subject).to have_no_content("Processes")
      end

      it "changes the cache hash" do
        expect(cache_hash).not_to eq(original_cache_hash)
      end

      context "when the user is logged" do
        let(:user) { create(:user, :confirmed, organization:) }
        let(:original_visibility) { "non_logged" }
        let(:extra_cache_keys) { [user.id] }

        before do
          allow(controller).to receive(:current_user).and_return(user)
        end

        it "shows the menu" do
          expect(subject).to have_css("#home__menu")
          expect(subject).to have_no_content("Mastering projects")
          expect(subject).to have_content("Blog")
          expect(subject).to have_content("Assemblies")
          expect(subject).to have_no_content("Processes")
        end

        it "changes the cache hash" do
          expect(cache_hash).not_to eq(original_cache_hash)
        end
      end
    end

    context "when visibility verified_user" do
      let(:visibility) { "verified_user" }

      it "shows the menu" do
        expect(subject).to have_css("#home__menu")
        expect(subject).to have_no_content("Mastering projects")
        expect(subject).to have_content("Blog")
        expect(subject).to have_content("Assemblies")
        expect(subject).to have_no_content("Processes")
      end

      it "changes the cache hash" do
        expect(cache_hash).not_to eq(original_cache_hash)
      end

      context "when the user is logged" do
        let(:user) { create(:user, :confirmed, organization:) }
        let(:original_visibility) { "verified_user" }
        let(:extra_cache_keys) { [user.id] }

        before do
          allow(controller).to receive(:current_user).and_return(user)
        end

        it "shows the menu" do
          expect(subject).to have_css("#home__menu")
          expect(subject).to have_no_content("Mastering projects")
          expect(subject).to have_content("Blog")
          expect(subject).to have_content("Assemblies")
          expect(subject).to have_no_content("Processes")
        end

        it "changes the cache hash" do
          expect(cache_hash).not_to eq(original_cache_hash)
        end

        context "and the user is verified" do
          let!(:authorization) { create(:authorization, :granted, user:, name: "dummy_authorization_handler") }

          it "shows the menu" do
            expect(subject).to have_css("#home__menu")
            expect(subject).to have_content("Mastering projects")
            expect(subject).to have_content("Blog")
            expect(subject).to have_content("Assemblies")
            expect(subject).to have_no_content("Processes")
          end

          it "changes the cache hash" do
            expect(cache_hash).not_to eq(original_cache_hash)
          end
        end

        context "and the authorization is pending" do
          let!(:authorization) { create(:authorization, :pending, user:, name: "dummy_authorization_handler") }

          it "shows the menu" do
            expect(subject).to have_css("#home__menu")
            expect(subject).to have_no_content("Mastering projects")
            expect(subject).to have_content("Blog")
            expect(subject).to have_content("Assemblies")
            expect(subject).to have_no_content("Processes")
          end

          it "changes the cache hash" do
            expect(cache_hash).not_to eq(original_cache_hash)
          end
        end
      end
    end
  end
end
