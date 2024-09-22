open Common
open Types

let updateCanvas = (canvas, ctx, hue, view) => {
  let xMax = canvas->Canvas.getWidth
  let yMax = canvas->Canvas.getHeight

  // context->Canvas.clearRect(~x=0, ~y=0, ~w=xSize, ~h=ySize)

  for x in 0 to xMax {
    for y in 0 to yMax {
      let h = hue
      let xVal = x->Int.toFloat /. xMax->Int.toFloat
      let yVal = y->Int.toFloat /. yMax->Int.toFloat

      let rgb = switch view {
      | View_LC => Texel.convert((xVal, yVal *. chromaBound, h), Texel.oklch, Texel.srgb)
      | View_SL => Texel.convert((h, yVal, xVal), Texel.okhsl, Texel.srgb)
      | View_SV => Texel.convert((h, xVal, yVal), Texel.okhsv, Texel.srgb)
      }

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

module CanvasComp = {
  @react.component
  let make = (~hueObj, ~view) => {
    Console.log("Render Canvas")
    let canvasRef = React.useRef(Nullable.null)

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

          updateCanvas(canvas, context, selectedHue.value, view)

        | None => context->Canvas.clearRect(~x=0, ~y=0, ~w=xSizeScaled, ~h=ySizeScaled)
        }
      | Null | Undefined => ()
      }

      None
    }, (view, canvasRef.current, hueObj->Option.mapOr(0., v => v.value)))

    <canvas
      style={{
        width: xSize->Int.toString ++ "px",
        height: ySize->Int.toString ++ "px",
      }}
      ref={ReactDOM.Ref.domRef(canvasRef)}
    />
  }

  let make = React.memoCustomCompareProps(make, (a, b) => {
    a.view == b.view &&
      switch (a.hueObj, b.hueObj) {
      | (Some(a_), Some(b_)) => a_.id == b_.id && a_.value == b_.value
      | (None, None) => true
      | _ => false
      }
  })
}

@react.component
let make = (
  ~hues: array<hue>,
  ~selectedHue,
  ~selectedElement,
  ~view: view,
  ~setSelectedElement,
) => {
  let hueObj = selectedHue->Option.flatMap(s => hues->Array.find(v => v.id == s))

  <div className="p-3 bg-black">
    <CanvasComp hueObj view />
    <div className="w-fit relative bg-black rounded-sm">
      {hueObj->Option.mapOr(React.null, hue => {
        hue.elements
        ->Array.map(e => {
          let hsl = (hue.value, e.saturation, e.lightness)

          let hex = Texel.convert(hsl, Texel.okhsl, Texel.srgb)->Texel.rgbToHex
          let (xPer, yPer) = switch view {
          | View_LC => {
              let (l, c, _h) = Texel.convert(hsl, Texel.okhsl, Texel.oklch)
              (l, c /. chromaBound)
            }
          | View_SL => (e.lightness, e.saturation)
          | View_SV => {
              let (_, s, v) = Texel.convert(
                (hue.value, e.saturation, e.lightness),
                Texel.okhsl,
                Texel.okhsv,
              )
              (v, s)
            }
          }

          <div
            onClick={_ => {setSelectedElement(_ => Some(e.id))}}
            className="absolute w-5 h-5 border border-black flex flex-row items-center justify-center cursor-pointer"
            style={{
              backgroundColor: hex,
              transform: "translate(-50%, 50%)",
              left: (xPer *. xSize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
              bottom: (yPer *. ySize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
            }}>
            {selectedElement->Option.mapOr(false, x => x == e.id)
              ? {"•"->React.string}
              : React.null}
          </div>
        })
        ->React.array
      })}
    </div>
  </div>
}
