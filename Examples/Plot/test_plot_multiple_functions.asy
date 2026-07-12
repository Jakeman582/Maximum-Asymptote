import MaximumMathematics;

// Example: two functions on one continuous Plot, sharing an x-domain and window.

real f1(real x) {return sin(x);}
real f2(real x) {return cos(x);}
real f3(real x) {return tan(x);}
real f4(real x) {return x;}
real f5(real x) {return log(x);}
real f6(real x) {return sqrt(x);}
real f7(real x) {return exp(x);}

Plot p = Plot();
p.set_window(-10, 10, -10, 10);
p.set_x_min(-10);
p.set_x_max(10);
p.add(f1);
p.add(f2);
p.add(f3);
p.add(f4);
p.add(f5, left_marker=ARROW);
p.add(f6);
p.add(f7);

Image img = Image(14, 14);
img.set_diagram_padding(0.5);
//img.caption_title("Figure");
//img.caption_text("$x^2$ and $x^3$ over [-4, 4], colors auto-assigned from the theme palette.");
img.add(p);

// Note: run `asy Examples/Plot/test_plot_multiple_functions.asy` to render
