# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class UsersAutoblocksScoresExporter
      BASIC_ATTRIBUTES = [:id, :name, :nickname, :about].freeze
      DATA_FILE_PATH = "tmp/block_users_scores.csv"

      attr_reader :users

      def initialize(users)
        @users = users
      end

      def export
        exporter = Decidim::Exporters::CSV.new(data)
        exported = exporter.export

        data_file_path = File.join(Rails.application.root, DATA_FILE_PATH)
        File.write(data_file_path, exported.read)

        data_file_path
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
