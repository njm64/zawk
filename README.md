# zawk
An Awk implementation of the Infocom Z-Machine. Supports Z3 files (e.g. Zork 1, Hitchhikers Guide to the Galaxy, etc). 

Works with original Awk, GNU gawk, and mawk.

**Beta version:** Note that save and restore are not yet supported.

Example
-------

    ./zawk zork1.z3
    ZORK I: The Great Underground Empire
    Copyright (c) 1981, 1982, 1983 Infocom, Inc. All rights reserved.
    ZORK is a registered trademark of Infocom, Inc.
    Revision 88 / Serial number 840726

    West of House
    You are standing in an open field west of a white house, with a boarded front door.
    There is a small mailbox here.

    >open mailbox
    Opening the small mailbox reveals a leaflet.

    >get leaflet
    Taken.

    >read leaflet
    "WELCOME TO ZORK!

    ZORK is a game of adventure, danger, and low cunning. In it you will explore
    some of the most amazing territory ever seen by mortals. No computer should 
    be without one!"

Still to do
-----------
- Save and restore is still to be added
- Word wrap is not implemented, so words can be split across lines
- Numerous other features and enhancements
