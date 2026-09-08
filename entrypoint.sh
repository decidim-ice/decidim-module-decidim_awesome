#!/bin/bash

# Check all the gems are installed or fails.
bundle install

PR_NUMBER=${PR_NUMBER:-"local"}

decidim /module_app --path  /app --skip_spring --demo --locales="en,ca,es" --queue=sidekiq --app_name "${PR_NUMBER}_decidim" --recreate_db --seed_db

cd /module_app

echo "🚀 $@"
exec "$@"