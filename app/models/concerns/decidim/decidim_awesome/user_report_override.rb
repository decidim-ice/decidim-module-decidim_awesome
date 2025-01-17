# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module UserReportOverride
      extend ActiveSupport::Concern

      old_reasons = Decidim::UserReport::REASONS
      Decidim::UserReport.const_set("REASONS", old_reasons + ["autoblock"])

      # included do
      # validates :reason, inclusion: { in: (old_reasons + ["huhuhu"]) }
      # end
    end
  end
end
