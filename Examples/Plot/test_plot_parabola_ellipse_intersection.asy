import MaximumMathematics;

// Example: one explicit function (a parabola) typed as real_function_1, and one hand-defined
// implicit function (an ellipse, x-radius 4 and y-radius 3 — defined directly here rather than via
// the library's conic_ellipse() convenience) typed as implicit_2, both from Utilities/FunctionTypes.asy,
// on one Plot, chosen so the two curves cross at exactly 4 points. The plot and its legend are laid
// out side by side in a 1x2 Gallery.

real_function_1 parabola = new real(real x) {             // y = x^2 - 4
    return x*x - 4;
};

implicit_2 ellipse = new real(real x, real y) {            // x^2/16 + y^2/9 = 1
    return x*x/16 + y*y/9 - 1;
};

Plot p = Plot(-6, 6);
p.set_window(-6, 6, -6, 6);
p.add(parabola, color=blue, label="$y = x^2 - 4$");
p.add(ellipse, color=red, label="$x^2/16 + y^2/9 = 1$");

Image img = Image(10, 10);
img.add(p);

Gallery g = Gallery(1, 2, 10, 10);
g.add(img.pic, 0, 0);
g.add(p.legend(10), 0, 1);   // height matches the Gallery's visual_height, so the legend's top row
                             // lines up with the plot's own square top instead of hugging the bottom

// Note: run `asy Examples/Plot/test_plot_parabola_ellipse_intersection.asy` to render
