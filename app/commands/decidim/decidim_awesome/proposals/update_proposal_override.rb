module Decidim
  module DecidimAwesome
    module Proposals
      module UpdateProposalOverride
        extend ActiveSupport::Concern

        included do
          private
          def attributes
            {
              title: {
                I18n.locale => title_with_hashtags
              },
              body: {
                I18n.locale => body_with_hashtags
              },
              private_body: form.private_body,
              category: form.category,
              scope: form.scope,
              address: form.address,
              latitude: form.latitude,
              longitude: form.longitude
            }
          end

        end
      end
    end
  end
end
