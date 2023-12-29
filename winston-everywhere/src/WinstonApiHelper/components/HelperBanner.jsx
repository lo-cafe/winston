import react, { useEffect, useState } from "react"
import { motion, LayoutGroup, MotionConfig } from "framer-motion"
import { IoMdAdd } from "@react-icons/all-files/io/IoMdAdd"
import { CgClose } from "@react-icons/all-files/cg/CgClose"

import getCredentials from "../domInteraction/getCredentials"
import fillWinstonApp from "../domInteraction/fillWinstonApp"
import zoomRecaptcha from "../domInteraction/zoomRecaptcha"
import submitCreateAppForm from "../domInteraction/submitCreateAppForm"
import selectCredential from "../utils/selectCredential"
import makeCredentialFromNode from "../utils/makeCredentialFromNode"
import useQueryWatcher from "../hooks/useQueryWatcher"
import BGDimmer from "./BGDimmer"
import Spinner from "./Spinner"
import CredentialItem from "./CredentialItem"
import Arrow from "./Arrow"

import "./HelperBanner.scss"

const spring = {
  type: "spring",
  stiffness: 100,
  damping: 17,
}

const HelperBanner = () => {
  const [showUp, setshowUp] = useState(false)
  const [showSpinner, setShowSpinner] = useState(false)

  const [credentials, lastAddedCredentials, lastRemovedCredentials, setIsWatchingCreds] = useQueryWatcher(
    "#developed-apps ul li.developed-app:not([style*='display: none'])",
    makeCredentialFromNode
  )
  const [gCaptchaIsFilled, , , setIsWatchingGCaptcha] = useQueryWatcher(
    "#g-recaptcha-response",
    (x) => x?.value !== null && x?.value !== "",
    (arr) => !!arr && arr[0] === true,
    false
  )

  const [highlightedCredential, setHighlightedCredential] = useState(null)
  const [presentNextAddedCredential, setPresentNextAddedCredential] = useState(false)
  const [showCredentials, setShowCredentials] = useState(false)
  const [dimBG, setDimBG] = useState(false)
  const [title, setTitle] = useState("Hey!")
  const [description, setDescription] = useState("I noticed you're generating an API. I can help with that!")
  const [arrowPointingUp, setArrowPointingUp] = useState(null)
  const [buttons, setButtons] = useState(null)
  const [positionBanner, setPositionBanner] = useState({ bottom: "-100%" })

  function createNewCredential() {
    setTitle("Ok so, here's the plan")
    setDescription("I'll create an API key for you. All you have to do is click the button below!")
    setShowCredentials(false)
    setArrowPointingUp(null)
    setButtons({
      primary: {
        label: "Let's do it!",
        fn: () => {
          fillWinstonApp()
          setTimeout(() => {
            setButtons(null)
            pointToCaptcha()
          }, 100)
        },
      },
    })
  }

  function pointToCaptcha() {
    setPresentNextAddedCredential(true)
    setTitle("Almost there!")
    setDescription(
      "The page is ugly back there, so we made recaptcha bigger for you. Tick it and I'll take care of the rest."
    )

    const { scaledHeight, recaptchaScaledTop, recaptchaBottomHeight } = zoomRecaptcha()

    const showHelperOnBottom = recaptchaBottomHeight > recaptchaScaledTop

    setArrowPointingUp(showHelperOnBottom)

    if (showHelperOnBottom) {
      setPositionBanner({ top: `${recaptchaScaledTop + scaledHeight - 24}px` })
    } else {
      setPositionBanner({ bottom: `${recaptchaBottomHeight + 24}px` })
    }
  }

  function presentNewCredential(cred) {
    setTitle("Yay!")
    setDescription(
      "Here's your new API key. Now you just have to click the button below and I'll take you back to the app."
    )
    setHighlightedCredential(cred)
    setButtons({
      primary: {
        label: "Nice, take me back!",
        fn: () => useExistingCredential(cred),
      },
    })
    repositionOnBottom()
  }

  function startHelping(altCreds) {
    if (!altCreds) return
    setButtons(null)
    const usefulCredentials = altCreds.filter((cred) => cred.type == "web app")
    if (altCreds.length == 0) {
      createNewCredential()
    } else {
      setShowCredentials(true)
      if (altCreds.length >= 3) {
        if (usefulCredentials.length == 0) {
          setTitle("Oops!")
          setDescription(
            "Reddit only allows 3 API keys per account, however, none of your keys are of the right type. Do you want to delete one of them so we can create the right key type?"
          )
        } else {
          setTitle("Well...")
          setDescription(
            "Unfortunately, Reddit only allows 3 API keys per account, and you already have 3. Do you want to use one of your existing keys?"
          )
        }
      } else {
        if (usefulCredentials.length == 0) {
          setTitle("Ok so, here's the plan")
          setDescription("I'll create an API key for you. All you have to do is click the button below!")
        } else {
          setTitle("Oh!")
          setDescription(
            `It looks like you already have ${
              usefulCredentials.length == 1 ? "one API key" : `a few API keys`
            } that could be reused. Do you want to reuse one of them?`
          )
        }
      }
    }
  }

  function repositionOnBottom() {
    setPositionBanner({ bottom: 32 })
    setArrowPointingUp(null)
  }

  function dismiss() {
    if (confirm("Are you sure you want to dismiss Winston API keys assistant?")) {
      setIsWatchingCreds(false)
      setIsWatchingGCaptcha(false)
      setDimBG(false)
      setPositionBanner({ bottom: "-100%" })
    }
  }

  function useExistingCredential(credential) {
    selectCredential(credential)
  }

  function deleteExistingCredential(credential) {
    credential.domNode.querySelector(".edit-app-button").click()
    credential.domNode.querySelector(".deleteapp-button a").click()
    credential.domNode.querySelector(".deleteapp-button a.yes").click()
  }

  function setInitialButtons(credentials) {
    setButtons({
      primary: {
        label: "Sure!",
        fn: (creds) => startHelping(creds),
      },
      secondary: {
        label: "Nah",
        fn: dismiss,
      },
    })
  }

  useEffect(() => {
    setTimeout(() => {
      setIsWatchingCreds(true)
      setIsWatchingGCaptcha(true)
      setInitialButtons()
      repositionOnBottom()
      setDimBG(true)
    }, 100)
    return () => {
      setIsWatchingCreds(false)
      setIsWatchingGCaptcha(false)
    }
  }, [])

  useEffect(() => {
    if (gCaptchaIsFilled) {
      submitCreateAppForm()
    }
  }, [gCaptchaIsFilled])

  useEffect(() => {
    if (
      presentNextAddedCredential &&
      Array.isArray(lastAddedCredentials) &&
      lastAddedCredentials.length > 0
    ) {
      presentNewCredential(lastAddedCredentials[0])
    }
  }, [lastAddedCredentials])

  const actuallyShowCredentials = showCredentials && !!credentials && credentials.length > 0
  return (
    <>
      <BGDimmer dimBG={dimBG} />
      <MotionConfig transition={spring}>
        <motion.div layout style={{ borderRadius: 118, ...positionBanner }} className="wrapperWinston">
          <motion.div style={{ borderRadius: 118 }} className="winstonContent">
            <motion.img
              layout="position"
              layoutId="logo"
              src="https://winston.cafe/side-winston-tinyfied.png"
              alt="Winston Logo"
            />
            <motion.div layout="position">
              <h1>{title}</h1>
              <p>{description}</p>
            </motion.div>

            {(actuallyShowCredentials || !!highlightedCredential) && (
              <motion.div layout className="existentCredentialsWrapper">
                <LayoutGroup id="items-pack">
                  {actuallyShowCredentials &&
                    credentials.map((cred) => (
                      <CredentialItem
                        key={`winston-${cred.appID}`}
                        credential={cred}
                        use={useExistingCredential}
                        del={deleteExistingCredential}
                        setSpinner={setShowSpinner}
                      />
                    ))}
                  {actuallyShowCredentials && credentials.length < 3 && (
                    <button className="fullWidthWinstonBtn" onClick={createNewCredential}>
                      <IoMdAdd />
                      Create new API key
                    </button>
                  )}
                  {!!highlightedCredential && <CredentialItem credential={highlightedCredential} />}
                </LayoutGroup>
              </motion.div>
            )}

            {!!buttons && (
              <motion.div layout="position" className="buttonsHolder">
                {buttons.secondary && (
                  <button
                    className="fullWidthWinstonBtn"
                    onClick={() => buttons.secondary.fn(credentials)}
                    id={`button-secondary-${buttons.secondary.label}`}
                  >
                    {buttons.secondary.label}
                  </button>
                )}
                {buttons.primary && (
                  <button
                    className="fullWidthWinstonBtn primary"
                    onClick={() => buttons.primary.fn(credentials)}
                    id={`button-primary-${buttons.primary.label}`}
                  >
                    {buttons.primary.label}
                  </button>
                )}
              </motion.div>
            )}
          </motion.div>
          {showSpinner && <Spinner />}
          {arrowPointingUp !== null && <Arrow pointingUp={arrowPointingUp} />}
          <motion.button layout="position" className="closeButton" onClick={dismiss}>
            <CgClose />
          </motion.button>
        </motion.div>
      </MotionConfig>
    </>
  )
}

export default HelperBanner









