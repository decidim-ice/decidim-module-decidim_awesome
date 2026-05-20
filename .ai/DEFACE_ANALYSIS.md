# Deface Overrides Analysis

## Current State

This document analyzes all existing Deface overrides against the preferred pattern:
**Single render command per `.html.erb.deface` file delegating to custom partials.**

### Overview

- **Total overrides**: 25
- **Following best practice** ✅: 21 (84%)
- **Need improvement** ⚠️: 4 (16%)

---

## Overrides Following Best Practice ✅

These overrides correctly delegate all logic to custom partials:

### Admin Officializations

1. **app/overrides/decidim/admin/officializations/index/add_td.html.erb.deface**
   ```erb
   <!-- insert_before "td.table-list__actions" -->
   <% if awesome_config[:admins_available_authorizations] %>
     <%= render "decidim/decidim_awesome/admin/officializations/participants_td", user: %>
   <% end %>
   ```
   ✅ Single render with condition

2. **app/overrides/decidim/admin/officializations/index/add_modal.html.erb.deface**
   ```erb
   <!-- insert_after "erb[loud]:contains('show_email_modal')" -->
   <%= render "decidim/decidim_awesome/admin/officializations/verification_modal" %>
   ```
   ✅ Pure render

3. **app/overrides/decidim/admin/officializations/index/add_th.html.erb.deface**
   ✅ Single render

### Proposals (Admin)

4. **app/overrides/decidim/proposals/admin/proposals/_form/replace_editor.html.erb.deface**
   ```erb
   <!-- replace "erb[loud]:contains('form.translated :editor, :body')" -->
   <%= render partial: "decidim/decidim_awesome/admin/proposals/editor", locals: { form: form } %>
   ```
   ✅ Perfect pattern - single render with locals

5. **app/overrides/decidim/proposals/admin/proposals/show/replace_body.html.erb.deface**
   ✅ Single render

6. **app/overrides/decidim/proposals/admin/proposals/show/add_private_body.html.erb.deface**
   ✅ Single render

### Proposals (Public)

7. **app/overrides/decidim/proposals/proposals/show/add_voting_help_modal.html.erb.deface**
   ```erb
   <!-- insert_bottom ".layout-main__section.layout-main__heading" -->
   <% if awesome_voting_manifest_for(current_component)&.show_vote_button_view.present? %>
     <%= cell("decidim/decidim_awesome/voting/voting_cards_modal", nil) %>
   <% end %>
   ```
   ✅ Single cell render with condition

8. **app/overrides/decidim/proposals/proposals/index/add_voting_help_modal.html.erb.deface**
   ✅ Single cell render

9. **app/overrides/decidim/proposals/proposals/_vote_button/replace_vote_button.html.erb.deface**
   ✅ Single render

10. **app/overrides/decidim/proposals/proposals/_votes_count/replace_counter.html.erb.deface**
    ✅ Single render

11. **app/overrides/decidim/proposals/proposals/_proposal_actions/limit_amendments_modal.html.erb.deface**
    ```erb
    <!-- insert_before "erb[silent]:contains('@proposal.amendable? && allowed_to?...')" -->
    <%= render "decidim/decidim_awesome/amendments/modal" if @proposal.emendations.not_hidden.where(...).exists? && @proposal.amendable? %>
    ```
    ⚠️ **Condition could be moved to partial** (see improvements below)

### Form Visibility Callouts

12. **app/overrides/decidim/assemblies/admin/assemblies/_form/add_visibility_callout.html.erb.deface**
    ```erb
    <!-- insert_bottom "div#panel-visibility" -->
    <%= render "decidim/decidim_awesome/admin/shared/visibility_notice", participatory_space: current_assembly rescue nil %>
    ```
    ✅ Single render

13. **app/overrides/decidim/participatory_processes/admin/participatory_processes/_form/add_visibility_callout.html.erb.deface**
    ```erb
    <!-- insert_bottom "div#panel-visibility" -->
    <%= render "decidim/decidim_awesome/admin/shared/visibility_notice", participatory_space: current_participatory_process rescue nil %>
    ```
    ✅ Single render

14. **app/overrides/decidim/conferences/admin/conferences/_form/add_visibility_callout.html.erb.deface**
    ```erb
    <!-- insert_bottom "div#panel-visibility" -->
    <%= render "decidim/decidim_awesome/admin/shared/visibility_notice", participatory_space: current_conference rescue nil %>
    ```
    ✅ Single render

15. **app/overrides/decidim/participatory_processes/admin/participatory_process_groups/_form/add_visibility_callout.html.erb.deface**
    ✅ Single render

### System Configuration

16. **app/overrides/decidim/system/organizations/_advanced_settings/add_awesome_config.html.erb.deface**
    ```erb
    <!-- insert_top '#advanced-settings-panel' -->
    <% if Decidim::DecidimAwesome.enabled?(:admins_available_authorizations) %>
      <div class="awesome_available_authorizations border-2 rounded border-background p-4 form__wrapper mt-8 first:mt-0 last:pb-4">
        <h3 class="h4"><%= t "decidim.decidim_awesome.system.organizations.awesome_tweaks" %></h3>
        <%= render partial: "decidim/decidim_awesome/system/organizations/admin_allowed_authorizations", locals: { f: f } %>
      </div>
    <% end %>
    ```
    ⚠️ **Too much HTML - should be in partial** (see improvements below)

### Authentication

17. **app/overrides/decidim/account/show/add_timezone_select.html.erb.deface**
    ✅ Single render

18. **app/overrides/decidim/devise/sessions/new/add_hashcash.html.erb.deface**
    ```erb
    <!-- insert_top ".login__modal-remember" -->
    <%= render partial: "decidim/decidim_awesome/hashcash/hidden_field", locals: { zone: :login } %>
    ```
    ✅ Single render

19. **app/overrides/decidim/devise/registrations/new/add_hashcash.html.erb.deface**
    ✅ Single render

20. **app/overrides/decidim/shared/_login_modal/add_hashcash.html.erb.deface**
    ```erb
    <!-- insert_top ".login__modal-remember" -->
    <%= render partial: "decidim/decidim_awesome/hashcash/hidden_field", locals: { zone: :login } %>
    ```
    ✅ Single render

### Layout Overrides

21. **app/overrides/layouts/decidim/_head/add_awesome_custom_styles.html.erb.deface**
    ```erb
    <!-- insert_after "erb[loud]:contains('content_for :header_snippets')" -->
    <%= render(partial: "layouts/decidim/decidim_awesome/custom_styles") if awesome_scoped_styles.present? %>
    ```
    ✅ Single render with condition

22. **app/overrides/layouts/decidim/admin/_header/add_awesome_tags.html.erb.deface**
    ✅ Single render

23. **app/overrides/layouts/decidim/admin/_header/add_awesome_custom_styles.html.erb.deface**
    ✅ Single render

24. **app/overrides/layouts/decidim/_decidim_javascript/add_awesome_tags.html.erb.deface**
    ✅ Single render

---

## Overrides Needing Improvement ⚠️

### 1. **layouts/decidim/_head/add_awesome_tags.html.erb.deface** 🔴

**Current (too much logic)**:
```erb
<!-- insert_after "erb[loud]:contains('append_stylesheet_pack_tag')" -->
<% append_stylesheet_pack_tag "decidim_decidim_awesome", media: "all" %>
<% append_javascript_pack_tag "decidim_decidim_awesome", defer: false %>
<% append_javascript_pack_tag("decidim_decidim_awesome_custom_fields") if Decidim::DecidimAwesome.enabled?(:proposal_custom_fields) %>
```

**Improvement**:
```erb
<!-- insert_after "erb[loud]:contains('append_stylesheet_pack_tag')" -->
<%= render "layouts/decidim/decidim_awesome/asset_tags" %>
```

**New partial** (`app/views/layouts/decidim/decidim_awesome/_asset_tags.html.erb`):
```erb
<% append_stylesheet_pack_tag "decidim_decidim_awesome", media: "all" %>
<% append_javascript_pack_tag "decidim_decidim_awesome", defer: false %>
<% append_javascript_pack_tag("decidim_decidim_awesome_custom_fields") if Decidim::DecidimAwesome.enabled?(:proposal_custom_fields) %>
```

**Reason**: Multiple append commands with conditional logic

---

### 2. **system/organizations/_advanced_settings/add_awesome_config.html.erb.deface** 🔴

**Current (too much HTML)**:
```erb
<!-- insert_top '#advanced-settings-panel' -->
<% if Decidim::DecidimAwesome.enabled?(:admins_available_authorizations) %>
  <div class="awesome_available_authorizations border-2 rounded border-background p-4 form__wrapper mt-8 first:mt-0 last:pb-4">
    <h3 class="h4"><%= t "decidim.decidim_awesome.system.organizations.awesome_tweaks" %></h3>
    <%= render partial: "decidim/decidim_awesome/system/organizations/admin_allowed_authorizations", locals: { f: f } %>
  </div>
<% end %>
```

**Improvement**:
```erb
<!-- insert_top '#advanced-settings-panel' -->
<%= render "decidim/decidim_awesome/system/organizations/awesome_config_section", f: f %>
```

**New partial** (`app/views/decidim/decidim_awesome/system/organizations/_awesome_config_section.html.erb`):
```erb
<% if Decidim::DecidimAwesome.enabled?(:admins_available_authorizations) %>
  <div class="awesome_available_authorizations border-2 rounded border-background p-4 form__wrapper mt-8 first:mt-0 last:pb-4">
    <h3 class="h4"><%= t "decidim.decidim_awesome.system.organizations.awesome_tweaks" %></h3>
    <%= render partial: "decidim/decidim_awesome/system/organizations/admin_allowed_authorizations", locals: { f: f } %>
  </div>
<% end %>
```

**Reason**: HTML markup should be in partial, not override file

---

### 3. **proposals/proposals/_proposal_actions/limit_amendments_modal.html.erb.deface** 🟡

**Current (complex condition inline)**:
```erb
<!-- insert_before "erb[silent]:contains('@proposal.amendable? && allowed_to?...')" -->
<%= render "decidim/decidim_awesome/amendments/modal" if @proposal.emendations.not_hidden.where(decidim_amendments: { state: Decidim::Amendment.states["evaluating"] }).exists? && @proposal.amendable? %>
```

**Suggestion** (optional improvement):
Move the condition logic to a helper method:
```erb
<!-- insert_before "erb[silent]:contains('@proposal.amendable? && allowed_to?...')" -->
<%= render "decidim/decidim_awesome/amendments/modal" if proposal_has_evaluating_amendments?(@proposal) %>
```

**New helper method** (`app/helpers/decidim/decidim_awesome/proposals_helper.rb`):
```ruby
def proposal_has_evaluating_amendments?(proposal)
  proposal.emendations.not_hidden.where(
    decidim_amendments: { state: Decidim::Amendment.states["evaluating"] }
  ).exists? && proposal.amendable?
end
```

**Reason**: Complex query conditions are easier to test and reuse when in helpers/services

---

### 4. **admin/officializations/index/add_td.html.erb.deface** 🟡

**Current (minor condition)**:
```erb
<!-- insert_before "td.table-list__actions" -->
<% if awesome_config[:admins_available_authorizations] %>
  <%= render "decidim/decidim_awesome/admin/officializations/participants_td", user: %>
<% end %>
```

**Status**: ✅ Already acceptable, but could be enhanced by moving condition to partial if it becomes more complex

---

## Summary & Next Steps

### Immediate Actions (Required)

1. **Fix `layouts/decidim/_head/add_awesome_tags.html.erb.deface`**
   - Extract asset tags into partial
   - Files to create: `app/views/layouts/decidim/decidim_awesome/_asset_tags.html.erb`

2. **Fix `system/organizations/_advanced_settings/add_awesome_config.html.erb.deface`**
   - Extract HTML structure into partial
   - Files to create: `app/views/decidim/decidim_awesome/system/organizations/_awesome_config_section.html.erb`

### Optional Improvements (Can be done gradually)

3. **Enhance `proposals/_proposal_actions/limit_amendments_modal.html.erb.deface`**
   - Extract condition check to helper method
   - Make logic testable and reusable
   - File to create: Helper method in `app/helpers/decidim/decidim_awesome/proposals_helper.rb`

### Testing Best Practice

When testing deface overrides:
- **Don't test the override itself** (Deface handles that)
- **Test the partial behavior** (unit tests for logic)
- **Test integration** (system/feature tests showing override appears)

Example:
```ruby
# spec/views/decidim/decidim_awesome/admin/officializations/_participants_td.html.erb_spec.rb
describe "decidim_awesome/admin/officializations/_participants_td" do
  it "renders officializations for authorized users" do
    # Test the partial logic, not the Deface injection
  end
end
```

---

## Maintenance Notes

- **Review selectors** when Decidim updates (they may change)
- **Use class/id selectors** over XPath when possible
- **Consider feature flags** for disabling overrides
- **Add deprecation notes** if Decidim will support feature natively
- **Track in CHANGELOG** when overrides are added/modified
