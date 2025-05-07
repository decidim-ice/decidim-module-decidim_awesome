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
        @data ||= begin
          accumulated_data = []

          users.find_in_batches do |group|
            group.each do |user|
              attributes = BASIC_ATTRIBUTES.index_with { |attr| user.send(attr) }
              attributes.merge!(Decidim::DecidimAwesome::UserAutoblockScoresPresenter.new(user).scores)

              accumulated_data << attributes
            end
          end

          accumulated_data
        end
      end

      def scores
        @scores ||= begin
          accumulated_data = {}

          users.find_in_batches do |group|
            group.each_with_object(accumulated_data) { |user, data| data[user.id] = Decidim::DecidimAwesome::UserAutoblockScoresPresenter.new(user).scores }
          end

          accumulated_data
        end
      end
    end
  end
end
