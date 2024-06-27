# frozen_string_literal: true

# Add to the "proposals" component an exporter that is not
# included in open-data to be able to export all private fields
# from the administration without exposing data to the frontend.
proposal_component = Decidim.find_component_manifest("proposals")
proposal_component.exports :awesome_private_proposals do |exports|
  exports.collection do |component_instance, user|
    space = component_instance.participatory_space

    collection = Decidim::Proposals::Proposal
                 .published
                 .not_hidden
                 .where(component: component_instance)
                 .includes(:scope, :category, :component)

    if space.user_roles(:valuator).where(user:).any?
      collection.with_valuation_assigned_to(user, space)
    else
      collection
    end
  end

  exports.include_in_open_data = false
  exports.serializer Decidim::DecidimAwesome::PrivateProposalSerializer
end
