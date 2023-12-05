function selectCredential(cred) {
   window.location.assign(`https://app.winston.cafe/?appID=${cred.appID}&appSecret=${cred.appSecret}`)
}

export default selectCredential
