import MorphingStain from "./MorphingStain"

const BGDimmer = ({ dimBG }) => {
  return (
    <div className="winstonBlurMask" style={{ opacity: dimBG ? 1 : 0 }}>
      <div className="winHelper">
        <MorphingStain
          size={1000}
          colors={["#FFB6C1", "#FFC0CB", "#FF69B4", "#FF1493"]}
          position={{ top: 0, left: 0 }}
        />
        <MorphingStain
          size={800}
          colors={["#FF8C00", "#ADD8E6", "#FFA07A", "#AFEEEE"]}
          position={{ top: 0, left: 70 }}
        />
        <MorphingStain
          size={1200}
          colors={["#87CEFA", "#90EE90", "#00FF7F", "#7CFC00"]}
          position={{ top: 120, left: 0 }}
        />
        <MorphingStain
          size={1050}
          colors={["#FFDAB9", "#FFE4B5", "#8ba9e0", "#FF7F50"]}
          position={{ top: 0, right: 0 }}
        />
        <MorphingStain
          size={850}
          colors={["#F0E68C", "#FFD700", "#ADD8E6", "#98FB98"]}
          position={{ top: 35, right: 0 }}
        />
        <MorphingStain
          size={1000}
          colors={["#87CEFA", "#FFA500", "#B0E0E6", "#AFEEEE"]}
          position={{ top: 0, right: 150 }}
        />
        />
        <MorphingStain
          size={2500}
          colors={["#87CEFA", "#FFE4B5", "#FF7F50", "#f08d8d"]}
          position={{ top: 0, right: window.innerWidth / 2 }}
          baseOpacity={0.5}
        />
      </div>
    </div>
  )
}

export default BGDimmer



