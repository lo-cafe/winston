import React, { useState, useEffect } from "react"

const MorphingStain = ({
  colors = ["#ee7752", "#e73c7e", "#23a6d5", "#23d5ab"],
  size,
  position = { top: null, bottom: null, left: null, right: null },
  baseOpacity = 0.9,
  style = {},
  ...props
}) => {
  const scaleVariation = 0.3
  const opacityVariation = 0.5
  const [scale, setScale] = useState(1 - Math.random() * scaleVariation)
  const [randomOpacity, setRandomOpacity] = useState(
    Math.max(0, baseOpacity - Math.random() * opacityVariation)
  )
  const [randomColor, setRandomColor] = useState(colors[Math.floor(Math.random() * colors.length)])
  const [transitionDuration, setTransitionDuration] = useState(3 - Math.random())

function randomize() {
  const newRandomScale = 1 - Math.random() * scaleVariation
  const newRandomOpacity = Math.max(0, baseOpacity - Math.random() * opacityVariation)
  setScale(newRandomScale)
  setRandomOpacity(newRandomOpacity)
  setRandomColor(
    (oldVal) => colors.filter((x) => x !== oldVal)[Math.floor(Math.random() * (colors.length - 1))]
  )
}

  useEffect(() => {
    randomize()
    setInterval(randomize, transitionDuration * 1000)
  }, [])

  const actualSize = size * (1 + scaleVariation / 2)
  const scaledSize = actualSize * scale

  function getPosition() {
    var pos = { top: null, left: null, right: null, bottom: null }
    var translateY = 0
    if (typeof position.top === "number") {
      pos.top = position.top - actualSize / 2
    } else if (typeof position.bottom === "number") {
      pos.bottom = position.bottom - actualSize / 2
    }
    if (typeof position.left === "number") {
      pos.left = position.left - actualSize / 2
    } else if (typeof position.right === "number") {
      pos.right = position.right - actualSize / 2
    }
    return pos
  }

  return (
    <div
      className="winsonStain"
      style={{
        width: actualSize,
        height: actualSize,
        borderRadius: actualSize / 2,
        ...getPosition(),
        transform: `scale(${scale})`,
        backgroundColor: randomColor,
        opacity: randomOpacity,
        transitionDuration: `${transitionDuration}s`,
      //   filter: "blur(150px)",
        ...style,
      }}
    />
  )
}

export default MorphingStain

















