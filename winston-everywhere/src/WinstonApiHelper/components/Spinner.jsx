const Spinner = () => (
  <div className="spinner">
    {[...Array(8).keys()].map((x) => (
      <div key={`spinner-blade-{x}`} className="spinnerBlade"></div>
    ))}
  </div>
)

export default Spinner


