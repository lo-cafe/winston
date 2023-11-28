//browser.runtime.sendMessage({ greeting: "hello" }).then((response) => {
//    console.log("Received response: ", response);
//});
//
//browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
//    console.log("Received request: ", request);
//});

document.querySelectorAll('a').forEach(link => {
  if (link && link.href) {
    try {
      var url = new URL(link.href);
      if (url.hostname.includes('reddit.com')) {
        link.href = link.href.replace(/(https?:\/\/)?(www\.)?reddit\.com/gi, 'https://winston.cafe');
      }
    } catch (e) {
      console.error('Invalid URL', link.href);
    }
  }
});


//https://www.reddit.com/api/v1/authorize?client_id=VwwmxgwUwf4vyhJEb3cHdw&response_type=code&state=49170419-ADA4-4CBD-ACA3-96F41FB22321&redirect_uri=https://winston.cafe/auth-success&duration=permanent&scope=identity,edit,flair,history,modconfig,modflair,modlog,modposts,modwiki,mysubreddits,privatemessages,read,report,save,submit,subscribe,vote,wikiedit,wikiread

var hostName = window.location.hostname;
if (hostName.includes('reddit.com' && !hostName.includes('reddit.com/api/v1/authorize'))) {
  var url = location.pathname+location.search
  var openInWinstonBanner = `<div id="winstonBanner" style="position:fixed;z-index:9999999999;bottom: 8px;left: 8px;right:0;border-radius: 64px;width: calc(100% - 16px);height: 72px;display: flex;align-items: center;justify-content: space-between;padding: 0 24px;background: radial-gradient(circle,#212136,#0f0e12);box-sizing: border-box;color: #fff;font-weight: 700;font-family: system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Oxygen,Ubuntu,Cantarell,Open Sans,Helvetica Neue,sans-serif;-webkit-user-select: none;-webkit-user-drag: none;"><img src="https://winston.cafe/james-webb.jpg" style="position: absolute;left: 0;z-index: -1;width:100%;height:100%;object-fit: cover;object-position: center;right: 0;margin: auto;border-radius: 64px;opacity: 0.25;"><div style="display:flex;color: white;align-items: center;gap: 12px;font-size: 14px;"><img src="https://winston.cafe/transparent-winston.png" style="
      width: 48px;
  "><div>Hey!</div></div><a href="winstonapp:/${url}" style="padding: 8px 16px;background: #008eff;border: none;border-radius: 16px;font-size: 14px;text-decoration: none;color: white;">Open in Winston!</a><button id="closeBannerButton" style="width: 20px;height: 20px;background: red;border: none;border-radius: 10px;font-size: 11px;position: absolute;right: 14px;top: -11px;line-height: 20px;vertical-align: middle;text-align:center;">X</button>
  </div>`
  document.body.insertAdjacentHTML('beforeend', openInWinstonBanner);
  document.getElementById('closeBannerButton').addEventListener('click', function() {
    var banner = document.getElementById('winstonBanner');
    banner.parentNode.removeChild(banner);
  });
}
