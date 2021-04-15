# frozen_string_literal: true

# Body valitation are overriden with a custom html/xml structure to store
# the custom fields definition
class Decidim::Proposals::ProposalWizardCreateStepForm < Decidim::Form
  mimic :proposal

  attribute :title, String
  attribute :body, defined?(Decidim::Attributes::CleanString) ? Decidim::Attributes::CleanString : String
  attribute :body_template, String
  attribute :user_group_id, Integer

  validates :title, presence: true, etiquette: true
  validates :body, presence: true, etiquette: true, unless: ->(form) { form.override_validations? }
  validates :title, length: { in: 15..150 }
  validates :body, proposal_length: {
    minimum: 15,
    maximum: ->(record) { record.component.settings.proposal_length }
  }, unless: ->(form) { form.override_validations? }

  validate :body_is_not_bare_template, unless: ->(form) { form.override_validations? }

  alias component current_component

  def map_model(model)
    self.user_group_id = model.user_groups.first&.id
    return unless model.categorization

    self.category_id = model.categorization.decidim_category_id
  end

  def override_validations?
    return false if context.current_component.settings.participatory_texts_enabled

    custom_fields.present?
  end

  private

  def body_is_not_bare_template
    return if body_template.blank?

    errors.add(:body, :cant_be_equal_to_template) if body.presence == body_template.presence
  end

  def custom_fields
    awesome_config = Decidim::DecidimAwesome::Config.new(context.current_organization)
    awesome_config.context_from_component(context.current_component)
    awesome_config.collect_sub_configs("proposal_custom_field")
  end
end
