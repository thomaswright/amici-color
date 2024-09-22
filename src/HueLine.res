open Common
open Types

let updateHueLineCanvas = (canvas, ctx) => {
  let _xMax = canvas->Canvas.getWidth
  let yMax = canvas->Canvas.getHeight

  for y in 0 to yMax {
    let rgb = Texel.convert(
      (y->Int.toFloat /. yMax->Int.toFloat *. 360., 1.0, 1.0),
      Texel.okhsv,
      Texel.srgb,
    )
    ctx->Canvas.setFillStyle(Texel.rgbToHex(rgb))
    ctx->Canvas.fillRect(~x=0, ~y, ~w=yMax, ~h=1)
  }

  // ctx->Canvas.setFillStyle("#000")

  // hues->Array.forEach(hue => {
  //   ctx->Canvas.fillRect(~x=(hue /. 360. *. xMax->Int.toFloat)->Float.toInt, ~y=0, ~w=10, ~h=10)
  // })

  ()
}

let xSize = 20
let ySize = 300
let xSizeScaled = (xSize->Int.toFloat *. devicePixelRatio)->Float.toInt
let ySizeScaled = (ySize->Int.toFloat *. devicePixelRatio)->Float.toInt

@react.component
let make = (~hues: array<hue>, ~selected) => {
  let canvasRef = React.useRef(Nullable.null)
  // let huesComparison = hues->Array.reduce("", (a, c) => {a ++ c->Float.toString})
  React.useEffect1(() => {
    switch canvasRef.current {
    | Value(canvasDom) => {
        let canvas = canvasDom->Obj.magic
        let context = canvas->Canvas.getContext("2d")
        context->Canvas.scale(1. /. devicePixelRatio, 1. /. devicePixelRatio)
        canvas->Canvas.setWidth(xSizeScaled)
        canvas->Canvas.setHeight(ySizeScaled)
        updateHueLineCanvas(canvas, context)
      }
    | Null | Undefined => ()
    }

    None
  }, [canvasRef.current])

  <div className="w-fit relative h-full rounded-sm overflow-hidden">
    {hues
    ->Array.map(hue => {
      <div
        className={[
          "w-3 h-3 absolute border-black rounded-full",
          selected->Option.mapOr(false, s => s == hue.id) ? "border-4" : "border ",
        ]->Array.join(" ")}
        style={{
          left: "0.25rem",
          top: (hue.value /. 360. *. ySize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
        }}
      />
    })
    ->React.array}
    <canvas
      style={{
        width: xSize->Int.toString ++ "px",
        height: ySize->Int.toString ++ "px",
      }}
      ref={ReactDOM.Ref.domRef(canvasRef)}
    />
  </div>
}
