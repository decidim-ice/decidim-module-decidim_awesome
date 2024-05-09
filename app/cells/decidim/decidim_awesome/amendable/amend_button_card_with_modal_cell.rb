# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Amendable
      class AmendButtonCardWithModalCell < Decidim::ViewModel
        delegate :current_user, to: :controller, prefix: false

        def model_name
          model.model_name.human
        end

        def current_component
          model.component
        end

        def new_amend_path
          decidim.new_amend_path(amendable_gid: model.to_sgid.to_s)
        end
      end
    end
  end
end
