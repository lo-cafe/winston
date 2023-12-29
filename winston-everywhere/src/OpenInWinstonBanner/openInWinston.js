loadHTML('openInWinstonBanner', (openInWinstonBanner) => {
  document.body.insertAdjacentHTML('beforeend', openInWinstonBanner);
  setTimeout(() => {
    document.getElementById('closeBannerButton').addEventListener('click', function() {
      removeElementByQuery('#winstonBanner')
    });
  }, 100);
})
