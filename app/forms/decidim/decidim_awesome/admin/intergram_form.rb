# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # A form object used to configure the endpoint.
      #
      class IntergramForm < Decidim::Form
        attribute :chat_id, String
        attribute :require_login, Boolean
        attribute :color, String
        attribute :use_floating_button, Boolean
        attribute :title_open, String
        attribute :title_closed, String
        attribute :intro_message, String
        attribute :auto_response, String
        attribute :auto_no_response, String
      end
    end
  end
end
