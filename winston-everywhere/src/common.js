function removeElementByQuery(query) {
  var element = document.querySelector(query)
  if (element) { element.parentNode.removeChild(element) }
}

function pxToNum(str) {
  return Number(str.replace('px', ''))
}

function loadHTML(file, cb) {
  var url = location.pathname+location.search
  const htmlTemplates = {
    openInWinstonBanner: `<div id="winstonBanner"> <img src="https://winston.cafe/james-webb.jpg" class="winstonBannerBg"><div class="logoHeyWrapper"> <img src="https://winston.cafe/side-winston-tinyfied.png"><div>Hey!</div></div><a href="winstonapp:/${url}" class="openInWinstonButton">Open in Winston!</a><button id="closeBannerButton" style="">X</button></div>`,
    helperBannerBase: `<div id="winston-api-helper"><div id="winston-api-helper-content-holder"> <img src="https://winston.cafe/side-winston-tinyfied.png" alt="Winston Logo"><h1 id="winston-helper-title">Hey!</h1><p id="winston-helper-body">I noticed you're generating an API.<br>I can help with that!</p><div id="winston-helper-buttons-holder"><button id="cancel-automate-winston-button" class="fullWidthWinstonBtn">Nah</button><button id="go-automate-winston-button" class="fullWidthWinstonBtn primary">Sure!</button></div><div id="winston-helper-existent-credentials"> </div></div><div class="progressView"><div class="spinner center"><div class="spinner-blade"></div><div class="spinner-blade"></div><div class="spinner-blade"></div><div class="spinner-blade"></div><div class="spinner-blade"></div><div class="spinner-blade"></div><div class="spinner-blade"></div><div class="spinner-blade"></div></div></div></div>`,
    existentCredential: (appName, appID) => `<button class="winstonExistentCredential"><div class="icon"> <img src="images/icon-credential.svg" alt=""> </div><div class="body"><div class="name">${appName}</div><div class="appID">${appID}</div></div></button>`
  }
  
  const foundTemplate = htmlTemplates[file]
  if (cb && foundTemplate) { cb(foundTemplate); }
}
