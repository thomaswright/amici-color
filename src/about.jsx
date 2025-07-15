import React from "react";
import * as Dialog from "@radix-ui/react-dialog";
import { Cross2Icon } from "@radix-ui/react-icons";

const About = () => {
  return (
    <div
      id="about"
      className="overflow-y-scroll flex-1 flex flex-col gap-4 py-4"
    >
      <p>Amici is a color palette picker with convenient constraints.</p>
      <p>
        All hue rows have a fixed hue (as defined by the oklab color space). You
        can adjust the hue for the row, but individual colors within that row
        will all have that hue.
      </p>
      <p>
        The hue rows are strictly order by their hue value. As you adjust them
        across the spectrum, the ordering will naturally adjust. Similarly the
        individual colors within a row will be sorted by lightness. If you
        adjust one higher or lower that its neighbor, they will swap columns.
      </p>
      <p>
        You can view the color in three different gamut panels: oklch, okhsl,
        and okhsv. Only one hue will be mapped on the gamut graph, but adjacent
        to each axis are the positions of the other hues, for convenient
        comparison. Grab the color handles and move them about to adjust.
      </p>
      <p>
        Click on the dropdown arrows to add and delete rows or columns. The
        names of each can be adjusted too.
      </p>
      <p>
        The arrow keys can be used to adjust the selected color on the gamut
        panel. The following keys make large hue adjustments: 'u' & 'd' and
        small hue adjustments: 'j' & 'k'.
      </p>
      <p>
        When you are happy with your palette, export to your preferred format.
      </p>
    </div>
  );
};

const AboutDialog = () => (
  <Dialog.Root>
    <Dialog.Trigger asChild>
      <button className="text-[var(--select)] mx-6">About</button>
    </Dialog.Trigger>
    <Dialog.Portal>
      <Dialog.Overlay className="fixed inset-0 data-[state=open]:animate-overlayShow" />
      <Dialog.Content
        className="shadow-xl fixed left-1/2 top-1/2 max-h-[85vh] w-[90vw] max-w-[450px] -translate-x-1/2 -translate-y-1/2 rounded-md bg-white p-[25px] 
         focus:outline-none data-[state=open]:animate-contentShow bg-[var(--bg)] text-[var(--select)] border border-[var(--complement)] "
      >
        <div className="flex flex-col max-h-[70vh]">
          <Dialog.Title className="m-0 text-lg font-black ">
            About Amici Color
          </Dialog.Title>
          <About />
        </div>

        <Dialog.Close asChild>
          <button
            className="absolute right-2.5 top-2.5 inline-flex size-[25px] appearance-none items-center justify-center rounded-full  focus:outline-none"
            aria-label="Close"
          >
            <Cross2Icon />
          </button>
        </Dialog.Close>
      </Dialog.Content>
    </Dialog.Portal>
  </Dialog.Root>
);

export default AboutDialog;

{
  /* <li>
  In the same column as the symmetry indicator is the listing of the
  number of correlations between each pitch class. For example, in the
  Pentatonic scale we can see if a mode is rotated 2 half-notes there
  will be 3 correlations, for 3 half-notes 2 correlations, etc. This is
  somewhat an indicator of how self-harmonic a scale is. You'll see that
  the most popular scales (like the Pentatonic and the Diatonic) have
  high correlations across rotations, especially for simple (aka high
  harmonic) pitch ratios like 5ths (7 half-notes) and 3rds (5
  half-notes).
</li> */
}
