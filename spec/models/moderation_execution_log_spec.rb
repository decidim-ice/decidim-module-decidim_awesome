# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ModerationExecutionLog do
    subject { moderation }

    let(:moderation) { build(:awesome_moderation_execution_log) }

    it { is_expected.to be_valid }
  end
end
