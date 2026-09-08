#!/bin/bash

# Check all the gems are installed or fails.

if [ bundle --check ]; then
  echo "✅ All gems are installed"
else
  echo "❌ Some gems are missing, installing..."
  bundle install
fi

decidim /module_app --path  /app --skip_spring --skip_gemfile --demo --locales="en,ca,es" --queue=sidekiq --recreate_db --seed_db --force-ssl false

cd /module_app

echo "🚀 $@"
exec "$@"