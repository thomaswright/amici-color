open Common
open Types

let updateLchHGamutCanvas = (canvas, ctx, hue) => {
  let xMax = canvas->Canvas.getWidth
  let yMax = canvas->Canvas.getHeight

  // context->Canvas.clearRect(~x=0, ~y=0, ~w=xSize, ~h=ySize)

  for x in 0 to xMax {
    for y in 0 to yMax {
      let h = hue
      let l = x->Int.toFloat /. xMax->Int.toFloat
      let c = y->Int.toFloat /. yMax->Int.toFloat *. chromaBound
      let rgb = Texel.convert((l, c, h), Texel.oklch, Texel.srgb)

      if rgb->Texel.isRGBInGamut {
        ctx->Canvas.setFillStyle(Texel.rgbToHex(rgb))
        ctx->Canvas.fillRect(~x, ~y=yMax - y, ~w=1, ~h=1)
      }
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
  // Todo: update on hues change
  React.useEffect3(() => {
    switch canvasRef.current {
    | Value(canvasDom) =>
      let canvas = canvasDom->Obj.magic
      let context = canvas->Canvas.getContext("2d")

      switch hueObj {
      | Some(selectedHue) =>
        context->Canvas.scale(1. /. devicePixelRatio, 1. /. devicePixelRatio)
        canvas->Canvas.setWidth(xSizeScaled)
        canvas->Canvas.setHeight(ySizeScaled)

        updateLchHGamutCanvas(canvas, context, selectedHue.value)

      | None => context->Canvas.clearRect(~x=0, ~y=0, ~w=xSizeScaled, ~h=ySizeScaled)
      }
    | Null | Undefined => ()
    }

    None
  }, (
    canvasRef.current,
    selectedHue,
    selectedHue->Option.flatMap(selectedHue_ => hues->Array.find(hue => hue.id == selectedHue_)),
  ))

  <div className="w-fit relative bg-black rounded-sm">
    {hueObj->Option.mapOr(React.null, hue => {
      hue.elements
      ->Array.map(e => {
        let hsl = (hue.value, e.saturation, e.lightness)
        let (l, c, _h) = Texel.convert(hsl, Texel.okhsl, Texel.oklch)

        let hex = Texel.convert(hsl, Texel.okhsl, Texel.srgb)->Texel.rgbToHex

        <div
          className="absolute w-5 h-5 border border-black flex flex-row items-center justify-center"
          style={{
            backgroundColor: hex,
            bottom: (c /. chromaBound *. ySize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
            left: (l *. xSize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
          }}>
          {selectedElement->Option.mapOr(false, x => x == e.id)
            ? {"•"->React.string}
            : React.null}
        </div>
      })
      ->React.array
    })}
    <canvas
      style={{
        width: xSize->Int.toString ++ "px",
        height: ySize->Int.toString ++ "px",
      }}
      ref={ReactDOM.Ref.domRef(canvasRef)}
    />
  </div>
}
