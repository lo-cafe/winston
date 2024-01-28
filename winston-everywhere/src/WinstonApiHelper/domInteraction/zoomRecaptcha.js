function zoomRecaptcha() {
  var recaptchaChild = document.querySelector(".c-form-group.g-recaptcha").children[0]
  const recaptchaRect = recaptchaChild.getBoundingClientRect()
  const recaptchaScaledPadding = 32
  const scale = (window.innerWidth - recaptchaScaledPadding * 2) / recaptchaRect.width
  const scaledHeight = recaptchaRect.height * scale
  const recaptchaRectCenterY = recaptchaRect.top + recaptchaRect.height / 2
  const recaptchaScaledTop = recaptchaRectCenterY - scaledHeight / 2
  const recaptchaBottomHeight = window.innerHeight - (recaptchaScaledTop + scaledHeight)
  recaptchaChild.style.transform = `scale(${scale})`
  var recaptchaRectCenterX = recaptchaRect.left + recaptchaRect.width / 2
  var outBounds = recaptchaRectCenterX - (recaptchaRect.width / 2) * scale

  recaptchaChild.style.position = "relative"
  recaptchaChild.style.right = `${outBounds - recaptchaScaledPadding}px`
  recaptchaChild.style.zIndex = 999999999

  return { scaledHeight, recaptchaScaledTop, recaptchaBottomHeight }
}

export function unzoomRecaptcha() {
  var recaptchaChild = document.querySelector(".c-form-group.g-recaptcha").children[0]
  if (recaptchaChild) {
    recaptchaChild.style.removeProperty("position")
    recaptchaChild.style.removeProperty("right")
    recaptchaChild.style.removeProperty("z-index")
    recaptchaChild.style.removeProperty("transform")
  }
}

export default zoomRecaptcha
