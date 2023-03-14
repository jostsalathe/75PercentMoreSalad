switchPitch = 19.05;
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

module stem()
{
  difference()
  {
    // stem meat
    translate([0, 0, zStem/2])
    {
      cube([wCross+2*tWallStem, tCross+2*tWallStem, zStem], center=true);
      cube([tCross+2*tWallStem, wCross+2*tWallStem, zStem], center=true);
    }
    // stem cavity
    translate([0, 0, zStem/2-2])
    {
      cube([wCross, tCross, zStem+4], center=true);
      cube([tCross, wCross, zStem+4], center=true);
    }
  }
}

module keycap(size=1, isHome=false)
{
  xExtra = (size-1) * switchPitch;
  difference()
  {
    union()
    {
      difference()
      {
        // main cap body
        minkowski()
        {
          cube([xyCav+xExtra, xyCav, zCap-capChamfer]);
          translate([tWall, tWall, 0])
          cylinder(h=capChamfer, r1=tWall, r2=tWall-capChamfer, $fn=64);
        }
        // main cavity
        translate([tWall, tWall, -1])
        cube([xyCav+xExtra, xyCav, zCav+1]);
      }
      // stem
      translate([(xyCap+xExtra)/2, xyCap/2, 0])
      {
        stem();
        // extra stems for stabilizer
        if (size >= 2) {
          stabiWidth = size>7 ? 133.35 : size>=7 ? 114.3 : size>=6.25 ? 38.1 : size>=6 ? 38.1 : size>=3 ? 38.1 : 23.9;
          translate([-stabiWidth/2, 0, 0]) stem();
          translate([stabiWidth/2, 0, 0]) stem();
        }
      }
    }
    // dimple
    translate([xyCap/2, xyCap/2, zCap+rDimpleSphere-zDimple])
    {
      $fn=$preview?64:256;
      sphere(rDimpleSphere);
      if (size>1)
      {
        translate([xExtra, 0, 0])
        sphere(rDimpleSphere);
        rotate([90, 180/$fn, 90])
        cylinder(h=xExtra, r=rDimpleSphere);
      }
    }
    // home mark
    if (isHome) translate([(xyCap+xExtra)/2, xyCap/2, (zCap-zCav)/2+zCav+0.2])
    {
      cube([wCross, tCross, zCap-zCav], center=true);
      cube([tCross, wCross, zCap-zCav], center=true);
    }
  }
}

difference()
{
  *keycap(1, false);
  keycap(2, false);
  *translate([-1, -1, -1]) cube([xyCap+2+9*switchPitch, xyCap/2+1, zCap+2]); // section near xz
  *translate([-1, xyCap/2, -1]) cube([xyCap+2+9*switchPitch, xyCap/2+1, zCap+2]); // section far xz
}

