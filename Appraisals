appraise "decidim-0.22" do
  gem "decidim", "0.22"
  gem "decidim-admin", "0.22"
  gem "decidim-core", "0.22"
  gem "puma", ">= 4.3"
  group :development, :test do
    gem "decidim-dev", "0.22"
  end
end

appraise "decidim-0.23" do
  gem "decidim", "0.23"
  gem "decidim-admin", "0.23"
  gem "decidim-core", "0.23"
  gem "puma", ">= 4.3.5"
  group :development, :test do
    gem "decidim-dev", "0.23"
  end
end

appraise "decidim-0.23.1" do
  gem "decidim", git: "https://github.com/decidim/decidim", branch: "release/0.23-stable"
  gem "decidim-admin", git: "https://github.com/decidim/decidim", branch: "release/0.23-stable"
  gem "decidim-core", git: "https://github.com/decidim/decidim", branch: "release/0.23-stable"
  gem "puma", ">= 4.3.5"
  group :development, :test do
    gem "decidim-dev", git: "https://github.com/decidim/decidim", branch: "release/0.23-stable"
  end
end

