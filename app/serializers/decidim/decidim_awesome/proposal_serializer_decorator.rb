module Decidim
    module DecidimAwesome
        module ProposalSerializerDecorator
            extend ActiveSupport::Concern
            included do |base|
                base.include(AwesomeHelpers)
                alias_method :decidim_original_serialize, :serialize

                def serialize
                    serialized_proposal = decidim_original_serialize
                    serialize_custom_fields(serialized_proposal) 
                end

                def awesome_config_instance
                    return @config if @config
                    @config = Config.new(proposal.organization)
                    @config.context_from_component(proposal.component)
                    @config
                end

                private
                    def serialize_custom_fields(payload)
                        custom_fields = CustomFields.new(awesome_proposal_custom_fields)
                        private_custom_fields = CustomFields.new(awesome_private_proposal_custom_fields)
                        proposal.body.keys.each do |locale|
                            unless custom_fields.blank?
                                custom_fields.apply_xml(proposal.body[locale])
                                custom_fields.fields.each do |field|
                                    if field["label"] && field["name"]
                                        payload["body/#{field["label"].parameterize}/#{locale}".to_sym] = field["userData"]
                                    end
                                end
                            end
                            unless private_custom_fields.blank?
                                private_custom_fields.apply_xml(proposal.private_body)
                                private_custom_fields.fields.each do |field|
                                    if field["label"] && field["name"]
                                        payload["secret/#{field["label"].parameterize}".to_sym] = field["userData"]
                                    end
                                end
                            end
                        end
                        payload
                    end

            end
        end
    end
end
