# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class UsersAutoblocksScoresExporter
      BASIC_ATTRIBUTES = [:id, :name, :nickname, :about].freeze
      DATA_FILE_KEY = "decidim-awesome/block_users_scores.csv"

      attr_reader :users, :organization

      def initialize(organization, users)
        @organization = organization
        @users = users
      end

      def export
        exporter = Decidim::Exporters::CSV.new(data)
        exported = exporter.export

        filename = "#{organization.id}-#{DATA_FILE_KEY}"

        if (previous_files = ActiveStorage::Blob.where(filename:)).exists?
          previous_files.each(&:purge_later)
        end
        ActiveStorage::Blob.create_and_upload!(io: StringIO.new(exported.read), filename:)
      end

      def data
        @data ||= users.map do |user|
          attributes = BASIC_ATTRIBUTES.index_with { |attr| user.send(attr) }
          attributes.merge!(Decidim::DecidimAwesome::UserAutoblockScoresPresenter.new(user).scores)
        end
      end

      def scores
        @scores ||= users.each_with_object({}) { |user, data| data[user.id] = Decidim::DecidimAwesome::UserAutoblockScoresPresenter.new(user).scores }
      end
    end
  end
end
