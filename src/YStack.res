open Common
open Types

let size = 300
@react.component
let make = (~hues: array<hue>, ~selectedElement, ~view: view) => {
  <div
    className="flex flex-row gap-1 border-black border"
    style={{height: size->Int.toString ++ "px"}}>
    {hues
    ->Array.map(hue =>
      <div className="relative w-5">
        {hue.elements
        ->Array.map(e => {
          let hex =
            Texel.convert(
              (hue.value, e.saturation, e.lightness),
              Texel.okhsl,
              Texel.srgb,
            )->Texel.rgbToHex

          let percentage = switch view {
          | View_LC => {
              let (_, chroma, _) = Texel.convert(
                (hue.value, e.saturation, e.lightness),
                Texel.okhsl,
                Texel.oklch,
              )
              chroma /. chromaBound
            }
          | View_SV => {
              let (_, s, v) = Texel.convert(
                (hue.value, e.saturation, e.lightness),
                Texel.okhsl,
                Texel.okhsv,
              )
              s
            }
          | View_SL => e.saturation
          }

          <div
            className="absolute w-5 h-5 border border-black flex flex-col items-center justify-center"
            style={{
              backgroundColor: hex,
              transform: "translate(0, 50%)",
              bottom: (percentage *. size->Int.toFloat)
              ->Float.toInt
              ->Int.toString ++ "px",
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
