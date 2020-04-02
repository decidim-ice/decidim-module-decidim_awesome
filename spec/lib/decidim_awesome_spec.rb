# frozen_string_literal: true

require "spec_helper"
require "digest"

# This ensures that overwritten files are the expected ones by checking the expected checksum
module Decidim
  describe DecidimAwesome do
    # rubocop:disable Rails/DynamicFindBy
    admin = ::Gem::Specification.find_by_name("decidim-admin")
    core = ::Gem::Specification.find_by_name("decidim-core")
    proposals = ::Gem::Specification.find_by_name("decidim-proposals")
    # rubocop:enable Rails/DynamicFindBy

    files_md5 = {
      "#{admin.gem_dir}/app/views/layouts/decidim/admin/_header.html.erb" => "6f0c010b1dcf912be1b3e0ff9f156026",
      "#{core.gem_dir}/app/views/layouts/decidim/_head.html.erb" => "b261c55492d047ba730eed8b39be0304",
      "#{core.gem_dir}/app/assets/javascripts/decidim/editor.js.es6" => "797d0ec1c9e79453cf6718f82d2fdd27",
      "#{proposals.gem_dir}/app/presenters/decidim/proposals/proposal_presenter.rb" => "af098810b12cee97fddc2ee8fd405a54"
    }

    it "each file matches the expected checksum" do
      files_md5.each do |file, md5|
        expect(md5(file)).to eq md5
      end
    end

    def md5(file)
      Digest::MD5.hexdigest(File.read(file))
    end
  end
end
