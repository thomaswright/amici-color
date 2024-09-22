import React from "react";
import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
import {
  HamburgerMenuIcon,
  DotsHorizontalIcon,
  ChevronDownIcon,
  DotFilledIcon,
  CheckIcon,
  ChevronRightIcon,
} from "@radix-ui/react-icons";
import "./dropdown.css";

const DropdownMenuComp = ({ items }) => {
  const [bookmarksChecked, setBookmarksChecked] = React.useState(true);
  const [urlsChecked, setUrlsChecked] = React.useState(false);
  const [person, setPerson] = React.useState("pedro");

  return (
    <DropdownMenu.Root>
      <DropdownMenu.Trigger asChild>
        <button className="IconButton" aria-label="Customise options">
          <ChevronDownIcon />
        </button>
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content className="DropdownMenuContent" sideOffset={5}>
          {items.map(([text, handle]) => {
            return (
              <DropdownMenu.Item onSelect={handle} className="DropdownMenuItem">
                {text}
              </DropdownMenu.Item>
            );
          })}
          <DropdownMenu.Arrow className="DropdownMenuArrow" />
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
};

export default DropdownMenuComp;
