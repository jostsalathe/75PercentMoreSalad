zPlateRim = 3.5;
zPlate = 1.2;
zPcbToPlate = 1.3;

tWall = 2;
xySwitchCutout = 14;

switchPitch = 19.05;
xStabi2U = 23.876;

// Array of rows with row = [[xOffset, yOffset], [sw0, sw1, ..., swN]] where
//  swI can be 0 (no switch), 1 (1U), 2 (2U horizontal) or 3 (2U vertical)
// This array follows a strict raster, so space occupied by a 2 or 3 has to
//  be reserved with a corresponding 0.
layoutNum =
[
  [1, 1, 1, 1],
  [1, 1, 1, 1],
  [1, 1, 1, 3],
  [1, 1, 1, 0],
  [1, 1, 1, 3],
  [2, 0, 1, 0]
];

layout75 =
[
  [1,    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  [1,    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 0, 1],
  [1.5,  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1],
  [1.75, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1],
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
  translate([switchPitch/2, 0, zPlate/2])
  {
    cube([xySwitchCutout, xySwitchCutout, zPlate+0.2], center=true);
    translate([-xStabi2U/2, 0, 0])
    cylinder(h=zPlate+0.2, d=6, center=true);
    translate([xStabi2U/2, 0, 0])
    cylinder(h=zPlate+0.2, d=6, center=true);
  }
}

module switches(layout)
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
        else if (layout[iRow][iCol] < 2) switch1U();
        else if (layout[iRow][iCol] == 2) switch2U();
        else if (layout[iRow][iCol] == 3) rotate([0, 0, 270]) switch2U();
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
    translate([0, -yPlate - 2*tWall, 0])
    cube([xPlate + 2*tWall, yPlate + 2*tWall, zPlate + zPlateRim]);
    translate([tWall, -yPlate - tWall, zPlate])
    cube([xPlate, yPlate, zPlateRim + 0.1]);
    translate([switchPitch/2 + tWall, -switchPitch/2 - tWall, 0])
    switches(layout);
  }
}

plate(layoutNum);
