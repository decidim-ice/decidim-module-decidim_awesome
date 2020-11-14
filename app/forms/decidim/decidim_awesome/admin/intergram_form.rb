# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # A form object used to configure the endpoint.
      #
      class IntergramForm < Decidim::Form
        attribute :chat_id, String
        attribute :require_login, Boolean
      end
    end
  end
end
