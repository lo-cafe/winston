import { useState, useEffect } from "react"
import { HiMiniTrash } from "@react-icons/all-files/hi2/HiMiniTrash"
// import { HiMiniTrash } from "react-icons/hi2"
import { GiHouseKeys } from "@react-icons/all-files/gi/GiHouseKeys"
// import { GiHouseKeys } from "react-icons/gi"
import { PiKeyFill } from "@react-icons/all-files/pi/PiKeyFill"
// import { PiKeyFill } from "react-icons/pi"
import { motion } from "framer-motion"

const CredentialItem = ({ credential, del, use, setSpinner }) => {
  const [confirmingDelete, setConfirmingDelete] = useState(false)
  function delCred() {
    if (!confirmingDelete) {
      setConfirmingDelete(true)
      return
    }
    if (setSpinner) {
      setSpinner(true)
    }
    if (del) {
      del(credential)
    }
  }

  const useCred = () => {
    if (use) {
      use(credential)
    }
  }

  useEffect(
    () => () => {
      if (setSpinner) {
        setSpinner(false)
      }
    },
    []
  )

  useEffect(() => {
    if (confirmingDelete) {
      setTimeout(() => {
        setConfirmingDelete(false)
      }, 1500)
    }
  }, [confirmingDelete])

  const { name, appID, appSecret } = credential
  const bordered = !del && !use
  return (
    // <></>
    <motion.div layout="position" className={`existentCredential${bordered ? " bordered" : ""}`}>
      <GiHouseKeys />
      <div className="body">
        <div className="name">{name}</div>
        <div className="appID">{appID.substring(0, 16)}...</div>
      </div>
      <div className="btnsWrapper">
        {!!del && (
          <div className="deleteWrapper">
            <motion.button layout onClick={delCred} style={{ borderRadius: 100 }} className="delete">
              <motion.span layout="position">
                <HiMiniTrash />
              </motion.span>
              {confirmingDelete ? <motion.span layout="position">Sure?</motion.span> : ""}
            </motion.button>
          </div>
        )}
        {!!use && <button onClick={useCred}>Use</button>}
      </div>
    </motion.div>
  )
}

export default CredentialItem







