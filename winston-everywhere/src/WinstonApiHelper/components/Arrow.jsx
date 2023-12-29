const Arrow = ({ pointingUp }) => {
  const position = pointingUp ? { top: "-27.4px" } : { bottom: "-27.4px" }
  return (
    <div
      className="arrowWinston"
      style={{ transform: `scaleX(1) rotate(${pointingUp ? "" : "-"}31deg)`, ...position }}
    ></div>
  )
}

export default Arrow


