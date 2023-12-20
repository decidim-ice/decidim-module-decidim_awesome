---
layout: default
title: Home
nav_order: 1
description: "Decidim Awesome is a module that hacks Decidim in order to provide more features or improve some aspects of it."
permalink: /
---

# Decidim::DecidimAwesome
{: .fs-9 }

Usability and UX tweaks for Decidim.
{: .fs-6 .fw-400 }

This plugin allows the administrators to expand the possibilities of Decidim beyond some existing limitations.
{: .fs-6 .fw-300 }

All tweaks are provided in a optional fashion with granular permissions that let the administrator to choose exactly where to apply those mods. Some tweaks can be applied to any assembly, other in an specific participatory process or even in type of component only.

[Get started now](#getting-started){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 } [View source code](https://github.com/Platoniq/decidim-module-decidim_awesome){: .btn .fs-5 .mb-4 .mb-md-0 }

[![[CI] Test](https://github.com/Platoniq/decidim-module-decidim_awesome/actions/workflows/test.yml/badge.svg)](https://github.com/Platoniq/decidim-module-decidim_awesome/actions/workflows/test.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/2dada53525dd5a944089/maintainability)](https://codeclimate.com/github/Platoniq/decidim-module-decidim_awesome/maintainability)
[![Test Coverage](https://codecov.io/gh/Platoniq/decidim-module-decidim_awesome/branch/master/graph/badge.svg?token=TFBMCLLZJG)](undefined)
[![Gem Version](https://badge.fury.io/rb/decidim-decidim_awesome.svg)](https://badge.fury.io/rb/decidim-decidim_awesome)
---

This module is heavily tested and widely used, howevever we do not accept any responsibility for breaking anything. Feedback is appreciated though.
{: .label .label-yellow }

---

## Getting started

### Dependencies

DecidimAwesome is built for [Decidim](https://decidim.org), a digital platform for citizen participation. View the [Getting started with Decidim](https://docs.decidim.org/en/install/) for more information.

### Installation

Add this line to your application's Gemfile:

```
gem "decidim-decidim_awesome", "~> 0.7.2"
```

And then execute:

```bash
bundle
bundle exec rails decidim_decidim_awesome:install:migrations
bundle exec rails db:migrate
```

Depending on your Decidim version, choose the corresponding Awesome version to ensure compatibility:

| Awesome version | Compatible Decidim versions |
|-----------------|-----------------------------|
| 0.5.x           | 0.21.x, 0.22.x              |
| 0.6.x           | 0.22.x, 0.23.x              |
| 0.7.x           | 0.23.x, 0.24.x              |

> *Heads up!* version 0.7.1 requires database migrations! Don't forget the migrations step when updating.

### Configure DecidimAwesome

- [See configuration options]({{ site.baseurl }}{% link configuration.md %})

---

## About the project

DecidimAwesome is released by [Platoniq](https://platoniq.net).

![Platoniq Logo]({{ 'assets/images/logo-platoniq.jpg' }})


### License

DecidimAwesome is distributed under the [GNU AFFERO GENERAL PUBLIC LICENSE](https://github.com/Platoniq/decidim-module-decidim_awesome/blob/main/LICENSE-AGPLv3.txt).

### Contributing

When contributing to this repository, please first discuss the change you wish to make via issue,
email, or any other method with the owners of this repository before making a change. Read more about becoming a contributor in [our GitHub repo](https://github.com/Platoniq/decidim-module-decidim_awesome/#contributing).

#### Thank you to the contributors of Decidim::Awesome!

<ul class="list-style-none">
{% for contributor in site.github.contributors %}
  <li class="d-inline-block mr-1">
     <a href="{{ contributor.html_url }}"><img src="{{ contributor.avatar_url }}" width="32" height="32" alt="{{ contributor.login }}"/></a>
  </li>
{% endfor %}
</ul>

### Code of Conduct

DecidimAwesome is committed to fostering a welcoming community.

[View our Code of Conduct](https://github.com/Platoniq/decidim-module-decidim_awesome/blob/main/CODE_OF_CONDUCT.md) on our GitHub repository.
