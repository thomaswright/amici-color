// %%raw(`import "./other.js"`)

module Utils = {
  let mapRange = (n, f) => {
    Array.make(~length=n, 0)->Array.mapWithIndex((_, i) => {
      f(i)
    })
  }
  let bound = (left, right, v) => {
    Math.max(left, Math.min(right, v))
  }
}

@module("ulid") external ulid: unit => string = "ulid"

let hueToName = hue => {
  switch hue {
  | x if x >= 05. && x < 15. => "rose"
  | x if x >= 15. && x < 25. => "crimson"
  | x if x >= 25. && x < 35. => "red"
  | x if x >= 35. && x < 45. => "vermillion"
  | x if x >= 45. && x < 55. => "persimmon"
  | x if x >= 55. && x < 65. => "orange"
  | x if x >= 65. && x < 75. => "pumpkin"
  | x if x >= 75. && x < 85. => "mango"
  | x if x >= 85. && x < 95. => "amber"
  | x if x >= 95. && x < 105. => "gold"
  | x if x >= 105. && x < 115. => "yellow"
  | x if x >= 115. && x < 125. => "citron"
  | x if x >= 125. && x < 135. => "pear"
  | x if x >= 135. && x < 145. => "chartreuse"
  | x if x >= 145. && x < 155. => "lime"
  | x if x >= 155. && x < 165. => "green"
  | x if x >= 165. && x < 175. => "emerald"
  | x if x >= 175. && x < 185. => "mint"
  | x if x >= 185. && x < 195. => "sea"
  | x if x >= 195. && x < 205. => "teal"
  | x if x >= 205. && x < 215. => "cyan"
  | x if x >= 215. && x < 225. => "pacific"
  | x if x >= 225. && x < 235. => "cerulean"
  | x if x >= 235. && x < 245. => "capri"
  | x if x >= 245. && x < 255. => "sky"
  | x if x >= 255. && x < 265. => "blue"
  | x if x >= 265. && x < 275. => "sapphire"
  | x if x >= 275. && x < 285. => "indigo"
  | x if x >= 285. && x < 295. => "veronica"
  | x if x >= 295. && x < 305. => "violet"
  | x if x >= 305. && x < 315. => "amethyst"
  | x if x >= 315. && x < 325. => "purple"
  | x if x >= 325. && x < 335. => "plum"
  | x if x >= 335. && x < 345. => "fuchsia"
  | x if x >= 345. && x < 355. => "magenta"
  | x if x >= 355. || x < 05. => "pink"
  | _ => "?"
  }
}
module Gamut = {
  @react.component @module("./other.jsx") external make: unit => React.element = "Gamut"
}

type shade = {id: string, name: string}

type element = {
  id: string,
  shadeId: string,
  hex: string,
}

type hue = {
  id: string,
  value: float,
  name: string,
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
  @module("@texel/color") external hexToRgb: string => triple = "hexToRGB"

  @module("@texel/color") external convert: (triple, texelType, texelType) => triple = "convert"
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

module NameInspection = {
  @react.component
  let make = () => {
    <div>
      {Utils.mapRange(36, i => {
        let hue = (i * 10)->Int.toFloat
        <div className="flex flex-row">
          <div
            className={"w-4 h-4"}
            style={{
              backgroundColor: Texel.rgbToHex(
                Texel.convert((hue, 1.0, 1.0), Texel.okhsv, Texel.srgb),
              ),
            }}
          />
          {hue->hueToName->React.string}
        </div>
      })->React.array}
    </div>
  }
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

  // ctx->Canvas.setFillStyle("#000")

  // hues->Array.forEach(hue => {
  //   ctx->Canvas.fillRect(~x=(hue /. 360. *. xMax->Int.toFloat)->Float.toInt, ~y=0, ~w=10, ~h=10)
  // })

  ()
}

module HueLine = {
  let xSize = 500
  @react.component
  let make = (~hues) => {
    let canvasRef = React.useRef(Nullable.null)
    // let huesComparison = hues->Array.reduce("", (a, c) => {a ++ c->Float.toString})
    React.useEffect1(() => {
      switch canvasRef.current {
      | Value(canvasDom) => {
          let canvas = canvasDom->Obj.magic
          let context = canvas->Canvas.getContext("2d")
          canvas->Canvas.setWidth(xSize)
          canvas->Canvas.setHeight(20)
          updateHueLineCanvas(canvas, context)
        }
      | Null | Undefined => ()
      }

      None
    }, [canvasRef.current])

    <div className="w-fit relative">
      {hues
      ->Array.map(hue => {
        <div
          className={"bg-black w-2 h-2 absolute "}
          style={{
            left: (hue /. 360. *. xSize->Int.toFloat)->Float.toInt->Int.toString ++ "px",
          }}
        />
      })
      ->React.array}
      <canvas ref={ReactDOM.Ref.domRef(canvasRef)} />
    </div>
  }
}

let makeDefaultPicks = (xLen, defaultShades: array<shade>) => {
  let xLenF = xLen->Int.toFloat
  let yLenF = defaultShades->Array.length->Int.toFloat

  Utils.mapRange(xLen, x => {
    let xF = x->Int.toFloat
    let hue = xF /. xLenF *. 360.
    let elements = defaultShades->Array.mapWithIndex((shade, y) => {
      let yF = y->Int.toFloat

      let s = (yF +. 1.) /. yLenF
      let hex = Texel.rgbToHex(Texel.convert((hue, s, 1.0), Texel.okhsv, Texel.srgb))

      {
        shadeId: shade.id,
        id: ulid(),
        hex,
      }
    })

    {
      id: ulid(),
      value: hue,
      name: hue->hueToName,
      elements,
    }
  })
}

module Palette = {
  let defaultShades = Utils.mapRange(5, i => {
    id: ulid(),
    name: ((i + 1) * 100)->Int.toString,
  })

  let defaultPicks = makeDefaultPicks(5, defaultShades)

  @react.component
  let make = (~arr) => {
    let (picks_, setPicks) = React.useState(() => defaultPicks)
    let (shades, setShades) = React.useState(() => defaultShades)

    let picks = picks_->Array.toSorted((a, b) => a.value -. b.value)

    let hueLen = picks->Array.length
    let shadeLen = shades->Array.length
    let picksFlat =
      picks
      ->Array.map(pick => pick.elements)
      ->Belt.Array.concatMany

    let changeHexHueByHSV = (hex, hue) => {
      let (_, s, v) = Texel.convert(hex->Texel.hexToRgb, Texel.srgb, Texel.okhsv)
      let newHex = Texel.convert((hue, s, v), Texel.okhsv, Texel.srgb)->Texel.rgbToHex
      newHex
    }

    let makeNewHue = (copy, left, right) => {
      let newValue = (left +. right) /. 2.
      {
        id: ulid(),
        name: newValue->hueToName,
        value: newValue,
        elements: copy.elements->Array.map(v => {
          {
            id: ulid(),
            shadeId: v.shadeId,
            hex: changeHexHueByHSV(v.hex, newValue),
          }
        }),
      }
    }

    <div>
      <HueLine hues={picks->Array.map(({value}) => value)} />
      <div
        style={{
          display: "grid",
          gridTemplateColumns: `5rem repeat(${shadeLen->Int.toString}, 1fr) 2.5rem`,
          gridTemplateRows: `2.5rem repeat(${hueLen->Int.toString}, 1fr) 2.5rem`,
        }}
        className="p-6 w-fit">
        <div
          className="flex flex-col justify-end"
          style={{
            gridRow: "1 / 2",
            gridColumn: "-1 / -2",
          }}>
          <button
            className="w-5 h-5 bg-pink-500 rounded-tr-full rounded-tl-full rounded-br-full"
            onClick={_ => {
              let newShadeId = ulid()
              setShades(s_ => {
                [
                  ...s_,
                  {
                    id: newShadeId,
                    name: "New",
                  },
                ]
              })
              setPicks(p_ => {
                p_->Array.map(v => {
                  {
                    ...v,
                    elements: v.elements->Array.reduceWithIndex(
                      [],
                      (a, c, i) => {
                        i == v.elements->Array.length - 1
                          ? {
                              let (h, s, left) = Texel.convert(
                                c.hex->Texel.hexToRgb,
                                Texel.srgb,
                                Texel.okhsv,
                              )

                              let right = 1.0
                              let avg = (left +. right) /. 2.

                              let newValue = Utils.bound(0.0, 1.0, avg)
                              let newHex =
                                Texel.convert(
                                  (h, s, newValue),
                                  Texel.okhsv,
                                  Texel.srgb,
                                )->Texel.rgbToHex

                              [
                                ...a,
                                c,
                                {
                                  id: ulid(),
                                  shadeId: newShadeId,
                                  hex: newHex,
                                },
                              ]
                            }
                          : [...a, c]
                      },
                    ),
                  }
                })
              })
            }}
          />
        </div>
        <div
          className="flex flex-col items-end"
          style={{
            gridRow: "-1 / -2",
            gridColumn: "1 / 2",
          }}>
          <button
            className="w-5 h-5 bg-blue-500 rounded-bl-full rounded-tl-full rounded-br-full"
            onClick={_ =>
              setPicks(p_ => {
                let lastHue = picks->Array.toReversed->Array.getUnsafe(0)

                let new = makeNewHue(lastHue, lastHue.value, 360.)
                [...p_, new]
              })}
          />
        </div>
        <div
          style={{
            gridRow: "2 / -2",
            gridColumn: "1 / 2",
            gridTemplateRows: `subgrid`,
          }}>
          {picks
          ->Array.map(pick => {
            <div key={pick.id} className="h-10 w-20 flex flex-col items-end">
              <button
                className="w-5 h-5 bg-blue-500 rounded-bl-full rounded-tl-full rounded-br-full"
                onClick={_ => {
                  setPicks(p_ => {
                    p_->Array.reduceWithIndex(
                      [],
                      (acc, cur, i) => {
                        let leftValue = i == 0 ? 0. : p_->Array.getUnsafe(i - 1)->{x => x.value}

                        cur.id == pick.id
                          ? [...acc, makeNewHue(cur, leftValue, cur.value), cur]
                          : [...acc, cur]
                      },
                    )
                  })
                }}
              />
              <input
                type_="text"
                value={pick.name}
                onChange={e => {
                  let value = (e->ReactEvent.Form.target)["value"]
                  setPicks(cur => {
                    cur->Array.map(
                      v => {
                        v.id == pick.id
                          ? {
                              ...v,
                              name: value,
                            }
                          : v
                      },
                    )
                  })
                }}
                className="w-20 h-5"
              />
            </div>
          })
          ->React.array}
        </div>
        <div
          style={{
            display: "grid",
            gridRow: "1 / 2",
            gridColumn: "2 / -2",
            gridTemplateColumns: `subgrid`,
          }}>
          {shades
          ->Array.map(shade => {
            <div key={shade.id} className="h-10 w-10 flex flex-col">
              <input
                type_="text"
                onChange={e => {
                  let value = (e->ReactEvent.Form.target)["value"]
                  setShades(cur =>
                    cur->Array.map(
                      v =>
                        v.id == shade.id
                          ? {
                              ...v,
                              name: value,
                            }
                          : v,
                    )
                  )
                }}
                value={shade.name}
                className="w-10 h-5"
              />
              <button
                className="w-5 h-5 bg-pink-500 rounded-tr-full rounded-tl-full rounded-br-full"
                onClick={_ => {
                  let newShadeId = ulid()
                  setShades(s_ => {
                    s_->Array.reduce(
                      [],
                      (a, c) => {
                        c.id == shade.id
                          ? [
                              ...a,
                              {
                                id: newShadeId,
                                name: "New",
                              },
                              c,
                            ]
                          : [...a, c]
                      },
                    )
                  })
                  setPicks(p_ => {
                    p_->Array.map(
                      v => {
                        {
                          ...v,
                          elements: v.elements->Array.reduceWithIndex(
                            [],
                            (a, c, i) => {
                              c.shadeId == shade.id
                                ? {
                                    // Todo: interpolate value too?

                                    let left =
                                      i == 0
                                        ? 0.0
                                        : v.elements
                                          ->Array.getUnsafe(i - 1)
                                          ->{
                                            x => {
                                              let (_, result, _) = Texel.convert(
                                                x.hex->Texel.hexToRgb,
                                                Texel.srgb,
                                                Texel.okhsv,
                                              )

                                              result
                                            }
                                          }

                                    let (h, right, v) = Texel.convert(
                                      c.hex->Texel.hexToRgb,
                                      Texel.srgb,
                                      Texel.okhsv,
                                    )

                                    let avg = (left +. right) /. 2.

                                    let newValue = Utils.bound(0.0, 1.0, avg)

                                    let newHex =
                                      Texel.convert(
                                        (h, newValue, v),
                                        Texel.okhsv,
                                        Texel.srgb,
                                      )->Texel.rgbToHex

                                    Console.log4(left, right, newValue, newHex)

                                    [
                                      ...a,
                                      {
                                        id: ulid(),
                                        shadeId: newShadeId,
                                        hex: newHex,
                                      },
                                      c,
                                    ]
                                  }
                                : [...a, c]
                            },
                          ),
                        }
                      },
                    )
                  })
                }}
              />
            </div>
          })
          ->React.array}
        </div>
        <div
          style={{
            display: "grid",
            gridRow: "2 / -2",
            gridColumn: "2 / -2",
            gridTemplateColumns: "subgrid",
            gridTemplateRows: "subgrid",
          }}>
          {picksFlat
          ->Array.map(element => {
            <div
              key={element.id}
              className="w-10 h-10 max-h-10 max-w-10"
              style={{
                backgroundColor: element.hex,
              }}
            />
          })
          ->React.array}
        </div>
      </div>
    </div>
  }
}

@react.component
let make = () => {
  <div className="p-6 ">
    <Palette arr={[]} />
    // <Gamut />
  </div>
}
