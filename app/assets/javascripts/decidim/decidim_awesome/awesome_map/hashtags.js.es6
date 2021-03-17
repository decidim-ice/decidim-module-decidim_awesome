((exports) => {
  const hashtags = [];

  const collectHashtags = (text) => {
    let tags = [];
    if(text) {
      const gids = text.match(/gid:\/\/[^\s<]+/g)
      if(gids) {
        tags = gids.filter(gid => gid.indexOf("/Decidim::Hashtag/") != -1).map(gid => {
          const parts = gid.split("/");
          const fromSelector = parts[5].charAt(0) == '_';
          const tag = fromSelector ? parts[5].substr(1) : parts[5];
          const name = '#' + tag;
          const html = `<a>${name}</a>`;
          const hashtag = {
            color: getComputedStyle(document.documentElement).getPropertyValue('--secondary'),
            gid: gid,
            id: parseInt(parts[4], 10),
            fromSelector: fromSelector,
            tag: tag,
            name: name,
            html: html
          }
          hashtags.push(hashtag)
          return hashtag;
        });
      }
    }
    return tags;
  };

  const removeHashtags = (text) => {
    return text.replace(/gid:\/\/[^\s<]+/g, "");
  };

  const appendHtmlHashtags = (text, tags) => {
    tags.forEach(tag => {
      text += ` ${tag.html}`;
    });
    return text;
  };

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.hashtags = hashtags;
  exports.AwesomeMap.collectHashtags = collectHashtags;
  exports.AwesomeMap.appendHtmlHashtags = appendHtmlHashtags;
  exports.AwesomeMap.removeHashtags = removeHashtags;
})(window);
