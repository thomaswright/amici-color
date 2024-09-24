open Common
open Types

let updateHueLineCanvas = (canvas, ctx) => {
  let xMax = canvas->Canvas.getWidth
  let _yMax = canvas->Canvas.getHeight

  for x in 0 to xMax {
    let rgb = Texel.convert(
      (x->Int.toFloat /. xMax->Int.toFloat *. 360., 1.0, 1.0),
      Texel.okhsv,
      Texel.srgb,
    )
    ctx->Canvas.setFillStyle(Texel.rgbToHex(rgb))
    ctx->Canvas.fillRect(~x, ~y=0, ~w=1, ~h=xMax)
  }

  // ctx->Canvas.setFillStyle("#000")

  // hues->Array.forEach(hue => {
  //   ctx->Canvas.fillRect(~x=(hue /. 360. *. xMax->Int.toFloat)->Float.toInt, ~y=0, ~w=10, ~h=10)
  // })

  ()
}

let xSize = 300
let ySize = 20
let xSizeScaled = (xSize->Int.toFloat *. devicePixelRatio)->Float.toInt
let ySizeScaled = (ySize->Int.toFloat *. devicePixelRatio)->Float.toInt

@react.component
let make = (~hues: array<hue>, ~selectedHue, ~setSelectedHue, ~onDragTo) => {
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

  let isDragging = React.useRef(false)
  let dragPos = React.useRef(None)
  let dragId = React.useRef(None)
  let gamutEl = React.useRef(Nullable.null)

  let drag = clientX => {
    switch (gamutEl.current, dragId.current) {
    | (Value(dom), Some(id)) => {
        let gamutRect = dom->getBoundingClientRect

        let gamutX = gamutRect["left"]

        let x = (clientX - gamutX)->Int.toFloat->Math.max(0.)->Math.min(xSize->Int.toFloat)

        onDragTo(id, x /. xSize->Int.toFloat)
      }

    | _ => ()
    }
  }

  React.useEffect0(() => {
    let onMouseMove = event => {
      if !isDragging.current {
        ()
      } else {
        drag(event->ReactEvent.Mouse.clientX)
      }
    }
    let onTouchMove = event => {
      if !isDragging.current {
        ()
      } else {
        event
        ->ReactEvent.Touch.touches
        ->Obj.magic
        ->Array.get(0)
        ->Option.mapOr((), touch => drag(touch["clientX"]))
      }
    }

    let onTouchEnd = _ => {
      isDragging.current = false
      dragPos.current = None
      dragId.current = None
    }
    let onMouseUp = _ => {
      isDragging.current = false
      dragPos.current = None
      dragId.current = None
    }

    addMouseListner("mousemove", onMouseMove)
    addTouchListner("touchmove", onTouchMove)
    addTouchListner("touchend", onTouchEnd)
    addMouseListner("mouseup", onMouseUp)
    Some(
      () => {
        removeMouseListner("mousemove", onMouseMove)
        removeTouchListner("touchmove", onTouchMove)
        removeTouchListner("touchend", onTouchEnd)
        removeMouseListner("mouseup", onMouseUp)
      },
    )
  })

  <div className="p-5">
    <div className="w-fit rounded-sm" ref={ReactDOM.Ref.domRef(gamutEl)}>
      <div className="h-5 relative w-full">
        {hues
        ->Array.map(hue => {
          let hex = Texel.convert((hue.value, 1.0, 1.0), Texel.okhsv, Texel.srgb)->Texel.rgbToHex
          let isSelected = selectedHue->Option.mapOr(false, s => s == hue.id)

          <div
            key={hue.id}
            className="absolute w-5 h-5 border border-black flex flex-row items-center justify-center cursor-pointer select-none"
            style={{
              backgroundColor: hex,
              transform: "translate(-50%, 0)",
              left: (hue.value /. 360. *. xSize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
              top: "0.25rem",
            }}
            onMouseDown={_ => {
              isDragging.current = true
              dragPos.current = None
              dragId.current = Some(hue.id)
              setSelectedHue(_ => Some(hue.id))
            }}
            onTouchStart={_ => {
              isDragging.current = true
              dragPos.current = None
              dragId.current = Some(hue.id)
            }}>
            {isSelected ? {"•"->React.string} : React.null}
          </div>
        })
        ->React.array}
      </div>
      <canvas
        style={{
          width: xSize->Int.toString ++ "px",
          height: ySize->Int.toString ++ "px",
        }}
        ref={ReactDOM.Ref.domRef(canvasRef)}
      />
    </div>
  </div>
}
