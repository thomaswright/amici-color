open Common
open Types

let size = 300
@react.component
let make = (
  ~hues: array<hue>,
  ~selectedElement,
  ~view: view,
  ~setSelectedElement,
  ~setSelectedHue,
) => {
  <div className="p-3 bg-black w-fit pt-0">
    <div
      className="flex flex-col gap-1 py-1 bg-white rounded"
      style={{width: size->Int.toString ++ "px"}}>
      {hues
      ->Array.map(hue =>
        <div className="relative h-5">
          {hue.elements
          ->Array.map(e => {
            let hex =
              Texel.convert(
                (hue.value, e.saturation, e.lightness),
                Texel.okhsl,
                Texel.srgb,
              )->Texel.rgbToHex

            let percentage = switch view {
            | View_LC => e.lightness
            | View_SV => {
                let (_, _, v) = Texel.convert(
                  (hue.value, e.saturation, e.lightness),
                  Texel.okhsl,
                  Texel.okhsv,
                )
                v
              }
            | View_SL => e.lightness
            }

            <div
              onClick={_ => {
                setSelectedElement(_ => Some(e.id))
                setSelectedHue(_ => Some(hue.id))
              }}
              className="absolute w-5 h-5 border border-black flex flex-row items-center justify-center cursor-pointer select-none"
              style={{
                backgroundColor: hex,
                transform: "translate(-50%, 0)",
                left: (percentage *. size->Int.toFloat)->Float.toInt->Int.toString ++ "px",
              }}>
              {selectedElement->Option.mapOr(false, x => x == e.id)
                ? {"•"->React.string}
                : React.null}
            </div>
          })
          ->React.array}
        </div>
      )
      ->React.array}
    </div>
    <div className="text-white h-4 font-medium text-center">
      {switch view {
      | View_LC => "lightness"
      | View_SL => "lightness"
      | View_SV => "value"
      }->React.string}
    </div>
  </div>
}
