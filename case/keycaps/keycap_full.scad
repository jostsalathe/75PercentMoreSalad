xyCav = 14.8;
zCav = 3.4;

zStem = zCav;
tCross = 1.2;
wCross = 4.2;
dStem = 5.8;
tWallStem = 0.8;

xyCap = 18;
zCap = zCav + 1.6;
capChamfer = 0.8;

tWall = (xyCap - xyCav) / 2;

zDimple = 1;
rDimple = (xyCap - 4 * capChamfer) / 2;
rDimpleSphere = (zDimple + rDimple^2 / zDimple) / 2;

module keycap(isHome=false)
{
  difference()
  {
    union()
    {
      difference()
      {
        minkowski()
        {
          cube([xyCav, xyCav, zCap-capChamfer]);
          translate([tWall, tWall, 0])
          cylinder(h=capChamfer, r1=tWall, r2=tWall-capChamfer, $fn=64);
        }
        translate([tWall, tWall, -1])
        cube([xyCav, xyCav, zCav+1]);
      }
      translate([xyCap/2, xyCap/2, zStem/2])
      {
        *cylinder(h=zStem, d=dStem, center=true, $fn=64);
        cube([wCross+2*tWallStem, tCross+2*tWallStem, zStem], center=true);
        cube([tCross+2*tWallStem, wCross+2*tWallStem, zStem], center=true);
      }
    }
    translate([xyCap/2, xyCap/2, isHome?0:zStem/2-2])
    {
      cube([wCross, tCross, isHome?zCap*3:zStem+4], center=true);
      cube([tCross, wCross, isHome?zCap*3:zStem+4], center=true);
    }
    translate([xyCap/2, xyCap/2, zCap+rDimpleSphere-zDimple])
    sphere(rDimpleSphere, $fn=$preview?64:256);
  }
  translate([xyCap/2, xyCap/2, zCav])
  cylinder(h=0.2, d=dStem);
}

difference()
{
  keycap(false);
  *translate([xyCap/2, -1, -1]) cube([xyCap/2+1, xyCap+2, zCap+2]);
  *translate([-1, -1, -1]) cube([xyCap/2+1, xyCap+2, zCap+2]);
}
