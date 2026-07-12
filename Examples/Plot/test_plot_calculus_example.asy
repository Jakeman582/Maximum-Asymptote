import MaximumMathematics;

real f(real x) {return x^3 - 3*x^2 + 2*x - 1;}

Plot p = Plot();
p.set_window(-1, 10, -1, 10);
p.set_x_min(-1);
p.set_x_max(10);
p.set_grid(2, 2);

p.add(f, color=blue, type=LONG_DASH_DOTTED);

Image img = Image();
img.set_diagram_padding(0.5);
img.add(p);