# Editor and content creation

## Tweaks

### 1.1 Image support for the RichText editor

Adds image upload and drag & drop support to the WYSIWYG editor used in admin/public rich text contexts.
The uploaded images are stored as external resources (not base64 inline content).

#### Admin description

Enables editorial teams to embed images directly in rich text areas without reverting to external hosting or links.
Concerns include storage quota management and image moderation workflows.
Recommend enabling image upload size limits in administration settings to prevent storage overflow.

#### Technical area

- **Configuration:** Via initializer (affects default state; admins can always restrict scope)

```ruby
# config/initializers/awesome_defaults.rb
Decidim::DecidimAwesome.configure do |config|
  # true = enabled by default globally (admins can restrict to specific scopes)
  # false = disabled by default (admins CAN enable using scope restrictions)
  # :disabled = completely removed, hidden from admins
  config.allow_images_in_editors = false  # default: false
end
```

- **Admin visibility:** Enabled (admins see Settings → Ckeditor options toggle)
- **Default behavior:** Disabled by default; admins can enable using scope restrictions (see [Global mechanisms](global-mechanisms.md))
- **Admin control:** Yes; toggle on/off and apply scope restrictions (see [Global mechanisms](global-mechanisms.md))
- **Performance:** Minimal impact; images stored as URLs, not base64. Monitor file storage quotas periodically.
- **Prerequisites:** Valid file storage backend configured (local, S3, etc.)
- **Moderation:** Images are subject to standard content moderation policies; no special review needed

![Images in RichText Editor](../../examples/quill-images.png)

### 1.2 Images in proposals

Allows users to drag & drop images into proposal textareas even when public rich text is not enabled.
Useful when proposals use plain text input but still need media attachments.

#### Admin description

Balances structured proposal text with visual content from participants. Reduces friction for visual storytelling.
Concerns: manage image quality expectations and moderation volume. Combined with Tweak 2.1 (custom fields), can structure images alongside metadata.
Recommend clear guidelines for image size and format in help text.

#### Technical area

- **Configuration:** Via initializer or admin panel per component

```ruby
# config/initializers/awesome_defaults.rb
Decidim::DecidimAwesome.configure do |config|
  # true = enabled by default globally (admins can restrict to specific scopes)
  # false = disabled by default (admins CAN enable using scope restrictions)
  # :disabled = completely removed, hidden from admins
  config.allow_images_in_proposals = false  # default: false
end
```

- **Admin visibility:** Enabled (admins see Settings → Components toggle per proposal component)
- **Default behavior:** Disabled by default; admins can enable using scope restrictions (see [Global mechanisms](global-mechanisms.md))
- **Admin control:** Yes; toggle on/off and apply scope restrictions (see [Global mechanisms](global-mechanisms.md))
- **Storage:** Same backend as editor images; validate combined quota limits if both tweaks enabled
- **Performance:** Negligible impact; images indexed alongside proposals for search
- **Moderation:** Follows standard proposal moderation workflow; images included in admin review

![Proposal images](../../examples/proposal-images.png)

### 1.3 HTML code editor in the admin

Replaces the WYSIWYG editor with an HTML code editor (CodeMirror 6) in the admin, so the markup is written and saved as is.
The public editors used by participants are never replaced.

#### Admin description

Useful for pages and descriptions that need markup the WYSIWYG editor cannot produce, such as custom containers with CSS classes.
Tags that are not allowed are underlined in the code editor, as they are removed when the content is displayed.
Content written in the code editor can lose its markup if it is saved again from the WYSIWYG editor, so avoid enabling and disabling the option for the same content.

#### Technical area

- **Configuration:** Via initializer (affects default state; admins can always restrict scope)

```ruby
# config/initializers/awesome_defaults.rb
Decidim::DecidimAwesome.configure do |config|
  # true = enabled by default globally (admins can restrict to specific scopes)
  # false = disabled by default (admins CAN enable using scope restrictions)
  # :disabled = completely removed, hidden from admins
  config.html_code_editor = false  # default: false

  # Extra HTML tags kept when displaying content written by admins,
  # added to the ones Decidim already allows
  config.html_code_editor_allowed_tags = %w(style)  # default: ["style"]
end
```

- **Admin visibility:** Enabled (admins see Editor Hacks → toggle)
- **Default behavior:** Disabled by default; admins can enable using scope restrictions (see [Global mechanisms](global-mechanisms.md))
- **Admin control:** Yes; toggle on/off and apply scope restrictions (see [Global mechanisms](global-mechanisms.md))
- **Scope:** `html_code_editor_allowed_tags` is set only in the initializer and applies to all the content written by admins in every organization, also where the code editor is not enabled; ignored with `html_code_editor = :disabled`
- **Security:** Proposals written by participants never get the extra tags. Do not add `script` to the list: any admin with access to an editor could then publish JavaScript
- **Compatibility:** Rules inside a `<style>` tag apply to the whole page; Decidim escapes `<`, `>` and `&` inside it, so rules that use them (like `.menu > li`) do not work there
- **Performance:** Minimal impact; the code editor is loaded on demand, only in the admin pages that render an editor
- **Cross-references:** Use Tweak 4.1 (custom CSS, see [UI, theming and navigation](ui-theming-navigation.md)) for the CSS rules that cannot go in a `<style>` tag

![HTML code editor](../../examples/html_code_editor.png)
