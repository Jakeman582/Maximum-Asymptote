size(5cm, 0);

import three;
import graph3;
import palette;
import animation;

import MaximumMathematics;

real f(pair z) {
  real x = z.x;
  real y = z.y;
  return x^2 + y^2;
}

real xmax = sqrt(12/5), xmin = -xmax;
real ymax = sqrt(12/5), ymin = -ymax;

surface s = surface(f, (xmin, ymin), (xmax, ymax), 40, Spline);

pen[] spen = Gradient(function_color_1, function_color_2);
pen[][] color_map = palette(s.map(zpart), spen);

// Create animation
animation A;

int nFrames = 90;

currentprojection = orthographic(11, 5, 7);

viewportmargin = 0;
triple bbox_min = (xmin, ymin, f((xmin, ymin)));
triple bbox_max = (xmax, ymax, f((0, 0)) + 0.5); // Add a buffer if needed

// Invisible bounding cube to fix the scene
draw((bbox_min.x, bbox_min.y, bbox_min.z) -- (bbox_max.x, bbox_min.y, bbox_min.z), invisible);
draw((bbox_max.x, bbox_max.y, bbox_max.z) -- (bbox_min.x, bbox_max.y, bbox_max.z), invisible);
draw((bbox_min.x, bbox_min.y, bbox_min.z) -- (bbox_min.x, bbox_max.y, bbox_min.z), invisible);
draw((bbox_max.x, bbox_min.y, bbox_min.z) -- (bbox_max.x, bbox_max.y, bbox_min.z), invisible);
draw((bbox_max.x, bbox_max.y, bbox_max.z) -- (bbox_max.x, bbox_min.y, bbox_max.z), invisible);
draw((bbox_min.x, bbox_max.y, bbox_max.z) -- (bbox_min.x, bbox_min.y, bbox_max.z), invisible);

for (int i = 0; i < nFrames; ++i) {

  save();

  //picture frme;
  //size(frme, 5cm, 0);

  //triple eye = rotate(i, Z) * (10, 4, 7);

  // Rotate surface around z-axis
  transform3 T = rotate(i, Z);

  draw(T * s, mean(color_map), nullpen, light = nolight);

  A.add();
  //erase();
  restore();
}

A.movie(loops = 0, delay = 100);