---
layout: default
title: Custom styles
excerpt: "DecidimAwesome Tweak: Custom styles"
parent: Tweaks
nav_order: 10
---

# Custom CSS applied only according scoped restrictions
{: .no_toc }

This tweak will be deprecated in next version (0.8.0)
{: .label .label-red }

With this feature you can create directly in the admin a CSS snipped that is only applied globally, in a particular assembly or even a single proposal!

![CSS screenshot]({{ 'assets/images/tweaks/custom_styles.png' | relative_url }})

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

## Examples

Here are some customisations that can be useful. To apply them, follow these steps:
1. Enter to admin panel > Decidim awesome > Custom styles
1. Add a new CSS box (link at the bottom of the page)
1. Copy & Paste the code of the case you want to apply, replacing UPPERCASE WORDS with relevant information, if needed (e.g. URL)
1. Select the component(s) to which you want to apply the customisation in "Applicable only in these cases".

Customisations have been tested in Firefox, Chrome, and Safari browsers.

***
### Participatory process

#### Remove creation date of process

To remove the creation date of a process card

```
li.card-data__item.creation_date_status { display:none; }
```
⚠️ Remember to select "Process" in "Applicable only in these cases".

### Meetings component

#### Change avatar in official meetings

![Avatar changed for official meetings](http://demo.platoniq.net/uploads/decidim/attachment/file/108/big_official-meeting.png)

To change the grey person 👤  to a custom avatar, use the following code, replacing URL by the location of the image you want to use as avatar.

⚠️ Remember to select "meetings" in "Applicable only in these cases" to avoid undesirable behaviours in other components.

```
/* change default avatar in official meetings */
div#meetings div.author-data span.author__avatar img,
div.view-header div.author-data span.author__avatar img {
  display: none;
}
div#meetings div.author-data span.author__avatar,
div.view-header div.author-data span.author__avatar {
  background-image: url(URL);
  background-size: contain;
  width: 25px;
  height: 25px;
  border-radius: 50%;
  background-position-y: center;
  background-position-x: center;
  background-repeat: no-repeat;
}
```

#### Hide meetings map

To hide the map above the meetings list, paste the following code in the CSS box.

⚠️ Remember to select "meetings" in "Applicable only in these cases" to avoid hiding maps in other components.

```
/* hide map in meetings list */
div#map { display: none; }
```

#### Hide filter sidebar

To hide the filter in the meetings list, paste the following code in the CSS box.

⚠️ Remember to restrict the affected components in "Applicable only in these cases" to avoid unexpected behaviour in other components.

```
/* hide filter sidebar */
div.filters__section, div.filters,
div.filters-controls.hide-for-mediumlarge, div.card.card--secondary.show-for-mediumlarge
  { display:none; }
div#meetings { width: 100%; }
```

***

### Proposals component

#### Hide some filters in proposals list

Select the code of the filter you want to hide and paste it to the CSS box.

⚠️ Remember to restrict the affected components in "Applicable only in these cases" to avoid hiding filters in other components.

```
/* hide status filter */
div.filters__section.state_check_boxes_tree_filter { display: none; }

/* hide category filter */
div.filters__section.category_id_check_boxes_tree_filter { display: none; }

/* hide origin filter */
div.filters__section.origin_check_boxes_tree_filter { display: none; }

/* hide my activity filter */
div.filters__section.activity_collection_radio_buttons_filter { display: none; }

/* hide related to filter */
div.filters__section.related_to_collection_radio_buttons_filter { display: none; }
```

## Sponsors

> TBD

