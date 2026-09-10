#!/bin/bash

# Check all the gems are installed or fails.
bundle check
if [ $? -ne 0 ]; then
  echo "❌ Gems in Gemfile are not installed, installing..."
  bundle install --jobs 4 --retry 3
else
  echo "✅ Gems in Gemfile are installed"
fi

echo "Creating new Decidim app in /module_app"
#decidim /module_app --path .. --skip_spring --demo --locales="en,ca,es" --queue=sidekiq --recreate_db --seed_db --force-ssl=false
bundle exec rake development_app

cd development_app

bin/rails assets:precompile

echo "🚀 $@"
exec "$@"