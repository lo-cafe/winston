function fillWinstonApp() {
  document.getElementById("create-app-button").click()
  document.querySelector("#create-app input[name=name]").value = "Winston"
  document.querySelector("#app_type_web").checked = true
  document.querySelector("#create-app textarea[name=description]").value =
    "A developer's tool for devs to test their API keys."
  document.querySelector("#create-app input[name=about_url]").value = "https://winston.cafe"
  document.querySelector("#create-app input[name=redirect_uri]").value =
    "https://app.winston.cafe/auth-success"
  const recaptchaEl = document.querySelector(".c-form-group.g-recaptcha")
  recaptchaEl.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" })
  recaptchaEl.focus()
}

export default fillWinstonApp
