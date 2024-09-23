// %%raw(`import "./other.js"`)

open Common
open Types

module Logo = {
  @module("./assets/amici-prism.svg?react") @react.component
  external make: unit => React.element = "default"
}

module DropdownMenu = {
  @react.component @module("./Dropdown.jsx")
  external make: (~items: array<(string, unit => unit)>) => React.element = "default"
}

let makeDefaultPicks = (xLen, defaultShades: array<shade>) => {
  let xLenF = xLen->Int.toFloat
  let yLenF = defaultShades->Array.length->Int.toFloat

  Utils.mapRange(xLen, x => {
    let xF = x->Int.toFloat
    let hue = xF /. xLenF *. 360. +. 1.
    let hueId = ulid()
    let elements = defaultShades->Array.mapWithIndex((shade, y) => {
      let yF = y->Int.toFloat

      let s = (yF +. 1.) /. yLenF

      let (_, s, l) = Texel.convert((hue, s, 1.0), Texel.okhsv, Texel.okhsl)

      {
        shadeId: shade.id,
        hueId,
        id: ulid(),
        lightness: l,
        saturation: s,
      }
    })

    {
      id: hueId,
      value: hue,
      name: hue->hueToName,
      elements,
    }
  })
}

// let modeName = mode =>
//   switch mode {
//   | HSL_L => "OKHSL - L"
//   | LCH_L => "OKLCH - L"
//   }

let viewName = view =>
  switch view {
  | View_LC => "oklch"
  | View_SV => "okhsv"
  | View_SL => "okhsl"
  }

module Palette = {
  let defaultShades = Utils.mapRange(5, i => {
    id: ulid(),
    name: ((i + 1) * 100)->Int.toString,
  })

  let defaultPicks = makeDefaultPicks(5, defaultShades)

  @react.component
  let make = () => {
    let (view, setView) = React.useState(() => View_LC)
    // let (selectedMode, setSelectedMode) = React.useState(() => LCH_L)
    let (picks_, setPicks) = React.useState(() => defaultPicks)
    let (shades, setShades) = React.useState(() => defaultShades)
    let (selectedHue, setSelectedHue) = React.useState(() => None)
    let (selectedElement, setSelectedElement) = React.useState(() => None)

    let handleKeydown = React.useCallback2(event => {
      let updateElement = f => {
        selectedElement->Option.mapOr((), e =>
          setPicks(
            p_ => {
              p_->Array.map(
                hue => {
                  ...hue,
                  elements: hue.elements
                  ->Array.map(
                    hueElement => {
                      if hueElement.id == e {
                        f(hueElement, hue.value)
                      } else {
                        hueElement
                      }
                    },
                  )
                  ->Array.toSorted((a, b) => b.lightness -. a.lightness),
                },
              )
            },
          )
        )
      }

      let updateHue = f => {
        selectedHue->Option.mapOr((), selectedHue_ =>
          setPicks(
            p_ => {
              p_->Array.map(
                hue => {
                  hue.id == selectedHue_
                    ? {
                        ...hue,
                        value: Utils.bound(hue.value->f, 0., 360.),
                      }
                    : hue
                },
              )
            },
          )
        )
      }

      switch event->ReactEvent.Keyboard.key {
      | "u" =>
        updateHue(hue => {
          let result = hue -. 10.0
          result < 0. ? result +. 360. : result
        })

      | "d" =>
        updateHue(hue => {
          let result = hue +. 10.0
          result > 360. ? result -. 360. : result
        })

      | "k" =>
        updateHue(hue => {
          let result = hue -. 1.0
          result < 0. ? result +. 360. : result
        })

      | "j" =>
        updateHue(hue => {
          let result = hue +. 1.0
          result > 360. ? result -. 360. : result
        })

      | "ArrowDown" =>
        updateElement((el, _) => {
          ...el,
          saturation: Math.max(0.0, el.saturation -. 0.01),
        })
        event->ReactEvent.Keyboard.preventDefault

      | "ArrowUp" =>
        updateElement((el, _) => {
          ...el,
          saturation: Math.min(1.0, el.saturation +. 0.01),
        })
        event->ReactEvent.Keyboard.preventDefault

      | "ArrowLeft" =>
        switch view {
        | View_SL =>
          updateElement((el, _) => {
            ...el,
            lightness: Math.max(0.0, el.lightness -. 0.01),
          })
        | View_SV =>
          updateElement((el, hue) => {
            let (_, hsvS, hsvV) = Texel.convert(
              (hue, el.saturation, el.lightness),
              Texel.okhsl,
              Texel.okhsv,
            )

            let newV = Math.max(0.0, hsvV -. 0.01)
            let (_, newSaturation, newLightness) = Texel.convert(
              (hue, hsvS, newV),
              Texel.okhsv,
              Texel.okhsl,
            )

            {
              ...el,
              saturation: newSaturation,
              lightness: newLightness,
            }
          })
        | View_LC =>
          updateElement((el, hue) => {
            let (l, c, h) = Texel.convert(
              (hue, el.saturation, el.lightness),
              Texel.okhsl,
              Texel.oklch,
            )
            let newL = Math.max(0.0, l -. 0.01)
            let (_, outputS, outputL) = Texel.convert((newL, c, h), Texel.oklch, Texel.okhsl)
            let rgb = Texel.convert((hue, outputS, outputL), Texel.okhsl, Texel.srgb)
            if rgb->Texel.isRGBInGamut {
              {
                ...el,
                saturation: outputS,
                lightness: outputL,
              }
            } else {
              el
            }
          })
        }

        event->ReactEvent.Keyboard.preventDefault

      | "ArrowRight" =>
        switch view {
        | View_SL =>
          updateElement((el, _) => {
            ...el,
            lightness: Math.min(1.0, el.lightness +. 0.01),
          })
        | View_SV =>
          updateElement((el, hue) => {
            let (_, hsvS, hsvV) = Texel.convert(
              (hue, el.saturation, el.lightness),
              Texel.okhsl,
              Texel.okhsv,
            )

            let newV = Math.min(1.0, hsvV +. 0.01)
            let (_, newSaturation, newLightness) = Texel.convert(
              (hue, hsvS, newV),
              Texel.okhsv,
              Texel.okhsl,
            )

            {
              ...el,
              saturation: newSaturation,
              lightness: newLightness,
            }
          })
        | View_LC =>
          updateElement((el, hue) => {
            let (l, c, h) = Texel.convert(
              (hue, el.saturation, el.lightness),
              Texel.okhsl,
              Texel.oklch,
            )
            let newL = Math.min(1.0, l +. 0.01)
            let (_, outputS, outputL) = Texel.convert((newL, c, h), Texel.oklch, Texel.okhsl)
            let rgb = Texel.convert((hue, outputS, outputL), Texel.okhsl, Texel.srgb)
            if rgb->Texel.isRGBInGamut {
              {
                ...el,
                saturation: outputS,
                lightness: outputL,
              }
            } else {
              el
            }
          })
        }

        event->ReactEvent.Keyboard.preventDefault

      | _ => ()
      }
    }, (selectedElement, view))

    React.useEffect2(() => {
      addKeyboardListner("keydown", handleKeydown)
      Some(() => removeKeyboardListner("keydown", handleKeydown))
    }, (selectedElement, view))

    let picks = picks_->Array.toSorted((a, b) => a.value -. b.value)

    let hueLen = picks->Array.length
    let shadeLen = shades->Array.length

    let newHue = (referenceHueId, isAfter: bool) => {
      setPicks(p_ => {
        p_
        ->Array.findIndexOpt(v => v.id === referenceHueId)
        ->Option.mapOr(p_, pickIndex => {
          let isFirst = pickIndex == 0
          let isLast = pickIndex == p_->Array.length - 1

          let (beforeIndex, afterIndex) = {
            if isAfter {
              if isLast {
                (Some(pickIndex), None)
              } else {
                (Some(pickIndex), Some(pickIndex + 1))
              }
            } else if isFirst {
              (None, Some(pickIndex))
            } else {
              (Some(pickIndex - 1), Some(pickIndex))
            }
          }

          switch (beforeIndex, afterIndex) {
          | (Some(bi), Some(ai)) => {
              let b = p_->Array.getUnsafe(bi)
              let a = p_->Array.getUnsafe(ai)
              let newHueValue = (b.value +. a.value) /. 2.

              let hueId = ulid()
              let newElement = {
                id: hueId,
                name: newHueValue->hueToName,
                value: newHueValue,
                elements: (isAfter ? b.elements : a.elements)->Array.map(
                  v => {
                    let hueRef = isAfter ? b.value : a.value
                    let (_, hsvs, hsvv) = Texel.convert(
                      (hueRef, v.saturation, v.lightness),
                      Texel.okhsl,
                      Texel.okhsv,
                    )
                    let (_, s, l) = Texel.convert(
                      (newHueValue, hsvs, hsvv),
                      Texel.okhsv,
                      Texel.okhsl,
                    )

                    {
                      id: ulid(),
                      hueId,
                      shadeId: v.shadeId,
                      saturation: s,
                      lightness: l,
                    }
                  },
                ),
              }

              p_->Array.toSpliced(~start=ai, ~remove=0, ~insert=[newElement])
            }
          | (Some(bi), None) => {
              let b = p_->Array.getUnsafe(bi)
              let newHueValue = (b.value +. 360.) /. 2.

              let hueId = ulid()
              let newElement = {
                id: hueId,
                name: newHueValue->hueToName,
                value: newHueValue,
                elements: b.elements->Array.map(
                  v => {
                    let (_, hsvs, hsvv) = Texel.convert(
                      (b.value, v.saturation, v.lightness),
                      Texel.okhsl,
                      Texel.okhsv,
                    )
                    let (_, s, l) = Texel.convert(
                      (newHueValue, hsvs, hsvv),
                      Texel.okhsv,
                      Texel.okhsl,
                    )

                    {
                      id: ulid(),
                      hueId,
                      shadeId: v.shadeId,
                      saturation: s,
                      lightness: l,
                    }
                  },
                ),
              }

              p_->Array.toSpliced(~start=bi + 1, ~remove=0, ~insert=[newElement])
            }
          | (None, Some(ai)) => {
              let a = p_->Array.getUnsafe(ai)
              let newHueValue = (0. +. a.value) /. 2.

              let hueId = ulid()
              let newElement = {
                id: hueId,
                name: newHueValue->hueToName,
                value: newHueValue,
                elements: a.elements->Array.map(
                  v => {
                    let (_, hsvs, hsvv) = Texel.convert(
                      (a.value, v.saturation, v.lightness),
                      Texel.okhsl,
                      Texel.okhsv,
                    )
                    let (_, s, l) = Texel.convert(
                      (newHueValue, hsvs, hsvv),
                      Texel.okhsv,
                      Texel.okhsl,
                    )
                    {
                      id: ulid(),
                      hueId,
                      shadeId: v.shadeId,
                      saturation: s,
                      lightness: l,
                    }
                  },
                ),
              }

              p_->Array.toSpliced(~start=0, ~remove=0, ~insert=[newElement])
            }
          | _ => p_
          }
        })
      })
    }

    let newShade = (referenceShadeId, isAfter: bool) => {
      let newShadeId = ulid()

      shades
      ->Array.findIndexOpt(v => v.id == referenceShadeId)
      ->Option.mapOr((), shadeIndex => {
        let isFirst = shadeIndex == 0
        let isLast = shadeIndex == shades->Array.length - 1

        let (beforeIndex, afterIndex) = {
          if isAfter {
            if isLast {
              (Some(shadeIndex), None)
            } else {
              (Some(shadeIndex), Some(shadeIndex + 1))
            }
          } else if isFirst {
            (None, Some(shadeIndex))
          } else {
            (Some(shadeIndex - 1), Some(shadeIndex))
          }
        }

        switch (beforeIndex, afterIndex) {
        | (Some(bi), Some(ai)) => {
            setShades(s_ => {
              s_->Array.toSpliced(
                ~start=ai,
                ~remove=0,
                ~insert=[
                  {
                    id: newShadeId,
                    name: "New",
                  },
                ],
              )
            })

            setPicks(p_ => {
              p_->Array.map(
                hue => {
                  let b = hue.elements->Array.getUnsafe(bi)
                  let a = hue.elements->Array.getUnsafe(ai)
                  let (_, hsvsB, hsvvB) = Texel.convert(
                    (hue.value, b.saturation, b.lightness),
                    Texel.okhsl,
                    Texel.okhsv,
                  )

                  let (_, hsvsA, hsvvA) = Texel.convert(
                    (hue.value, a.saturation, a.lightness),
                    Texel.okhsl,
                    Texel.okhsv,
                  )
                  let (_, s, l) = Texel.convert(
                    (hue.value, (hsvsB +. hsvsA) /. 2., (hsvvB +. hsvvA) /. 2.),
                    Texel.okhsv,
                    Texel.okhsl,
                  )

                  let newElement = {
                    id: ulid(),
                    hueId: hue.id,
                    shadeId: newShadeId,
                    saturation: s,
                    lightness: l,
                  }

                  {
                    ...hue,
                    elements: hue.elements->Array.toSpliced(
                      ~start=ai,
                      ~remove=0,
                      ~insert=[newElement],
                    ),
                  }
                },
              )
            })
          }
        | (Some(bi), None) => {
            setShades(s_ => {
              s_->Array.toSpliced(
                ~start=bi + 1,
                ~remove=0,
                ~insert=[
                  {
                    id: newShadeId,
                    name: "New",
                  },
                ],
              )
            })

            setPicks(p_ => {
              p_->Array.map(
                hue => {
                  let b = hue.elements->Array.getUnsafe(bi)

                  let (_, hsvs, hsvv) = Texel.convert(
                    (hue.value, b.saturation, b.lightness),
                    Texel.okhsl,
                    Texel.okhsv,
                  )
                  let (_, s, l) = Texel.convert(
                    (hue.value, (hsvs +. 1.) /. 2., hsvv /. 2.),
                    Texel.okhsv,
                    Texel.okhsl,
                  )

                  let newElement = {
                    id: ulid(),
                    hueId: hue.id,
                    shadeId: newShadeId,
                    saturation: s,
                    lightness: l,
                  }

                  {
                    ...hue,
                    elements: hue.elements->Array.toSpliced(
                      ~start=bi + 1,
                      ~remove=0,
                      ~insert=[newElement],
                    ),
                  }
                },
              )
            })
          }
        | (None, Some(ai)) => {
            setShades(s_ => {
              s_->Array.toSpliced(
                ~start=0,
                ~remove=0,
                ~insert=[
                  {
                    id: newShadeId,
                    name: "New",
                  },
                ],
              )
            })

            setPicks(p_ => {
              p_->Array.map(
                hue => {
                  let a = hue.elements->Array.getUnsafe(ai)

                  let (_, hsvs, hsvv) = Texel.convert(
                    (hue.value, a.saturation, a.lightness),
                    Texel.okhsl,
                    Texel.okhsv,
                  )
                  let (_, s, l) = Texel.convert(
                    (hue.value, hsvs /. 2., (hsvv +. 1.) /. 2.),
                    Texel.okhsv,
                    Texel.okhsl,
                  )

                  let newElement = {
                    id: ulid(),
                    hueId: hue.id,
                    shadeId: newShadeId,
                    saturation: s,
                    lightness: l,
                  }
                  {
                    ...hue,
                    elements: hue.elements->Array.toSpliced(
                      ~start=0,
                      ~remove=0,
                      ~insert=[newElement],
                    ),
                  }
                },
              )
            })
          }
        | _ => ()
        }
      })
    }

    let onDragToGamut = React.useCallback1((id, x, y) => {
      let adjust = f =>
        setPicks(p_ => {
          p_->Array.map(
            hue => {
              ...hue,
              elements: hue.elements
              ->Array.map(
                hueElement => {
                  if hueElement.id == id {
                    f(hueElement, hue.value)
                  } else {
                    hueElement
                  }
                },
              )
              ->Array.toSorted((a, b) => b.lightness -. a.lightness),
            },
          )
        })

      switch view {
      | View_LC =>
        adjust((el, hue) => {
          let lch = (x, (1. -. y) *. chromaBound, hue)
          if Texel.convert(lch, Texel.oklch, Texel.srgb)->Texel.isRGBInGamut {
            let (_h, s, l) = Texel.convert(lch, Texel.oklch, Texel.okhsl)
            {
              ...el,
              saturation: s,
              lightness: l,
            }
          } else {
            el
          }
        })
      | View_SL =>
        adjust((el, _hue) => {
          {
            ...el,
            saturation: 1. -. y,
            lightness: x,
          }
        })
      | View_SV =>
        adjust((el, hue) => {
          let (_h, s, l) = Texel.convert((hue, 1. -. y, x), Texel.okhsv, Texel.okhsl)
          {
            ...el,
            saturation: x == 0. ? 1. -. y : s,
            lightness: l,
          }
        })
      }
    }, [view])

    let onDragToX = React.useCallback1((id, x) => {
      let adjust = f =>
        setPicks(p_ => {
          p_->Array.map(
            hue => {
              ...hue,
              elements: hue.elements
              ->Array.map(
                hueElement => {
                  if hueElement.id == id {
                    f(hueElement, hue.value)
                  } else {
                    hueElement
                  }
                },
              )
              ->Array.toSorted((a, b) => b.lightness -. a.lightness),
            },
          )
        })

      switch view {
      | View_LC =>
        adjust((el, hue) => {
          let (_, oldChroma, _) = Texel.convert(
            (hue, el.saturation, el.lightness),
            Texel.okhsl,
            Texel.oklch,
          )
          let lch = (x, oldChroma, hue)
          if Texel.convert(lch, Texel.oklch, Texel.srgb)->Texel.isRGBInGamut {
            let (_h, s, l) = Texel.convert(lch, Texel.oklch, Texel.okhsl)
            {
              ...el,
              saturation: s,
              lightness: l,
            }
          } else {
            el
          }
        })
      | View_SL =>
        adjust((el, _hue) => {
          {
            ...el,
            lightness: x,
          }
        })
      | View_SV =>
        adjust((el, hue) => {
          let (_, oldS, _) = Texel.convert(
            (hue, el.saturation, el.lightness),
            Texel.okhsl,
            Texel.okhsv,
          )

          let (_h, s, l) = Texel.convert((hue, oldS, x), Texel.okhsv, Texel.okhsl)
          {
            ...el,
            saturation: el.lightness == 0. ? oldS : s,
            lightness: l,
          }
        })
      }
    }, [view])

    let onDragToY = React.useCallback1((id, y) => {
      let adjust = f =>
        setPicks(p_ => {
          p_->Array.map(
            hue => {
              ...hue,
              elements: hue.elements
              ->Array.map(
                hueElement => {
                  if hueElement.id == id {
                    f(hueElement, hue.value)
                  } else {
                    hueElement
                  }
                },
              )
              ->Array.toSorted((a, b) => b.lightness -. a.lightness),
            },
          )
        })

      switch view {
      | View_LC =>
        adjust((el, hue) => {
          let (oldL, _, _) = Texel.convert(
            (hue, el.saturation, el.lightness),
            Texel.okhsl,
            Texel.oklch,
          )
          let lch = (oldL, (1. -. y) *. chromaBound, hue)
          if Texel.convert(lch, Texel.oklch, Texel.srgb)->Texel.isRGBInGamut {
            let (_h, s, l) = Texel.convert(lch, Texel.oklch, Texel.okhsl)
            {
              ...el,
              saturation: s,
              lightness: l,
            }
          } else {
            el
          }
        })
      | View_SL =>
        adjust((el, _hue) => {
          {
            ...el,
            saturation: 1. -. y,
          }
        })
      | View_SV =>
        adjust((el, hue) => {
          let (_, _, oldV) = Texel.convert(
            (hue, el.saturation, el.lightness),
            Texel.okhsl,
            Texel.okhsv,
          )

          let (_h, s, l) = Texel.convert((hue, 1. -. y, oldV), Texel.okhsv, Texel.okhsl)
          {
            ...el,
            saturation: el.lightness == 0. ? 1. -. y : s,
            lightness: l,
          }
        })
      }
    }, [view])

    <div>
      <div className="font-black text-4xl flex flex-row items-center gap-2 pb-4">
        <div className="h-12 w-12">
          <Logo />
        </div>
        {"Amici Color"->React.string}
      </div>
      <div className="flex flex-row">
        <div>
          <div className="flex flex-row gap-2">
            {[View_LC, View_SL, View_SV]
            ->Array.map(v => {
              let isSelected = view == v
              <button
                key={v->viewName}
                className={[
                  "px-2 rounded",
                  isSelected ? "bg-blue-600 text-white" : "bg-blue-200",
                ]->Array.join(" ")}
                onClick={_ => setView(_ => v)}>
                {v->viewName->React.string}
              </button>
            })
            ->React.array}
          </div>
          <div className="flex flex-col py-2">
            <div className="flex flex-row">
              <ViewGamut
                view={view}
                hues={picks}
                selectedHue
                selectedElement
                setSelectedElement
                onDragTo={onDragToGamut}
              />
              <YStack
                view={view}
                hues={picks}
                selectedElement
                setSelectedElement
                setSelectedHue
                selectedHue
                onDragTo={onDragToY}
              />
            </div>
            <XStack
              view={view}
              hues={picks}
              selectedElement
              setSelectedElement
              setSelectedHue
              onDragTo={onDragToX}
            />
            // <div className="flex flex-row gap-2 ">
            //   <HslSGamut hues={picks} selectedHue selectedElement />
            //   <HueLine hues={picks} selected={selectedHue} />
            // </div>
          </div>
        </div>
        // <div className="flex flex-row gap-2">
        //   {[HSL_L, LCH_L]
        //   ->Array.map(mode => {
        //     let isSelected = selectedMode == mode
        //     <button
        //       className={[
        //         "px-2 rounded",
        //         isSelected ? "bg-blue-600 text-white" : "bg-blue-200",
        //       ]->Array.join(" ")}
        //       onClick={_ => setSelectedMode(_ => mode)}>
        //       {mode->modeName->React.string}
        //     </button>
        //   })
        //   ->React.array}
        // </div>

        <div
          style={{
            display: "grid",
            gridTemplateColumns: `auto repeat(${shadeLen->Int.toString}, 3rem)`,
            gridTemplateRows: `auto repeat(${hueLen->Int.toString}, 3rem)`,
          }}
          className="py-6 w-fit h-fit">
          <div
            className="overflow-hidden"
            style={{
              display: "grid",
              gridRow: "2 / -1",
              gridColumn: "1 / 2",
              gridTemplateRows: "subgrid",
              gridTemplateColumns: "subgrid",
            }}>
            {picks
            ->Array.map(pick => {
              let onDelete = () => {
                setPicks(p_ => p_->Array.filter(v => v.id != pick.id))
                setSelectedHue(v => v->Option.flatMap(p => p == pick.id ? None : Some(p)))
              }

              <div key={pick.id} className=" ">
                <div className="flex-row flex w-full justify-between items-center gap-2 h-full">
                  <DropdownMenu
                    items={[
                      ("Add Row Before", () => {newHue(pick.id, false)}),
                      ("Add Row After", () => {newHue(pick.id, true)}),
                      ("Delete Row", onDelete),
                    ]}
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
                <div className="flex flex-row justify-start gap-2 w-full" />
              </div>
            })
            ->React.array}
          </div>
          <div
            className="overflow-hidden"
            style={{
              display: "grid",
              gridRow: "1 / 2",
              gridColumn: "2 / -1",
              gridTemplateRows: "subgrid",
              gridTemplateColumns: "subgrid",
            }}>
            {shades
            ->Array.map(shade => {
              let onDelete = () => {
                setPicks(p_ =>
                  p_->Array.map(
                    v => {
                      {
                        ...v,
                        elements: v.elements->Array.filter(e => e.shadeId != shade.id),
                      }
                    },
                  )
                )
                setShades(s_ => s_->Array.filter(v => v.id != shade.id))
              }

              <div key={shade.id} className=" flex flex-col gap-2">
                <DropdownMenu
                  items={[
                    ("Add Column Before", _ => newShade(shade.id, false)),
                    ("Add Column After", _ => newShade(shade.id, true)),
                    ("Delete Column", onDelete),
                  ]}
                />
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
              </div>
            })
            ->React.array}
          </div>
          <div
            style={{
              display: "grid",
              gridRow: "2 / -1",
              gridColumn: "2 / -1",
              gridTemplateColumns: "subgrid",
              gridTemplateRows: "subgrid",
            }}>
            {picks
            ->Array.map(hue => {
              hue.elements->Array.map(element => {
                let hex =
                  Texel.convert(
                    (hue.value, element.saturation, element.lightness),
                    Texel.okhsl,
                    Texel.srgb,
                  )->Texel.rgbToHex
                <div
                  key={element.id}
                  className="w-12 h-12 max-h-12 max-w-12 flex flex-row items-center justify-center cursor-pointer"
                  style={{
                    backgroundColor: hex,
                  }}
                  onClick={_ => {
                    setSelectedElement(_ => Some(element.id))
                    setSelectedHue(_ => Some(element.hueId))
                  }}>
                  {selectedElement->Option.mapOr(false, e => e == element.id)
                    ? {"•"->React.string}
                    : React.null}
                </div>
              })
            })
            ->Belt.Array.concatMany
            ->React.array}
          </div>
        </div>
      </div>
    </div>
  }
}

@react.component
let make = () => {
  <div className="p-6 min-h-screen bg-white">
    <Palette />
    // <Gamut />
  </div>
}
