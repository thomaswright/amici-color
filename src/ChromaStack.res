open Common
open Types

let ySize = 300
@react.component
let make = (~hues: array<hue>, ~selectedElement) => {
  <div
    className="flex flex-row gap-1 border-black border"
    style={{height: ySize->Int.toString ++ "px"}}>
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

          let (_, chroma, _) = Texel.convert(
            (hue.value, e.saturation, e.lightness),
            Texel.okhsl,
            Texel.oklch,
          )
          <div
            className="absolute w-5 h-5 border border-black flex flex-col items-center justify-center"
            style={{
              backgroundColor: hex,
              bottom: (chroma /. chromaBound *. ySize->Int.toFloat)
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
