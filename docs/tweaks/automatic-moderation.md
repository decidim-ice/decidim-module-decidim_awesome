# Automatic moderation

## Tweaks

### 1.1 Moderation of participatory content

Allows admins to define rules that automatically moderate content based on configurable criteria.
Rules can trigger actions like hiding content, flagging for review, or notifying moderators based on object type, content patterns, etc.

### Admin description

Enables admins to manage automatic moderation of content through the platform based on simple rules. This helps maintain content quality and community standards without manual review of every item.

Rules allow to automatically hide content that matches certain criteria (e.g., contains banned words, posted by new users, etc.) or flag it for moderator review. This can reduce the workload on moderators and improve the user experience by quickly removing harmful content.


### Technical area



- **Admin visibility:** Enabled (admins see a new "Automatic Moderation" section in admin panel with rule management UI)
- **Default behavior:** Enabled by default; there are no predefined rules.
- **Admin control:** Yes. Admins can generate new rules, enable them or disable wheen needed.

\`\`\`ruby
# config/initializers/awesome_defaults.rb
Decidim::DecidimAwesome.configure do |config|
  config.auto_moderation_rules = true  # default: true
end
\`\`\`