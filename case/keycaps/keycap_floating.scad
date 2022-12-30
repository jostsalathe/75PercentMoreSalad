zCav = 2.4;

zStemExtra = 1;
zStem = zCav + zStemExtra;
tCross = 1.2;
wCross = 4.2;
dStem = 5.8;
tWallStem = 0.8;

xyCap = 18;
zCap = zStemExtra + 0.2;
capChamfer = 0.8;

rFillet = 2;

module keycap(isHome=false)
{
  difference()
  {
    union()
    {
      translate([0, 0, zCav]) minkowski()
      {
        cube([xyCap-2*rFillet, xyCap-2*rFillet, zCap-capChamfer]);
        translate([rFillet, rFillet, 0])
        cylinder(h=capChamfer, r1=rFillet, r2=rFillet-capChamfer, $fn=64);
      }
      translate([xyCap/2, xyCap/2, zStem/2])
      {
        *cylinder(h=zStem, d=dStem, center=true, $fn=64);
        cube([wCross+2*tWallStem, tCross+2*tWallStem, zStem], center=true);
        cube([tCross+2*tWallStem, wCross+2*tWallStem, zStem], center=true);
      }
    }
    translate([xyCap/2, xyCap/2, zStem/2-(isHome?0:1)])
    {
      cube([wCross, tCross, zStem+2], center=true);
      cube([tCross, wCross, zStem+2], center=true);
    }
  }
}

difference()
{
  translate([0, 0, zCap+zCav]) rotate([180, 0, 90]) keycap(false);
  translate([xyCap/2, -1, -1])
  *cube([xyCap/2+1, xyCap+2, zCav+zCap+2]);
  translate([-1, -1, -1])
  *cube([xyCap/2+1, xyCap+2, zCap+2]);
}
