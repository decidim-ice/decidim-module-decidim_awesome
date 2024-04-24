import ApiFetcher from "src/decidim/decidim_awesome/awesome_map/api/api_fetcher";

export default class Fetcher {
  constructor(controller) {
    this.controller = controller;
    this.config = {
      length: controller.awesomeMap.config.length || 255
    };
    this.onFinished = () => {};
    this.onNode = () => {};
    this.onCollection = () => {};
    this.hashtags = [];

    this.collection = this.controller.component.type;
    // override in specific components:
    this.query = `query ($id: ID!, $after: String!) {
        component(id: $id) {
          id
          __typename
        }
      }`;
  }

  fetch(after = "") {
    const variables = {
      "id": this.controller.component.id,
      "after": after
    };
    const api = new ApiFetcher(this.query, variables);
    api.fetchAll((result) => {
      if (result) {
        const collection = result.component[this.collection];
        // console.log("collection", collection)
        
        collection.edges.forEach((element) => {
          let node = element.node;
          if (!node) {
            return;
          }
      
          if (node.coordinates && node.coordinates.latitude && node.coordinates.longitude) {
            this.decorateNode(node);
            this.onNode(node)
          }
        });

        this.onCollection(collection);

        if (collection.pageInfo.hasNextPage) {
          this.fetch(collection.pageInfo.endCursor);
        } else {
          this.onFinished();
        }
      }
    });
  }

  decorateNode(node) {
    const body = this.findTranslation(node.body.translations)
    const title = this.findTranslation(node.title.translations);
    node.hashtags = this.collectHashtags(title);
    node.hashtags = node.hashtags.concat(this.collectHashtags(body));
    // hashtags in the title look ugly, lets replace the gid:... structure with the tag #name
    node.title.translation = this.replaceHashtags(title, node.hashtags);
    node.body.translation = this.appendHtmlHashtags(this.truncate(this.removeHashtags(body)), node.hashtags);
    // console.log("decorateNode", node.title.translation, "BODY", body, "translation", node.body.translation, node.hashtags)
    node.link = `${this.controller.component.url}/${node.id}`;
  }

  findTranslation(translations) {
    let lang = document.querySelector("html").getAttribute("lang"),
        text = "";
    
    translations.forEach((txt) => {
      if (txt.text) {
        if (!text || txt.locale === lang) {
          text = txt.text
        }
      }
    });
    return text;
  }

  collectHashtags(text) {
    let tags = [];
    if (text) {
      const gids = text.match(/gid:\/\/[^\s<&,;]+/g)
      if (gids) {
        tags = gids.filter((gid) => gid.indexOf("/Decidim::Hashtag/") !== -1).map((gid) => {
          const parts = gid.split("/");
          const fromSelector = parts[5].charAt(0) === "_";
          const tag = fromSelector ? parts[5].substr(1) : parts[5]; // eslint-disable-line no-ternary, multiline-ternary
          const name = `#${tag}`;
          const html = `<a href="/search?term=${name}">${name}</a>`;
          const hashtag = {
            color: getComputedStyle(document.documentElement).getPropertyValue("--secondary"),
            gid: gid,
            id: parseInt(parts[4], 10),
            fromSelector: fromSelector,
            tag: tag,
            name: name,
            html: html
          }
          this.hashtags.push(hashtag)
          return hashtag;
        });
      }
    }
    return tags;
  }

  replaceHashtags(txt, hashtags) {
    let text = txt;
    hashtags.forEach((tag) => {
      text = text.replace(tag.gid, tag.name)
    });
    return text;
  }

  removeHashtags(text) {
    return text.replace(/gid:\/\/[^\s<&,;]+/g, "");
  }

  appendHtmlHashtags(txt, tags) {
    let string = tags.reduce((accumulator, tag) => (accumulator
      ? `${accumulator} ${tag.html}`
      : tag.html), "");
    if (string) {
      return `${txt}<p>${string}</p>`;
    } 
    return txt;
    
  }

  truncate(html) {
    return $.truncate(html, this.config);
  }

  formatDateRange(startDate, endDate) {
    // Check if either startDate or endDate is blank
    if (!startDate || !endDate) {
      return "";
    }

    // Convert startDate and endDate to JavaScript Date objects
    const start = new Date(startDate);
    const end = new Date(endDate);

    const date = Intl.DateTimeFormat(window.DecidimAwesome.currentLocale, { // eslint-disable-line new-cap
      year: "numeric",
      month: "short",
      day: "numeric"
    });
    return date.formatRange(start, end);
  }
}
