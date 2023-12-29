import makeCredentialFromNode from '../utils/makeCredentialFromNode';

const getCredentials = () => {
  const creds = Array.from(window.document.querySelector("#developed-apps ul").children).map(makeCredentialFromNode)
  return creds
}

export default getCredentials
