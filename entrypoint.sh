#!/bin/bash

# Check all the gems are installed or fails.
bundle check
if [ $? -ne 0 ]; then
  echo "❌ Gems in Gemfile are not installed, aborting..."
  bundle install --jobs 4 --retry 3
else
  echo "✅ Gems in Gemfile are installed"
fi

decidim /module_app --path  /app --skip_spring --skip_gemfile --demo --locales="en,ca,es" --queue=sidekiq --recreate_db --seed_db --force-ssl false

cd /module_app

echo "🚀 $@"
exec "$@"