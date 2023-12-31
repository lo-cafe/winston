document.querySelectorAll('a').forEach(link => {
  if (link && link.href) {
    try {
      var url = new URL(link.href);
      if (url.hostname.includes('reddit.com')) {
        link.href = link.href.replace(/(https?:\/\/)?(www\.|old\.)?reddit\.com/gi, 'https://app.winston.cafe');
      }
    } catch (e) {
      console.error('Invalid URL', link.href);
    }
  }
});
