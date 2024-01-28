browser.webNavigation.onBeforeNavigate.addListener(function(details) {
  if (details.frameId === 0) { // Ensure it's the main frame
    console.log('Navigating to:', details.url);
    
    try {
      var url = new URL(details.url);
      console.log('Parsed URL:', url);

      if (url.hostname.includes('reddit.com')) {
        // Modify the URL before navigation
        var newUrl = details.url.replace(/(https?:\/\/)?(www\.)?reddit\.com/gi, 'https://app.winston.cafe');
        console.log('Modified URL:', newUrl);

        // Redirect to the modified URL
        browser.webNavigation.onBeforeNavigate.removeListener(listener); // Remove the listener to avoid infinite loop
        browser.webNavigation.navigate({ url: newUrl });
      }
    } catch (e) {
      console.error('Invalid URL', details.url, e);
    }
  }
});

// Start listening for navigation events
var listener = browser.webNavigation.onBeforeNavigate.addListener(function() {});
