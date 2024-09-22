open Common
open Types

let size = 300
@react.component
let make = (~hues: array<hue>, ~selectedElement, ~view: view) => {
  <div
    className="flex flex-col gap-1 border-black border" style={{width: size->Int.toString ++ "px"}}>
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
            className="absolute w-5 h-5 border border-black flex flex-row items-center justify-center"
            style={{
              backgroundColor: hex,
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
}
