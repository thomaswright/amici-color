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
  hex: string,
}

type row = {
  id: string,
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
        hex,
      }
    })
    {
      id: x->Int.toString,
      elements,
    }
  })
}

module Palette = {
  @react.component
  let make = (~arr) => {
    let (picks, letPicks) = React.useState(() => makeDefaultPalette(5, 5))
    Console.log(picks)
    let len = picks->Array.getUnsafe(0)->{x => x.elements->Array.length}

    <div className="p-6">
      <div className="flex flex-row">
        {Utils.mapRange(len, i => {
          <div className="w-10">
            <button className={"w-4 h-4 bg-blue-500 -ml-2 rounded-full"} />
          </div>
        })->React.array}
      </div>
      {picks
      ->Array.map(({id, elements}) => {
        <div key={id} className="flex flex-row ">
          <button className={"w-4 h-4 bg-blue-500 -mt-2 rounded-full"} />
          {elements
          ->Array.map(element =>
            <div
              className={"w-10 h-10 m-1"}
              key={element.id}
              style={{
                backgroundColor: element.hex,
              }}
            />
          )
          ->React.array}
        </div>
      })
      ->React.array}
    </div>
  }
}

@react.component
let make = () => {
  <div className="p-6 ">
    <Palette arr={[]} />
  </div>
}
