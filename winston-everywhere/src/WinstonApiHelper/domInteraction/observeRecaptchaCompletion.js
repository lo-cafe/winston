function observeRecaptchaCompletion(cb) {
  var response = document.querySelector("#g-recaptcha-response")
  if (!response || !response.value || response.value === "") {
    return setTimeout(() => observeRecaptchaCompletion(cb), 100)
  }
  setTimeout(() => {
    cb()
  }, 50)
}

export default observeRecaptchaCompletion
