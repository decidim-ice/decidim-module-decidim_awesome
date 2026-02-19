# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AwesomeProcessGroupsQuery
      def initialize(organization)
        @organization = organization
      end

      def results
        grouped_processes.map do |process|
          { process: process, status: status_for(process) }
        end
      end

      def active
        grouped_processes.active
      end

      def past
        grouped_processes.past
      end

      private

      attr_reader :organization

      def grouped_processes
        @grouped_processes ||= Decidim::ParticipatoryProcess
                               .where(organization: organization)
                               .published
                               .where.not(decidim_participatory_process_group_id: nil)
                               .order(weight: :asc, start_date: :desc)
      end

      def status_for(process)
        return "active" if process.active?
        return "past" if process.past?

        "active"
      end
    end
  end
end
