// %%raw(`import "./other.js"`)

module Utils = {
  let mapRange = (n, f) => {
    Array.make(~length=n, 0)->Array.mapWithIndex((_, i) => {
      f(i)
    })
  }
}
module Gamut = {
  @react.component @module("./other.jsx") external make: unit => React.element = "Gamut"
}

type element = {
  id: string,
  hueId: string,
  hex: string,
}

type row = {
  hueId: string,
  elements: array<element>,
}

module Texel = {
  type triple = (float, float, float)
  type texelType

  @module("@texel/color") external okhsv: texelType = "OKHSV"
  @module("@texel/color") external okhsl: texelType = "OKHSL"
  @module("@texel/color") external oklch: texelType = "OKLCH"
  @module("@texel/color") external srgb: texelType = "sRGB"

  @module("@texel/color") external rgbToHex: triple => string = "RGBToHex"
  @module("@texel/color") external convert: (triple, texelType, texelType) => triple = "convert"
}

let makeDefaultPalette = (xLen, yLen) => {
  let xLenF = xLen->Int.toFloat
  let yLenF = yLen->Int.toFloat

  Utils.mapRange(xLen, x => {
    let xF = x->Int.toFloat
    let elements = Utils.mapRange(yLen, y => {
      let yF = y->Int.toFloat
      let hex = Texel.rgbToHex(
        Texel.convert((xF /. xLenF *. 360., (yF +. 1.) /. yLenF, 1.0), Texel.okhsv, Texel.srgb),
      )
      {
        id: y->Int.toString ++ x->Int.toString,
        hueId: x->Int.toString,
        hex,
      }
    })
    {
      hueId: x->Int.toString,
      elements,
    }
  })
}

module Canvas = {
  type canvas
  type context

  @send
  external fillRect: (context, ~x: int, ~y: int, ~w: int, ~h: int) => unit = "fillRect"
  @set external setFillStyle: (context, string) => unit = "fillStyle"
  @get external getWidth: canvas => int = "width"
  @get external getHeight: canvas => int = "height"
  @set external setWidth: (canvas, int) => unit = "width"
  @set external setHeight: (canvas, int) => unit = "height"
  @send external getContext: (canvas, string) => context = "getContext"
}

let updateHueLineCanvas = (canvas, ctx) => {
  let xMax = canvas->Canvas.getWidth
  let yMax = canvas->Canvas.getHeight

  for x in 0 to xMax {
    let rgb = Texel.convert(
      (x->Int.toFloat /. xMax->Int.toFloat *. 360., 1.0, 1.0),
      Texel.okhsv,
      Texel.srgb,
    )
    ctx->Canvas.setFillStyle(Texel.rgbToHex(rgb))
    ctx->Canvas.fillRect(~x, ~y=0, ~w=1, ~h=yMax)
  }

  ()
}

let size = 500

module HueLine = {
  @react.component
  let make = () => {
    let canvasRef = React.useRef(Nullable.null)

    React.useEffect1(() => {
      switch canvasRef.current {
      | Value(canvasDom) => {
          let canvas = canvasDom->Obj.magic
          let context = canvas->Canvas.getContext("2d")
          canvas->Canvas.setWidth(size)
          canvas->Canvas.setHeight(20)
          updateHueLineCanvas(canvas, context)
        }
      | Null | Undefined => ()
      }

      None
    }, [canvasRef.current])

    <div>
      <canvas ref={ReactDOM.Ref.domRef(canvasRef)} />
    </div>
  }
}

module Palette = {
  @react.component
  let make = (~arr) => {
    let (picks, letPicks) = React.useState(() => makeDefaultPalette(5, 5))
    let hueLen = picks->Array.length
    let shadeLen = picks->Array.getUnsafe(0)->{x => x.elements->Array.length}
    let picksFlat =
      picks
      ->Array.map(pick => pick.elements)
      ->Belt.Array.concatMany
    Console.log(picksFlat)

    let addHue =
      <div className="w-5 h-5 bg-neutral-500 rounded-bl-full rounded-tl-full rounded-br-full" />
    let addShade =
      <div className="w-5 h-5 bg-neutral-500 rounded-tr-full rounded-tl-full rounded-br-full" />

    <div
      style={{
        display: "grid",
        gridTemplateColumns: "2.5rem 1fr 2.5rem",
        gridTemplateRows: "2.5rem 1fr 2.5rem",
        gridTemplateAreas: `"... xAxis addShade" "yAxis main ..." "addHue ... ..."`,
      }}
      className="p-6 w-fit">
      <div
        style={{
          gridArea: "addShade",
        }}>
        {addShade}
      </div>
      <div
        style={{
          gridArea: "addHue",
        }}>
        {addHue}
      </div>
      <div
        style={{
          display: "grid",
          gridArea: "yAxis",
          gridTemplateRows: `repeat(${shadeLen->Int.toString}, 1fr)`,
        }}>
        {shadeLen
        ->Utils.mapRange(i => {
          <div key={i->Int.toString} className="h-10 w-10">
            {addHue}
            <input type_="text" value={"test"} className="w-10 h-5" />
          </div>
        })
        ->React.array}
      </div>
      <div
        style={{
          display: "grid",
          gridArea: "xAxis",
          gridTemplateColumns: `repeat(${shadeLen->Int.toString}, 1fr)`,
        }}>
        {hueLen
        ->Utils.mapRange(i => {
          <div key={i->Int.toString} className="h-10 w-10">
            {addShade}
            <input type_="text" value={"test"} className="w-10 h-5" />
          </div>
        })
        ->React.array}
      </div>
      <div
        style={{
          display: "grid",
          gridArea: "main",
          gridTemplateColumns: `repeat(${hueLen->Int.toString}, 1fr)`,
          gridTemplateRows: `repeat(${shadeLen->Int.toString}, 1fr)`,
        }}>
        {picksFlat
        ->Array.map(element => {
          <div
            key={element.id}
            className="w-10 h-10 rounded"
            style={{
              backgroundColor: element.hex,
            }}
          />
        })
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = () => {
  <div className="p-6 ">
    <HueLine />
    <Palette arr={[]} />
    // <Gamut />
  </div>
}
