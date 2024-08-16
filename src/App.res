// %%raw(`import "./other.js"`)
module Gamut = {
  @react.component @module("./other.jsx") external make: unit => React.element = "Gamut"
}

@react.component
let make = () => {
  <div className="p-6">
    <Gamut />
  </div>
}
