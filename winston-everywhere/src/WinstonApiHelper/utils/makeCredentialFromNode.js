const makeCredentialFromNode = (domNode) => {
  if (!domNode?.querySelector) {
    return null
  }
  const ourAppDetails = Array.from(domNode.querySelector(".app-details").children)
  const info = Array.from(domNode.querySelectorAll(".app-details h3"))
  const name = domNode.querySelector(".app-details h2 a").innerText
  const type = info[0].innerText
  const appID = info[1].innerText
  const appSecret = domNode.querySelector(".prefright").innerHTML
  return { name, type, appID, appSecret, domNode }
}

export default makeCredentialFromNode
