# frozen_string_literal: true

# Body valitation are overriden with a custom html/xml structure to store
# the custom fields definition
Decidim::Proposals::ProposalWizardCreateStepForm.class_eval do
  # remove body validation if custom_styles apply
  def before_validation
    @@original_validators ||= _validators.deep_dup

    if custom_fields.present?
      _validators.delete(:body)
      _validators.each { |_key, validators| validators.each { |val| val.attributes.delete :body } }
    else
      _validators = @@original_validators
    end
  end

  def custom_fields
    return @custom_fields if @custom_fields.present?

    @awesome_config = Decidim::DecidimAwesome::Config.new(context.current_organization)
    @awesome_config.context_from_component(context.current_component)
    @custom_fields = @awesome_config.collect_sub_configs("proposal_custom_field")
  end
end
