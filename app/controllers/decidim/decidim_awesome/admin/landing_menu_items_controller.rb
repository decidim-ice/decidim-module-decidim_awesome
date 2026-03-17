# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class LandingMenuItemsController < DecidimAwesome::Admin::ApplicationController
        layout false

        before_action :validate_content_block_id

        def new
          @form = form(LandingMenuItemForm).from_params(default_params)
          @available_anchors = ContentBlocks::LandingMenuFormCell.available_anchors_for(content_block)
        end

        def create
          @form = form(LandingMenuItemForm).from_params(params)

          unless @form.valid?
            @available_anchors = ContentBlocks::LandingMenuFormCell.available_anchors_for(content_block)
            return render :new, status: :unprocessable_entity
          end

          items = current_items
          items << form_to_hash(@form)
          save_items!(items)

          head :ok
        end

        def show
          item = current_items[item_index]
          return head(:not_found) unless item

          @form = form(LandingMenuItemForm).from_params(item_to_form_params(item))
        end

        def update
          @form = form(LandingMenuItemForm).from_params(params)

          items = current_items
          return head(:not_found) unless items[item_index]
          return render :show, status: :unprocessable_entity unless @form.valid?

          items[item_index] = form_to_hash(@form)
          save_items!(items)

          head :ok
        end

        def destroy
          items = current_items
          return head(:not_found) unless items[item_index]

          items.delete_at(item_index)
          save_items!(items)

          redirect_back fallback_location: decidim_admin.root_path
        end

        def toggle_visible
          items = current_items
          return head(:not_found) unless items[item_index]

          items[item_index]["visible"] = !items[item_index].fetch("visible", true)
          save_items!(items)

          redirect_back fallback_location: decidim_admin.root_path
        end

        def reorder
          return head(:bad_request) unless params[:order_ids].is_a?(Array)

          items = current_items
          order = params[:order_ids].map(&:to_i)
          return head(:bad_request) unless order.sort == (0...items.length).to_a

          reordered = order.map { |index| items[index] }
          save_items!(reordered)

          head :ok
        end

        private

        def validate_content_block_id
          head(:bad_request) if params[:content_block_id].blank?
        end

        def content_block
          @content_block ||= Decidim::ContentBlock.where(organization: current_organization).find(params[:content_block_id])
        end

        def item_index
          params[:id].to_i
        end

        def current_items
          items = MenuItemsParser.parse_json(content_block.settings.menu_items)
          return items if items.present? || content_block.settings.menu_items.blank?

          raise "Corrupted menu_items data in content block #{content_block.id}"
        end

        def save_items!(items)
          settings = content_block.settings.attributes.dup
          settings["menu_items"] = items.to_json
          content_block.settings = settings
          content_block.save!
        end

        def form_to_hash(menu_form)
          { "name" => menu_form.name, "url" => menu_form.url, "visible" => menu_form.visible }
        end

        def item_to_form_params(item)
          return {} if item.blank?

          params_hash = { "url" => item["url"], "visible" => item.fetch("visible", true) }
          (item["name"] || {}).each do |locale, value|
            params_hash["name_#{locale}"] = value
          end
          params_hash
        end

        def default_params
          params_hash = { "url" => "", "visible" => true }
          current_organization.available_locales.each do |locale|
            params_hash["name_#{locale}"] = ""
          end
          params_hash
        end
      end
    end
  end
end
