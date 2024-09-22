open Common

@react.component
let make = () => {
  <div>
    {Utils.mapRange(36, i => {
      let hue = (i * 10)->Int.toFloat
      <div className="flex flex-row">
        <div
          className={"w-4 h-4"}
          style={{
            backgroundColor: Texel.rgbToHex(
              Texel.convert((hue, 1.0, 1.0), Texel.okhsv, Texel.srgb),
            ),
          }}
        />
        {hue->hueToName->React.string}
      </div>
    })->React.array}
  </div>
}
