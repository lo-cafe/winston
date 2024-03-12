function removeElementByQuery(query) {
  var element = document.querySelector(query)
  if (element) { element.parentNode.removeChild(element) }
}

function pxToNum(str) {
  return Number(str.replace('px', ''))
}
