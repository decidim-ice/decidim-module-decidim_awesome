# Pull Request Review Instructions

## Documentation Requirements

### Mandatory Documentation Updates

When reviewing pull requests, **always verify** that documentation has been updated for:

1. **New Features or Tweaks**
   - Any new tweak MUST have documentation added to the appropriate category file in `docs/tweaks/`
   - Choose the correct category based on the feature's primary purpose:
     - `editor-content.md` - Editor and content creation tweaks (Section 1.x)
     - `proposals-participation.md` - Proposals and participation tweaks (Section 2.x)
     - `admin-governance.md` - Admin governance and accountability tweaks (Section 3.x)
     - `ui-theming-navigation.md` - UI, theming and navigation tweaks (Section 4.x)
     - `forms-surveys-verifications.md` - Forms, surveys and verifications tweaks (Section 5.x)
     - `components-integrations.md` - Components and integrations tweaks (Section 6.x)
   - If the feature is cross-cutting/transversal, consider adding to `global-mechanisms.md`

2. **Configuration Changes**
   - Any new `config_accessor` in `lib/decidim/decidim_awesome/awesome.rb` requires documentation
   - Initializer examples must be provided showing all three states where applicable:
     - `true` = enabled by default globally (admins can restrict to specific scopes)
     - `false` = disabled by default (admins CAN enable per-scope)
     - `:disabled` = completely removed, hidden from admins

3. **API Changes**
   - GraphQL schema additions require documentation updates
   - New REST endpoints or parameters must be documented

### Documentation Template for New Tweaks

When suggesting documentation for a new tweak, use this structure:

```markdown
### X.Y Tweak Title

Brief one-line description of what the tweak does.

#### Admin description

- What problem does this solve for admins/organizations?
- Key concerns admins should be aware of
- Recommendations for best practices

#### Technical area

- **Admin visibility:** Enabled/Disabled (describe what admins see)
- **Default behavior:** Enabled/Disabled by default (explain default state)
- **Admin control:** Yes/No (explain admin configuration options)

\`\`\`ruby
# config/initializers/awesome_defaults.rb
Decidim::DecidimAwesome.configure do |config|
  # Provide realistic configuration example with comments
  config.feature_name = value  # default: value
  
  # Show :disabled option if applicable:
  # config.feature_name = :disabled
end
\`\`\`

- **Additional technical details:** Performance, dependencies, caveats, prerequisites
- **Cross-references:** Link to related tweaks using new numbering (e.g., "Works with Tweak 2.1")

![Description](../../examples/screenshot.png)
```

### Auto-Suggestion Guidelines

When reviewing PRs that add features WITHOUT documentation updates:

1. **Request Changes** with a comment like:
   ```
   This PR adds a new feature/tweak but is missing documentation updates.
   
   Please add documentation to `docs/tweaks/[appropriate-category].md` following the template in `.github/instructions/copilot.instructions.md`.
   
   Suggested documentation outline:
   - Section number: [suggest next available number in category]
   - Title: [feature name]
   - Admin description: [what problem does this solve?]
   - Technical area: configuration example using the new `config.X` accessor
   ```

2. **Provide a Draft** of the documentation section based on code changes:
   - Extract the config accessor name from `awesome.rb`
   - Identify default values from the `do` block
   - Note if `:disabled` is mentioned in comments
   - Suggest appropriate category based on file modifications

3. **Verify Cross-References**
   - Check that any references to other tweaks use the new per-section numbering (X.Y format)
   - Ensure global mechanisms are referenced from `global-mechanisms.md` not inline
   - Verify screenshot paths are correct (`../../examples/...`)

### Code Review Checklist

- [ ] Does this PR add a new `config_accessor` in `awesome.rb`?
- [ ] Is there corresponding documentation in `docs/tweaks/*.md`?
- [ ] Does the documentation follow the template structure?
- [ ] Are all three configuration states documented (true/false/:disabled)?
- [ ] Are there initializer code examples?
- [ ] Are cross-references using the new numbering scheme?
- [ ] If global/transversal, is it documented in `global-mechanisms.md`?
- [ ] Are screenshots referenced correctly?
- [ ] Does the README need updates (only if major new category)?

### Accuracy Requirements

Documentation must match actual implementation:
- Don't claim features have automatic cleanup/retention if they don't exist in code
- Don't claim server-side validation beyond what's actually implemented
- Verify async behavior claims against actual job/transaction handling
- Check default values against actual `do` block content in `awesome.rb`

## Review Philosophy

Documentation is not optional. Every user-facing feature requires clear, accurate documentation before merging.
When in doubt, suggest documentation improvements rather than approving without them.
