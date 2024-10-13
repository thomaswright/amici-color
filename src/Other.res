open Texel

let adjustLchLofHex = (hex, f) => {
  let (l, c, h) = hex->hexToRgb->convert(srgb, oklch)
  convert((l->f, c, h), oklch, srgb)->rgbToHex
}

let adjustLchCofHex = (hex, f) => {
  let (l, c, h) = hex->hexToRgb->convert(srgb, oklch)
  convert((l, c->f, h), oklch, srgb)->rgbToHex
}
