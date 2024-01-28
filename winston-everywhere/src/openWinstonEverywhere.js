document.onreadystatechange = function () {
  if (document.readyState == "complete") {
    console.log('Script is running after document is complete.');

    document.querySelectorAll('a').forEach(link => {
      console.log('Checking link:', link.href);
      
      if (link && link.href) {
        try {
          var url = new URL(link.href);
          console.log('Parsed URL:', url);

          if (url.hostname.includes('reddit.com')) {
            link.href = link.href.replace(/(https?:\/\/)?(www\.)?reddit\.com/gi, 'https://app.winston.cafe');
            console.log('Modified link:', link.href);
          }
        } catch (e) {
          console.error('Invalid URL', link.href, e);
        }
      }
    });
  }
}
