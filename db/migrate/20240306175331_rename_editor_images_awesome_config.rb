# frozen_string_literal: true

class RenameEditorImagesAwesomeConfig < ActiveRecord::Migration[6.1]
  class AwesomeConfig < ApplicationRecord
    self.table_name = :decidim_awesome_config
  end

  def change
    # rubocop:disable Rails/SkipsModelValidations
    AwesomeConfig.where(var: :allow_images_in_full_editor).update_all(var: :allow_images_in_editors)
    AwesomeConfig.where(var: :allow_images_in_small_editor).destroy_all
    # rubocop:enable Rails/SkipsModelValidations
  end
end
