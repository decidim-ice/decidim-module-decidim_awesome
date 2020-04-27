appraise "decidim-0.20" do
  gem "decidim", "0.20"
  gem "decidim-admin", "0.20"
  gem "decidim-core", "0.20"
  gem "puma", "~> 3.12.2"
  group :development, :test do
    gem "decidim-dev", "0.20"
  end
  group :test do
    # Workaround for cc-test-reporter with SimpleCov 0.18.
    # Stop upgrading SimpleCov until the following issue will be resolved.
    # https://github.com/codeclimate/test-reporter/issues/418
    gem "simplecov", "~> 0.10", "< 0.18"
  end
end

appraise "decidim-0.21" do
  gem "decidim", "0.21"
  gem "decidim-admin", "0.21"
  gem "decidim-core", "0.21"
  gem "puma", ">= 4.3"
  group :development, :test do
    gem "decidim-dev", "0.21"
  end
end
