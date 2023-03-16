$fn=$preview?12:64;

zCase = 1.6;
zCaseToPcb = 3;

zPcb = 1.6;
zPcbToPlate = 1.3;

zPlate = 1.2;
zPlateRim = 3.5;


tWall = 2;
xySwitchCutout = 14;

switchPitch = 19.05;
switchStemHole = 3.5;
xSwitchClipSlot = 5.4;
ySwitchClipSlot = 1.6;
ySwitchClipSlotDist = 6.5;

xStabiDist2U = 23.876;
xStabiPlate = 6.7;
yStabiPlate = 16;

// Array of rows with row = [[xOffset, yOffset], [sw0, sw1, ..., swN]] where
//  swI can be 0 (no switch), 1 (1U), 2 (2U horizontal) or 3 (2U vertical)
// This array follows a strict raster, so space occupied by a 2 or 3 has to
//  be reserved with a corresponding 0.
layoutTest =
[
  [1, 1, 0],
  [2, 0, 3]
];

layoutNum =
[
  [1, 1, 1, 1],
  [1, 1, 1, 1],
  [1, 1, 1, 0],
  [1, 1, 1, 3],
  [1, 1, 1, 0],
  [2, 0, 1, 3]
];

layout75 =
[
  [1,    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  [1,    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 0, 1],
  [1.5,  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1],
  [1.75, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1],
  [1.25, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  [1,    1, 1, 1, 2, 0, 2, 0, 2, 0, 1, 1, 1, 1, 1, 1]
];

module switch1U()
{
  translate([0, 0, zPlate/2])
  cube([xySwitchCutout, xySwitchCutout, zPlate+0.2], center=true);
}

module switch2U()
{
  translate([switchPitch/2, 0, 0])
  {
    switch1U();
    translate([0, 0, zPlate/2])
    {
      for(xPos = [-1, 1])
      translate([xPos * xStabiDist2U/2, 0, 0])
      {
        cube([xStabiPlate, yStabiPlate, zPlate+0.2], center=true);
      }
    }
  }
}

module pcbSwitch1U()
{
  translate([0, 0, zPcb/2])
  {
    cylinder(h=zPcb+0.2, d=switchStemHole, center=true);
    for (yOffset = [-ySwitchClipSlotDist, ySwitchClipSlotDist])
    translate([0, yOffset, 0])
    {
      translate([-(xSwitchClipSlot-ySwitchClipSlot)/2, 0, 0])
      cylinder(h=zPcb+0.2, d=ySwitchClipSlot, center=true);
      cube([xSwitchClipSlot-ySwitchClipSlot, ySwitchClipSlot, zPcb+0.2], center=true);
      translate([(xSwitchClipSlot-ySwitchClipSlot)/2, 0, 0])
      cylinder(h=zPcb+0.2, d=ySwitchClipSlot, center=true);
    }
  }
}

module pcbStabi()
{
  xMain = 8.3;
  yMain = 12.4;
  yMainOffset = -0.7;

  xWire = 3;
  yWire = 1.2;
  yWireOffset = -yMain/2+yMainOffset-yWire/2;

  translate([0, yMainOffset, 0]) cube([xMain, yMain, zPcb+0.2], center=true);
  translate([0, yWireOffset+0.1, 0]) cube([xWire, yWire+0.1, zPcb+0.2], center=true);
}

module pcbSwitch2U(rotated=false)
{
  translate([switchPitch/2, 0, 0])
  {
    rotate([0,0,rotated?-90:0]) pcbSwitch1U();
    translate([0, 0, zPcb/2])
    {
      translate([-xStabiDist2U/2, 0, 0]) pcbStabi();
      translate([xStabiDist2U/2, 0, 0]) pcbStabi();
    }
  }
}

module switches(layout, isPcb=false)
{
  for (iRow = [0:len(layout)-1])
  {
    firstSwitch = layout[iRow][0];
    offsetX = firstSwitch<2 ? firstSwitch-1 : 0;
    for (iCol = [0:len(layout[iRow])-1])
    {
      posX = (iCol==0 ? offsetX/2 : offsetX + iCol) * switchPitch;
      posY = -iRow * switchPitch;
      translate([posX, posY, 0])
      {
        if (layout[iRow][iCol] < 1);
        else if (layout[iRow][iCol] < 2)
        {
          if(isPcb) pcbSwitch1U();
          else switch1U();
        }
        else if (layout[iRow][iCol] == 2)
        {
          if(isPcb) pcbSwitch2U();
          else switch2U();
        }
        else if (layout[iRow][iCol] == 3) rotate([0, 0, 90])
        {
          if(isPcb) pcbSwitch2U(true);
          else switch2U();
        }
      }
    }
  }
}

module plate(layout)
{
  xPlate = len(layout[0]) * switchPitch;
  yPlate = len(layout) * switchPitch;
  difference()
  {
    translate([tWall, -yPlate - tWall, 0])
    minkowski()
    {
      cube([xPlate, yPlate, zPlateRim]);
      cylinder(h=zPlate, r=tWall);
    }
    translate([tWall, -yPlate - tWall, zPlate])
    cube([xPlate, yPlate, zPlateRim + 0.1]);
    translate([switchPitch/2 + tWall, -switchPitch/2 - tWall, 0])
    switches(layout);
  }
}

module pcb(layout)
{
  xPcb = len(layout[0]) * switchPitch;
  yPcb = len(layout) * switchPitch;
  difference()
  {
    // outer contours
    translate([2*tWall, -yPcb - 2*tWall, 0])
    minkowski()
    {
      cube([xPcb, yPcb, zPcbToPlate + zPlateRim]);
      cylinder(h = zPcb, r = 2*tWall);
    }
    // cutout plate
    translate([2*tWall, -yPcb - 2*tWall, zPcb + zPcbToPlate])
    minkowski()
    {
      cube([xPcb, yPcb, zPlateRim + 0.1]);
      cylinder(h=zPlate, r=tWall);
    }
    // cutout parts on pcb top side
    translate([2*tWall, -yPcb - 2*tWall, zPcb])
    cube([xPcb, yPcb, zPcbToPlate + 0.1]);
    // pcb cutouts
    translate([switchPitch/2 + 2*tWall, -switchPitch/2 - 2*tWall, 0])
    switches(layout, true);
    // wall cutouts
    for(xPos = [2*tWall + xPcb, -0.1])
    translate([xPos, -2*tWall - yPcb/2 - switchPitch/2, -0.1])
    cube([2*tWall + 0.1, switchPitch, zPcb + 0.2]);
    translate([-0.1, -2*tWall - yPcb/2 - switchPitch/2, zPcb])
    cube([xPcb + 4*tWall + 0.2, switchPitch, zPcbToPlate + zPlateRim + 0.1]);
  }
}

module case(layout)
{
  xCase = len(layout[0]) * switchPitch;
  yCase = len(layout) * switchPitch;
  difference()
  {
    // outer contours
    translate([3*tWall, -yCase - 3*tWall, 0])
    minkowski()
    {
      cube([xCase, yCase, zCaseToPcb + zPlateRim]);
      cylinder(h = zCase, r = 3*tWall);
    }
    // cutout pcb
    translate([3*tWall, -yCase - 3*tWall, zCase + zCaseToPcb])
    minkowski()
    {
      cube([xCase, yCase, zPcbToPlate + zPlateRim + 0.1]);
      cylinder(h = zPcb, r = 2*tWall);
    }
    // cutout parts on pcb bottom side
    translate([3*tWall, -yCase - 3*tWall, zCase])
    minkowski()
    {
      cube([xCase, yCase, zCaseToPcb]);
      cylinder(h = 0.1, r = tWall);
    }
    // wall cutouts
    for(yPos = [-2*tWall, -yCase - 6*tWall - 0.1])
    translate([3*tWall + xCase/2 - switchPitch/2, yPos, -0.1])
    cube([switchPitch, 2*tWall + 0.1, zCase + 0.2]);
    translate([3*tWall + xCase/2 - switchPitch/2, -yCase - 6*tWall - 0.1, zCase])
    cube([switchPitch, yCase + 6*tWall + 0.2, zCaseToPcb + zPcb + zPcbToPlate + zPlateRim + 0.1]);
  }
}

case(layoutTest);

translate([tWall, -tWall, zCase + zCaseToPcb])
pcb(layoutTest);

translate([2*tWall, -2*tWall, zCase + zCaseToPcb + zPcb + zPcbToPlate])
plate(layoutTest);



