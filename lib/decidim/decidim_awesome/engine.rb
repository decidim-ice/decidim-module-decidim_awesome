# frozen_string_literal: true

require "rails"
require "deface"
require "decidim/core"
require "decidim/decidim_awesome/awesome_helpers"

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
        ActionView::Base.include(Decidim::DecidimAwesome::AwesomeHelpers)
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
          Decidim::Proposals::ProposalSerializer.include(Decidim::DecidimAwesome::ProposalSerializerOverride)
          Decidim::Proposals::ProposalType.include(Decidim::DecidimAwesome::ProposalTypeOverride)
          Decidim::Proposals::ProposalMCell.include(Decidim::DecidimAwesome::ProposalMCellOverride)
        end

        Decidim::MenuPresenter.include(Decidim::DecidimAwesome::MenuPresenterOverride)
        Decidim::MenuItemPresenter.include(Decidim::DecidimAwesome::MenuItemPresenterOverride)

        # Late registering of components to take into account initializer values
        DecidimAwesome.registered_components.each do |manifest, block|
          next if DecidimAwesome.disabled_components.include?(manifest)
          next if Decidim.find_component_manifest(manifest)

          Decidim.register_component(manifest, &block)
        end
      end

      initializer "decidim_decidim_awesome.overrides", after: "decidim.action_controller" do
        config.to_prepare do
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

          Decidim::Proposals::ProposalsController.include(Decidim::DecidimAwesome::Proposals::OrderableOverride) if DecidimAwesome.enabled?(:additional_proposal_sortings)
        end
      end

      initializer "decidim_decidim_awesome.middleware" do |app|
        app.config.middleware.insert_after Decidim::Middleware::CurrentOrganization, Decidim::DecidimAwesome::CurrentConfig
      end

      initializer "decidim_decidim_awesome.additional_proposal_sortings" do |_app|
        if DecidimAwesome.enabled?(:additional_proposal_sortings)
          Decidim.component_registry.find(:proposals).tap do |component|
            component.settings(:global) do |settings|
              settings.attribute :default_sort_order, type: :select, default: "default", choices: -> { ["default"] + DecidimAwesome.possible_additional_proposal_sortings }
            end
            component.settings(:step) do |settings|
              settings.attribute :default_sort_order, type: :select, include_blank: true, choices: -> { ["default"] + DecidimAwesome.possible_additional_proposal_sortings }
            end
          end
        end
      end

      initializer "decidim_decidim_awesome.weighted_proposal_voting" do |_app|
        if DecidimAwesome.enabled?(:weighted_proposal_voting)
          # register available processors
          Decidim::DecidimAwesome.voting_registry.register(:voting_cards) do |voting|
            voting.show_vote_button_view = "decidim/decidim_awesome/voting/voting_cards/show_vote_button"
            voting.show_votes_count_view = "decidim/decidim_awesome/voting/voting_cards/show_votes_count"
            voting.show_votes_count_view = "" # hide votes count if needed
            voting.proposal_m_cell_footer = "decidim/decidim_awesome/voting/voting_cards/proposal_m_cell_footer"
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
              settings.attribute :awesome_voting_manifest,
                                 type: :select,
                                 default: "",
                                 choices: -> { ["default"] + Decidim::DecidimAwesome.voting_registry.manifests.map(&:name) },
                                 readonly: lambda { |context|
                                   Decidim::Proposals::Proposal.where(component: context[:component]).where.not(proposal_votes_count: 0).any?
                                 }
              settings.attribute :voting_cards_box_title,
                                 type: :string,
                                 translated: true
              settings.attribute :voting_cards_show_modal_help,
                                 type: :boolean,
                                 default: true
              settings.attribute :voting_cards_show_abstain,
                                 type: :boolean,
                                 default: false
              settings.attribute :voting_cards_instructions,
                                 type: :text,
                                 translated: true,
                                 editor: true
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
    end
  end
end
