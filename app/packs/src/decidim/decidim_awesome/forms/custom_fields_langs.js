export default function getLang(lang) {
    const langs = {
      // ar: 'ar-SA', // Not in decidim yet
      "ar": "ar-TN",
      "ca": "ca-ES",
      "cs": "cs-CZ",
      "da": "da-DK",
      "de": "de-DE",
      "el": "el-GR",
      "en": "en-US",
      "es": "es-ES",
      "fa": "fa-IR",
      "fi": "fi-FI",
      "fr": "fr-FR",
      "he": "he-IL",
      "hu": "hu-HU",
      "it": "it-IT",
      "ja": "ja-JP",
      "my": "my-MM",
      "nb": "nb-NO",
      "nl": "nl-NL",
      "pl": "pl-PL",
      "pt": "pt-BR",
      "qz": "qz-MM",
      "ro": "ro-RO",
      "ru": "ru-RU",
      "sl": "sl-SI",
      "th": "th-TH",
      "tr": "tr-TR",
      "uk": "uk-UA",
      "vi": "vi-VN",
      "zh-TW": "zh-TW",
      "zh": "zh-CN"
    };
    if (langs[lang]) {
      return langs[lang];
    }
    if (langs[lang.substr(0, 2)]) {
      return langs[lang.substr(0, 2)];
    }
    return "en-US";
  }