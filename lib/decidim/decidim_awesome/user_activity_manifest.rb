# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class UserActivityManifest
      include ActiveModel::Model
      include Decidim::AttributeObject::Model

      attribute :name, Symbol
      attribute :counter, Proc

      validates :name, presence: true
    end
  end
end
