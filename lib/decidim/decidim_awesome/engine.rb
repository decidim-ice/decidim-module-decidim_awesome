# frozen_string_literal: true

require "rails"
require "deface"
require "decidim/core"
require "decidim/decidim_awesome/awesome_helpers"
require "decidim/decidim_awesome/menu"

module Decidim
  module DecidimAwesome
    # This is the engine that runs on the public interface of decidim_awesome.
    class Engine < ::Rails::Engine
      include AwesomeHelpers

      isolate_namespace Decidim::DecidimAwesome

      routes do
        post :editor_images, to: "editor_images#create"
      end

      # Prepare a zone to create overrides
      # https://edgeguides.rubyonrails.org/engines.html#overriding-models-and-controllers
      # overrides
      config.to_prepare do
        # activate Decidim LayoutHelper for the overriden views
        ActiveSupport.on_load :action_controller do
          helper Decidim::LayoutHelper if respond_to?(:helper)
        end
        # Include additional helpers globally
        ActiveSupport.on_load(:action_view) { include Decidim::DecidimAwesome::AwesomeHelpers }
        # Also for cells
        Decidim::ViewModel.include(Decidim::DecidimAwesome::AwesomeHelpers)

        # Override EtiquetteValidator
        EtiquetteValidator.include(Decidim::DecidimAwesome::EtiquetteValidatorOverride) if DecidimAwesome.enabled?([:validate_title_max_caps_percent,
                                                                                                                    :validate_title_max_marks_together,
                                                                                                                    :validate_title_start_with_caps,
                                                                                                                    :validate_body_max_caps_percent,
                                                                                                                    :validate_body_max_marks_together,
                                                                                                                    :validate_body_start_with_caps])

        # Custom fields need to deal with several places
        if DecidimAwesome.enabled?([:proposal_custom_fields,
                                    :validate_title_min_length,
                                    :validate_title_max_caps_percent,
                                    :validate_title_max_marks_together,
                                    :validate_title_start_with_caps,
                                    :validate_body_min_length,
                                    :validate_body_max_caps_percent,
                                    :validate_body_max_marks_together,
                                    :validate_body_start_with_caps])
                                    Decidim::Proposals::ProposalPresenter.include(Decidim::DecidimAwesome::Proposals::ProposalPresenterOverride)
                                    Decidim::Proposals::ProposalWizardCreateStepForm.include(Decidim::DecidimAwesome::Proposals::ProposalWizardCreateStepFormOverride)
                                    Decidim::Proposals::Admin::ProposalForm.include(Decidim::DecidimAwesome::Admin::ProposalFormOverride)
          Decidim::Proposals::UpdateProposal.include(Decidim::DecidimAwesome::Proposals::UpdateProposalOverride)
          Decidim::Proposals::CreateProposal.include(Decidim::DecidimAwesome::Proposals::CreateProposalOverride)
        end

        # override user's admin property
        Decidim::User.include(Decidim::DecidimAwesome::UserOverride) if DecidimAwesome.enabled?(:scoped_admins)

        if DecidimAwesome.enabled?(:weighted_proposal_voting)
          # add vote weight to proposal vote
          Decidim::Proposals::ProposalVote.include(Decidim::DecidimAwesome::HasVoteWeight)
          # add vote weight cache to proposal
          Decidim::Proposals::Proposal.include(Decidim::DecidimAwesome::HasProposalExtraFields)
          Decidim::Proposals::ProposalType.include(Decidim::DecidimAwesome::ProposalTypeOverride)
          Decidim::Proposals::ProposalLCell.include(Decidim::DecidimAwesome::ProposalLCellOverride)
        end

        if DecidimAwesome.enabled?([:menu, :content_block_main_menu])
          Decidim::ContentBlocks::GlobalMenuCell.include(Decidim::DecidimAwesome::GlobalMenuCellOverride)
          Decidim::BreadcrumbHelper.include(Decidim::DecidimAwesome::BreadcrumbHelperOverride)
          Decidim::MenuPresenter.include(Decidim::DecidimAwesome::MenuPresenterOverride)
          Decidim::MenuItemPresenter.include(Decidim::DecidimAwesome::MenuItemPresenterOverride)
          Decidim::BreadcrumbRootMenuItemPresenter.include(Decidim::DecidimAwesome::BreadcrumbRootMenuItemPresenterOverride)
        end

        # Late registering of components to take into account initializer values
        DecidimAwesome.registered_components.each do |manifest, block|
          next if DecidimAwesome.disabled_components.include?(manifest)
          next if Decidim.find_component_manifest(manifest)

          Decidim.register_component(manifest, &block)
        end
      end

      initializer "decidim_decidim_awesome.overrides", after: "decidim.action_controller" do
        config.to_prepare do
          # Auto-insert some csp directives
          Decidim::ApplicationController.include(Decidim::DecidimAwesome::ContentSecurityPolicy)
          Decidim::Admin::ApplicationController.include(Decidim::DecidimAwesome::ContentSecurityPolicy)

          # redirect unauthorized scoped admins to allowed places or custom redirects if configured
          Decidim::ErrorsController.include(Decidim::DecidimAwesome::NotFoundRedirect) if DecidimAwesome.enabled?([:scoped_admins, :custom_redirects])

          # Custom fields need to deal with several places
          if DecidimAwesome.enabled?(:proposal_custom_fields)
            Decidim::Proposals::ApplicationHelper.include(Decidim::DecidimAwesome::Proposals::ApplicationHelperOverride)
            Decidim::AmendmentsHelper.include(Decidim::DecidimAwesome::AmendmentsHelperOverride)
            Decidim::Proposals::ProposalSerializer.include(Decidim::DecidimAwesome::ProposalSerializerDecorator)
          end

          if DecidimAwesome.enabled?(:weighted_proposal_voting)
            Decidim::Proposals::ProposalVotesController.include(Decidim::DecidimAwesome::Proposals::ProposalVotesControllerOverride)
          end

          Decidim::AmendmentsController.include(Decidim::DecidimAwesome::LimitPendingAmendments) if DecidimAwesome.enabled?(:allow_limiting_amendments)

          Decidim::Proposals::ProposalsController.include(Decidim::DecidimAwesome::Proposals::OrderableOverride) if DecidimAwesome.enabled?(:additional_proposal_sortings)
        end
      end

      initializer "decidim_decidim_awesome.middleware" do |app|
        app.config.middleware.insert_after Decidim::Middleware::CurrentOrganization, Decidim::DecidimAwesome::CurrentConfig
      end

      initializer "decidim_decidim_awesome.additional_proposal_options" do |_app|
        Decidim.component_registry.find(:proposals).tap do |component|
          component.settings(:global) do |settings|
            if DecidimAwesome.enabled?(:additional_proposal_sortings)
              settings.attribute(
                :default_sort_order,
                type: :select,
                default: "default",
                choices: -> { (POSSIBLE_SORT_ORDERS + DecidimAwesome.possible_additional_proposal_sortings).uniq }
              )
            end
            if DecidimAwesome.enabled?(:allow_limiting_amendments)
              DecidimAwesome.hash_append!(
                settings.attributes,
                :amendments_enabled,
                :limit_pending_amendments,
                Decidim::SettingsManifest::Attribute.new(type: :boolean, default: DecidimAwesome.allow_limiting_amendments)
              )
            end
          end
          if DecidimAwesome.enabled?(:additional_proposal_sortings)
            component.settings(:step) do |settings|
              settings.attribute(
                :default_sort_order,
                type: :select,
                include_blank: true,
                choices: -> { (POSSIBLE_SORT_ORDERS + DecidimAwesome.possible_additional_proposal_sortings).uniq }
              )
            end
          end
        end
        if DecidimAwesome.enabled?(:allow_limiting_amendments)
          Decidim.component_registry.find(:proposals).tap do |component|
            component.settings(:global) do |settings|
              settings.attribute :limit_pending_amendments, type: :boolean, default: DecidimAwesome.allow_limiting_amendments
            end
          end
        end
      end

      initializer "decidim_decidim_awesome.weighted_proposal_voting" do |_app|
        if DecidimAwesome.enabled?(:weighted_proposal_voting)
          # register available processors
          Decidim::DecidimAwesome.voting_registry.register(:voting_cards) do |voting|
            voting.show_vote_button_view = "decidim/decidim_awesome/voting/voting_cards/show_vote_button"
            # voting.show_votes_count_view = "decidim/decidim_awesome/voting/voting_cards/show_votes_count"
            voting.show_votes_count_view = "" # hide votes count if not needed (in this case is integrated in the show_vote_button_view)
            voting.proposal_metadata_cell = "decidim/decidim_awesome/voting/proposal_metadata"
            voting.weight_validator do |weight, context|
              allowed = [1, 2, 3]
              allowed << 0 if context[:proposal]&.component&.settings&.voting_cards_show_abstain
              weight.in? allowed
            end
          end

          Decidim::DecidimAwesome.voting_components&.each do |manifest|
            component = Decidim.component_registry.find(manifest)
            next unless component

            component.settings(:global) do |settings|
              DecidimAwesome.hash_append!(
                settings.attributes,
                :can_accumulate_supports_beyond_threshold,
                :awesome_voting_manifest,
                Decidim::SettingsManifest::Attribute.new(
                  type: :select,
                  default: "",
                  choices: -> { ["default"] + Decidim::DecidimAwesome.voting_registry.manifests.map(&:name) },
                  readonly: lambda { |context|
                    Decidim::Proposals::Proposal.where(component: context[:component]).where.not(proposal_votes_count: -Float::INFINITY..0).any?
                  }
                )
              )
              DecidimAwesome.hash_append!(
                settings.attributes,
                :awesome_voting_manifest,
                :voting_cards_box_title,
                Decidim::SettingsManifest::Attribute.new(type: :string, translated: true)
              )
              DecidimAwesome.hash_append!(
                settings.attributes,
                :voting_cards_box_title,
                :voting_cards_show_modal_help,
                Decidim::SettingsManifest::Attribute.new(type: :boolean, default: true)
              )
              DecidimAwesome.hash_append!(
                settings.attributes,
                :voting_cards_show_modal_help,
                :voting_cards_show_abstain,
                Decidim::SettingsManifest::Attribute.new(type: :boolean, default: false)
              )
              DecidimAwesome.hash_append!(
                settings.attributes,
                :voting_cards_show_abstain,
                :voting_cards_instructions,
                Decidim::SettingsManifest::Attribute.new(type: :text, translated: true, editor: true)
              )
            end
          end
        end
      end

      initializer "decidim_decidim_awesome.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      # Votings may override proposals cells, let's be sure to add these paths after the proposal component initializer
      initializer "decidim_decidim_awesome.add_cells_view_paths", before: "decidim_proposals.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::DecidimAwesome::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::DecidimAwesome::Engine.root}/app/views")
      end

      initializer "decidim_decidim_awesome.register_icons" do
        Decidim.icons.register(name: "editors-text", icon: "text", category: "system", description: "", engine: :decidim_awesome)
        Decidim.icons.register(name: "surveys", icon: "survey-line", category: "system", description: "", engine: :decidim_awesome)
        Decidim.icons.register(name: "brush", icon: "brush-line", category: "system", description: "", engine: :decidim_awesome)
        Decidim.icons.register(name: "layers", icon: "stack-line", category: "system", description: "", engine: :decidim_awesome)
        Decidim.icons.register(name: "pulse", icon: "pulse-line", category: "system", description: "", engine: :decidim_awesome)
        Decidim.icons.register(name: "fire", icon: "fire-line", category: "system", description: "", engine: :decidim_awesome)
        Decidim.icons.register(name: "line-chart-line", icon: "line-chart-line", category: "system", description: "", engine: :decidim_awesome)
      end
    end
  end
end
