# AI Agent Guidelines for Decidim Awesome

This directory contains guidelines and documentation to help AI agents understand and contribute to the Decidim Awesome module effectively.

## Quick Overview

**Project**: Decidim Awesome - A Decidim module that adds usability and UX tweaks  
**Language**: Ruby on Rails  
**Current Version**: 0.14.1  
**Decidim Compatibility**: 0.31.x  

## Key Files to Review

- [ARCHITECTURE.md](./ARCHITECTURE.md) - Project structure and organization
- [DEFACE_ANALYSIS.md](./DEFACE_ANALYSIS.md) - Analysis of all Deface overrides with improvement recommendations
- [CONVENTIONS.md](./CONVENTIONS.md) - Code style and conventions
- [TESTING.md](./TESTING.md) - Testing guidelines and practices
- [WORKFLOW.md](./WORKFLOW.md) - Development workflow and best practices

## For Code Reviews

When reviewing code in this repository:

1. **Check compatibility**: Always verify Decidim version compatibility in `lib/decidim/decidim_awesome/version.rb`
2. **Test coverage**: All new features should include specs in the `spec/` directory
3. **Translations**: New user-facing strings must be added to all locale files in `config/locales/`
4. **Locale files**: Validate YAML syntax using `ruby -ryaml -e "YAML.load_file('config/locales/xx.yml')"`
5. **Documentation**: Update `CHANGELOG.md` and `README.md` where applicable

## Helpful Resources

- GitHub Issues: https://github.com/decidim-ice/decidim-module-decidim_awesome/issues
- Pull Requests: https://github.com/decidim-ice/decidim-module-decidim_awesome/pulls
- Decidim Docs: https://docs.decidim.org

## Common Tasks

### Running Tests
```bash
bundle exec rspec spec/
```

### Validate YAML Locales
```bash
ruby -e "Dir['config/locales/*.yml'].each { |f| YAML.load_file(f); puts \"✓ #{f}\" }"
```

### Fetch Latest Version Info
```bash
# Check Decidim Awesome version
cat lib/decidim/decidim_awesome/version.rb
```

## AI Agent Capabilities

You can help with:
- Code reviews and quality assurance
- Adding features and fixes
- Writing/updating specs and tests
- Maintaining locale files and translations
- Documentation updates
- CHANGELOG updates with PR references
- Performance optimizations
- Security reviews

## When in Doubt

1. Review the existing code patterns in the codebase
2. Check similar implementations in other parts of the project
3. Refer to Decidim's documentation and best practices
4. Ask for clarification via commit comments or PR conversations
