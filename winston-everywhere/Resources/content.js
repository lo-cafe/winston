  //browser.runtime.sendMessage({ greeting: "hello" }).then((response) => {
  //    console.log("Received response: ", response);
  //});
  //
  //browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
  //    console.log("Received request: ", request);
  //});
  
  var recaptchaWasCheckedWinston = false
  var previousNumberOfAppsWinston = 0

  function removeElementByQuery(query) {
    var element = document.querySelector(query)
    if (element) { element.parentNode.removeChild(element) }
  }

  function changeContent(newTitle, newBody) {
    var title = document.querySelector("#winston-helper-title")
    var body = document.querySelector("#winston-helper-body")
    removeElementByQuery("#winston-helper-buttons-holder")
    title.innerText = newTitle
    body.innerText = newBody

    var apiHelper = document.querySelector('#winston-api-helper');
    var apiHelperContentHolder = document.querySelector('#winston-api-helper-content-holder');
    var winstonApiHelperContentHolderRect = apiHelperContentHolder.getBoundingClientRect();

    apiHelper.style.height = (winstonApiHelperContentHolderRect.height + 112 + 'px');
  }

  function positionElement() {
    var apiHelper = document.querySelector('#winston-api-helper');
    var recaptchaChild = document.querySelector('.c-form-group.g-recaptcha').children[0];
    var recaptchaRect = recaptchaChild.getBoundingClientRect();

    apiHelper.style.top = ((recaptchaRect.top + recaptchaRect.height - 35) + 'px');
    changeContent("Almost there!", "The page is ugly back there, so we made recaptcha bigger for you. Tick it and I'll take care of the rest.")

    var arrow = document.querySelector('#apiHelperArrow') || document.createElement('div');
    arrow.id = 'apiHelperArrow';
    arrow.style.position = 'absolute';
    arrow.style.width = '100px';
    arrow.style.height = '100px';
    arrow.style.backgroundColor = 'black';
    arrow.style.transform = 'scaleX(1) rotate(31deg)';
    arrow.style.top = '-27.4px';
    arrow.style.left = '84px';
    arrow.style.borderRadius = '12px';

    var recaptchaScaledPadding = 32;
    var scale = (window.innerWidth - (recaptchaScaledPadding * 2)) / recaptchaRect.width
    recaptchaChild.style.transform = `scale(${scale})`
    var recaptchaRectCenterX = recaptchaRect.left + (recaptchaRect.width / 2);
    var outBounds = recaptchaRectCenterX - ((recaptchaRect.width / 2) * scale)
    recaptchaChild.style.position = 'relative';
    recaptchaChild.style.right = `${outBounds - recaptchaScaledPadding}px`;
    recaptchaChild.style.top = '-100px';

    if (!document.querySelector('#apiHelperArrow')) {
      apiHelper.appendChild(arrow);
    }
  }

  function fillWinstonApp() {
    document.getElementById("create-app-button").click()
    document.querySelector("#create-app input[name=name]").value = "Winston"
    document.querySelector("#app_type_web").checked = true
    document.querySelector("#create-app textarea[name=description]").value = "A developer's tool for devs to test their API keys."
    document.querySelector("#create-app input[name=about_url]").value = "https://winston.cafe"
    document.querySelector("#create-app input[name=redirect_uri]").value = "https://app.winston.cafe/auth-success"
    const recaptchaEl = document.querySelector(".c-form-group.g-recaptcha")
    recaptchaEl.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"})
    recaptchaEl.focus()
  }

  function submitAndGetDetails() {
    document.querySelector("#create-app button[type=submit]").click()
    changeContent("Here we go!", "Now you just need to wait a little bit.")
    resetPosition()
    var title = document.querySelector("#winston-helper-title")
    var body = document.querySelector("#winston-helper-body")
    
    function getDetailsOfNewApp() {
      const appsItems = document.querySelector("#developed-apps ul").children
      if (appsItems.length == previousNumberOfAppsWinston) { setTimeout(getDetailsOfNewApp, 200); return }
      const ourApp = appsItems[appsItems.length - 1]
      const ourAppDetails = ourApp.querySelector(".app-details").children
      const appID = ourAppDetails[ourAppDetails.length - 1].innerText
      const appSecret = ourApp.querySelector(".prefright").innerHTML

      window.location.assign(`https://app.winston.cafe/?appID=${appID}&appSecret=${appSecret}`)
    }
    setTimeout(() => {
      getDetailsOfNewApp()
    }, 200);
  }

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

function resetPosition() {
  var apiHelper = document.querySelector('#winston-api-helper');
  var apiHelperRect = apiHelper.getBoundingClientRect();
  apiHelper.style.height = (apiHelperRect.height + 'px');
  apiHelper.style.top = `${screenHeight - apiHelperRect.height - 32}px`;
}
  //https://www.reddit.com/api/v1/authorize?client_id=VwwmxgwUwf4vyhJEb3cHdw&response_type=code&state=49170419-ADA4-4CBD-ACA3-96F41FB22321&redirect_uri=https://winston.cafe/auth-success&duration=permanent&scope=identity,edit,flair,history,modconfig,modflair,modlog,modposts,modwiki,mysubreddits,privatemessages,read,report,save,submit,subscribe,vote,wikiedit,wikiread

  var hostName = window.location.hostname;
  if (hostName.includes('reddit.com')) {
    var screenHeight = window.innerHeight
    var url = location.pathname+location.search
    var winstonHelpBanner = `<div id="winston-api-helper" style='gap:0;position:fixed;z-index:999999999;left:0;right:0;padding:56px;margin:0 auto;font-size:48px;background:#000;color:#fff;width:calc(100% - 64px);box-sizing:border-box;border-radius:118px;display:flex;flex-direction:column;align-items:center;justify-content:flex-start;font-family:"SF Pro",system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Oxygen,Ubuntu,Cantarell,"Open Sans","Helvetica Neue",sans-serif;text-align:center;top:${screenHeight}px;transition:all 1s cubic-bezier(.12,1.335,.4,.98) 0s;height:726.406px'><div id="winston-api-helper-content-holder" style=display:flex;flex-direction:column;align-items:center;justify-content:flex-start;width:100%><img src=https://winston.cafe/side-winston-tinyfied.png style=width:178px;margin-bottom:16px><h1 id=winston-helper-title style=font-weight:700;font-size:84px>Hey!</h1><p id=winston-helper-body style=margin:0>I noticed you're generating an API.<br>I can help with that!<div id=winston-helper-buttons-holder style=display:flex;margin-top:46px;width:100%;gap:24px><button id=cancel-automate-winston-button style="background:#3b3b3f;color:#fff;border:none;border-radius:1000px;font-size:52px;font-family:SF Pro,system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Oxygen,Ubuntu,Cantarell,Open Sans,Helvetica Neue,sans-serif;font-weight:600;flex-grow:1;display:block;padding:32px">Nah</button><button id=go-automate-winston-button style="background:#008fff;color:#fff;border:none;border-radius:1000px;font-size:52px;font-family:SF Pro,system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Oxygen,Ubuntu,Cantarell,Open Sans,Helvetica Neue,sans-serif;font-weight:600;flex-grow:1;display:block;padding:32px">Sure!</button></div></div></div>`
    var openInWinstonBanner = `<div id="winstonBanner" style="position:fixed;z-index:9999999999;bottom: 8px;left: 8px;right:0;border-radius: 64px;width: calc(100% - 16px);height: 72px;display: flex;align-items: center;justify-content: space-between;padding: 0 24px;background: radial-gradient(circle,#212136,#0f0e12);box-sizing: border-box;color: #fff;font-weight: 700;font-family: system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Oxygen,Ubuntu,Cantarell,Open Sans,Helvetica Neue,sans-serif;-webkit-user-select: none;-webkit-user-drag: none;"><img src="https://winston.cafe/james-webb.jpg" style="position: absolute;left: 0;z-index: -1;width:100%;height:100%;object-fit: cover;object-position: center;right: 0;margin: auto;border-radius: 64px;opacity: 0.25;"><div style="display:flex;color: white;align-items: center;gap: 12px;font-size: 14px;"><img src="https://winston.cafe/side-winston-tinyfied.png" style="
        width: 48px;
    "><div>Hey!</div></div><a href="winstonapp:/${url}" style="padding: 8px 16px;background: #008eff;border: none;border-radius: 16px;font-size: 14px;text-decoration: none;color: white;">Open in Winston!</a><button id="closeBannerButton" style="width: 20px;height: 20px;background: red;border: none;border-radius: 10px;font-size: 11px;position: absolute;right: 14px;top: -11px;line-height: 20px;vertical-align: middle;text-align:center;">X</button>
    </div>`
    
    if (url.includes('/prefs/apps')) {
      document.body.insertAdjacentHTML('beforeend', winstonHelpBanner);
      previousNumberOfAppsWinston = document.querySelector("#developed-apps ul").children
      setTimeout(() => {

        resetPosition()

        document.getElementById('cancel-automate-winston-button').addEventListener('click', function() {
          var banner = document.getElementById('winston-api-helper');
          document.getElementById('winston-api-helper').style.bottom = "-100%"
          setTimeout(() => {
            banner.parentNode.removeChild(banner);
          }, 1000);
        });
        
        document.getElementById('go-automate-winston-button').addEventListener('click', function() {
          fillWinstonApp()
          setTimeout(() => {
            var observer = new MutationObserver((mutationsList, observer) => {
              for(let mutation of mutationsList) {
                if (mutation.target.nodeName == "IFRAME") {
                  if (recaptchaWasCheckedWinston) { return }
                  recaptchaWasCheckedWinston = true
                  setTimeout(() => {
                  submitAndGetDetails()
                }, 500);
                }
              }
          });
          observer.observe(document, { attributes: true, subtree: true });
            positionElement()
        }, 200);
        });
        
      }, 500);
    } else if (!url.includes('/api/v1/authorize')) {
      document.body.insertAdjacentHTML('beforeend', openInWinstonBanner);
      setTimeout(() => {
        document.getElementById('closeBannerButton').addEventListener('click', function() {
          var banner = document.getElementById('winstonBanner');
          banner.parentNode.removeChild(banner);
        });
      }, 100);
    }
  }
