////////////////////////////////////////////////////////////////////////////////////////////////////
// File: Conic.asy
//
// Description:
// A general conic section, stored in standard form A*x^2 + B*y^2 + C*x*y + D*x + E*y + F = 0. This
// single form covers every conic — circle, ellipse, parabola, hyperbola, and their degenerate cases
// (a point, a line, a pair of lines) — depending on the coefficients, with no special-casing.
// as_implicit() exposes it as an implicit_2, addable to a Plot directly.
// Below the struct, conic_circle/conic_ellipse/conic_hyperbola/conic_parabola build one from the
// parameters each shape is naturally described by, rather than raw A..F — named with a conic_ prefix
// since Asymptote's own plain library already defines circle(pair, real) and ellipse(pair, real,
// real) as path constructors, which these would otherwise collide with.
////////////////////////////////////////////////////////////////////////////////////////////////////

// Orientation for hyperbola/parabola: which axis the conic is symmetric about. HORIZONTAL means a
// horizontal transverse/symmetry axis (a hyperbola opening left-right; a parabola opening left-right
// with a vertical directrix). VERTICAL means a vertical transverse/symmetry axis (a hyperbola opening
// up-down; a parabola opening up-down with a horizontal directrix — the familiar y = x^2 shape).
string HORIZONTAL = "horizontal";
string VERTICAL = "vertical";

// A conic section A*x^2 + B*y^2 + C*x*y + D*x + E*y + F = 0.
struct Conic {
    real A, B, C, D, E, F;

    void operator init(real A, real B, real C, real D, real E, real F) {
        this.A = A;
        this.B = B;
        this.C = C;
        this.D = D;
        this.E = E;
        this.F = F;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Function: evaluate
    //
    // Description:
    // Evaluate A*x^2 + B*y^2 + C*x*y + D*x + E*y + F at a point. Zero exactly on the conic, nonzero
    // everywhere else.
    //
    // Inputs:
    //    x - x-coordinate of the point.
    //    y - y-coordinate of the point.
    //
    // Outputs:
    //    result - A*x^2 + B*y^2 + C*x*y + D*x + E*y + F.
    ////////////////////////////////////////////////////////////////////////////////////////////////
    real evaluate(real x, real y) {
        return this.A * x * x + this.B * y * y + this.C * x * y
             + this.D * x + this.E * y + this.F;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Function: as_implicit
    //
    // Description:
    // Expose this conic as an implicit_2 closure bound to this instance's coefficients, so it can be
    // handed directly to Plot's implicit add() overload.
    //
    // Inputs: None
    //
    // Outputs:
    //    fn - An implicit_2 (real(real, real)) equivalent to this.evaluate.
    ////////////////////////////////////////////////////////////////////////////////////////////////
    implicit_2 as_implicit() {
        return new real(real x, real y) { return this.evaluate(x, y); };
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: conic_circle
//
// Description:
// Build the circle (x - center_x)^2 + (y - center_y)^2 = radius^2, expanded to standard form.
//
// Inputs:
//    center_x - x-coordinate of the center.
//    center_y - y-coordinate of the center.
//    radius   - The circle's radius.
//
// Outputs:
//    conic - The resulting Conic.
////////////////////////////////////////////////////////////////////////////////////////////////////
Conic conic_circle(real center_x, real center_y, real radius) {
    real r2 = radius * radius;
    return Conic(1, 1, 0,
                 -2 * center_x, -2 * center_y,
                 center_x * center_x + center_y * center_y - r2);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: conic_ellipse
//
// Description:
// Build the axis-aligned ellipse ((x - center_x)/radius_x)^2 + ((y - center_y)/radius_y)^2 = 1,
// expanded to standard form.
//
// Inputs:
//    center_x - x-coordinate of the center.
//    center_y - y-coordinate of the center.
//    radius_x - Semi-axis length in the x direction.
//    radius_y - Semi-axis length in the y direction.
//
// Outputs:
//    conic - The resulting Conic.
////////////////////////////////////////////////////////////////////////////////////////////////////
Conic conic_ellipse(real center_x, real center_y, real radius_x, real radius_y) {
    real a2 = radius_x * radius_x;
    real b2 = radius_y * radius_y;
    return Conic(b2, a2, 0,
                 -2 * b2 * center_x, -2 * a2 * center_y,
                 b2 * center_x * center_x + a2 * center_y * center_y - a2 * b2);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: conic_hyperbola
//
// Description:
// Build the axis-aligned hyperbola centered at (center_x, center_y) with semi-axes radius_x/radius_y,
// expanded to standard form. orientation selects which axis is the transverse axis (the one the
// hyperbola opens along): HORIZONTAL gives ((x-center_x)/radius_x)^2 - ((y-center_y)/radius_y)^2 = 1
// (opens left-right); VERTICAL gives ((y-center_y)/radius_y)^2 - ((x-center_x)/radius_x)^2 = 1 (opens
// up-down).
//
// Inputs:
//    center_x    - x-coordinate of the center.
//    center_y    - y-coordinate of the center.
//    radius_x    - Semi-axis length in the x direction.
//    radius_y    - Semi-axis length in the y direction.
//    orientation - HORIZONTAL (default) or VERTICAL.
//
// Outputs:
//    conic - The resulting Conic.
////////////////////////////////////////////////////////////////////////////////////////////////////
Conic conic_hyperbola(real center_x, real center_y, real radius_x, real radius_y,
                       string orientation = HORIZONTAL) {
    real a2 = radius_x * radius_x;
    real b2 = radius_y * radius_y;
    if (orientation == HORIZONTAL) {
        return Conic(b2, -a2, 0,
                     -2 * b2 * center_x, 2 * a2 * center_y,
                     b2 * center_x * center_x - a2 * center_y * center_y - a2 * b2);
    } else {
        return Conic(-b2, a2, 0,
                     2 * b2 * center_x, -2 * a2 * center_y,
                     -b2 * center_x * center_x + a2 * center_y * center_y - a2 * b2);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: conic_parabola
//
// Description:
// Build the parabola with vertex (center_x, center_y), expanded to standard form from vertex form.
// With h = center_x, k = center_y, a = scale, orientation selects which of the two vertex-form
// equations is being expressed:
//    VERTICAL (default):   y = a(x - h)^2 + k   — the familiar y = x^2 shape, opening up if a > 0,
//                           down if a < 0.
//    HORIZONTAL:            x = a(y - h)^2 + k   — opening right if a > 0, left if a < 0.
// scale (a) is that equation's leading coefficient — larger magnitude means a narrower parabola.
// (scale relates to the focus/directrix form by scale = 1/(4p), where p is the distance from the
// vertex to the focus, equivalently to the directrix.)
//
// Inputs:
//    center_x    - x-coordinate of the vertex (h).
//    center_y    - y-coordinate of the vertex (k).
//    scale       - Leading coefficient (a); sign sets the opening direction, magnitude sets
//                  narrowness.
//    orientation - VERTICAL (default), for y = a(x - h)^2 + k, or HORIZONTAL, for
//                  x = a(y - h)^2 + k.
//
// Outputs:
//    conic - The resulting Conic.
////////////////////////////////////////////////////////////////////////////////////////////////////
Conic conic_parabola(real center_x, real center_y, real scale, string orientation = VERTICAL) {
    if (orientation == VERTICAL) {
        return Conic(scale, 0, 0,
                     -2 * scale * center_x, -1,
                     scale * center_x * center_x + center_y);
    } else {
        return Conic(0, scale, 0,
                     -1, -2 * scale * center_y,
                     scale * center_y * center_y + center_x);
    }
}
