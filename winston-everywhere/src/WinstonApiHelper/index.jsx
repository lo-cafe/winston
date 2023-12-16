import { createRoot } from 'react-dom/client'
import HelperBanner from './components/HelperBanner'

const helperID = 'winston-api-helper-react-container'

const helperString = `<div id="${helperID}"></div>`

document.body.insertAdjacentHTML('beforeend', helperString)

const container = document.getElementById(helperID)
const root = createRoot(container)
root.render(<HelperBanner />)













