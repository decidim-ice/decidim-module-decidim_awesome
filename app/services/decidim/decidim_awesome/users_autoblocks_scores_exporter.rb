# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class UsersAutoblocksScoresExporter
      BASIC_ATTRIBUTES = [:id, :name, :nickname, :about].freeze

      attr_reader :users

      def initialize(users)
        @users = users
      end

      def export
        exporter = Decidim::Exporters::CSV.new(data)
        exported = exporter.export

        # TODO: Use a file in a more stable location to reuse it
        tmpfile = Tempfile.new("user_autoblocks_scores")
        tmpfile.write(exported.read)
        # Do not delete the file when the reference is deleted
        ObjectSpace.undefine_finalizer(tmpfile)
        tmpfile.close

        tmpfile.path
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
