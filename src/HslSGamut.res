open Common
open Types

let updateHslSGamutCanvas = (canvas, ctx) => {
  let xMax = canvas->Canvas.getWidth
  let yMax = canvas->Canvas.getHeight

  // context->Canvas.clearRect(~x=0, ~y=0, ~w=xSize, ~h=ySize)

  for x in 0 to xMax {
    for y in 0 to yMax {
      let h = y->Int.toFloat /. yMax->Int.toFloat *. 360.
      let l = x->Int.toFloat /. xMax->Int.toFloat
      let s = 0.0
      let rgb = Texel.convert((h, s, l), Texel.okhsl, Texel.srgb)

      ctx->Canvas.setFillStyle(Texel.rgbToHex(rgb))
      ctx->Canvas.fillRect(~x, ~y, ~w=1, ~h=1)
    }
  }

  ()
}

let xSize = 300
let ySize = 300
let xSizeScaled = (xSize->Int.toFloat *. devicePixelRatio)->Float.toInt
let ySizeScaled = (ySize->Int.toFloat *. devicePixelRatio)->Float.toInt

@react.component
let make = (~hues: array<hue>, ~selectedHue, ~selectedElement) => {
  let canvasRef = React.useRef(Nullable.null)
  let hueObj = selectedHue->Option.flatMap(s => hues->Array.find(v => v.id == s))

  React.useEffect3(() => {
    switch canvasRef.current {
    | Value(canvasDom) =>
      let canvas = canvasDom->Obj.magic
      let context = canvas->Canvas.getContext("2d")

      switch hueObj {
      | Some(_) =>
        context->Canvas.scale(1. /. devicePixelRatio, 1. /. devicePixelRatio)
        canvas->Canvas.setWidth(xSizeScaled)
        canvas->Canvas.setHeight(ySizeScaled)
        updateHslSGamutCanvas(canvas, context)

      | None => context->Canvas.clearRect(~x=0, ~y=0, ~w=xSize, ~h=ySize)
      }
    | Null | Undefined => ()
    }

    None
  }, (
    canvasRef.current,
    selectedHue,
    selectedHue->Option.flatMap(selectedHue_ => hues->Array.find(hue => hue.id == selectedHue_)),
  ))

  <div className="w-fit relative border border-black rounded-sm">
    {selectedHue->Option.isNone
      ? React.null
      : {
          hues
          ->Array.map(hue =>
            hue.elements->Array.map(e => {
              let hex =
                Texel.convert(
                  (hue.value, e.saturation, e.lightness),
                  Texel.okhsl,
                  Texel.srgb,
                )->Texel.rgbToHex

              <div
                className="absolute w-5 h-5 border border-black flex flex-row items-center justify-center"
                style={{
                  backgroundColor: hex,
                  left: (e.lightness *. ySize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
                  top: (hue.value /. 360. *. xSize->Int.toFloat)
                  ->Float.toInt
                  ->Int.toString ++ "px",
                }}>
                {selectedElement->Option.mapOr(false, x => x == e.id)
                  ? {"•"->React.string}
                  : React.null}
              </div>
            })
          )
          ->Belt.Array.concatMany
          ->React.array
        }}
    <canvas
      style={{
        width: xSize->Int.toString ++ "px",
        height: ySize->Int.toString ++ "px",
      }}
      ref={ReactDOM.Ref.domRef(canvasRef)}
    />
  </div>
}
