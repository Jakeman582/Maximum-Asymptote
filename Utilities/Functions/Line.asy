////////////////////////////////////////////////////////////////////////////////////////////////////
// File: Line.asy
//
// Description:
// A general line, stored in standard form a*x + b*y + c = 0. Standard form represents any line —
// vertical, horizontal, or slanted — with no special-casing, unlike slope-intercept form (y = m*x +
// b), which cannot express a vertical line at all. Convenience constructors below build a Line from
// whichever form is most natural for the caller; as_implicit() exposes it as an implicit_2, addable
// to a Plot directly.
////////////////////////////////////////////////////////////////////////////////////////////////////

// A line a*x + b*y + c = 0.
struct Line {
    real a, b, c;

    void operator init(real a, real b, real c) {
        this.a = a;
        this.b = b;
        this.c = c;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Function: evaluate
    //
    // Description:
    // Evaluate a*x + b*y + c at a point. Zero exactly on the line, nonzero (sign indicates which
    // side) everywhere else.
    //
    // Inputs:
    //    x - x-coordinate of the point.
    //    y - y-coordinate of the point.
    //
    // Outputs:
    //    result - a*x + b*y + c.
    ////////////////////////////////////////////////////////////////////////////////////////////////
    real evaluate(real x, real y) {
        return this.a * x + this.b * y + this.c;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Function: as_implicit
    //
    // Description:
    // Expose this line as an implicit_2 closure bound to this instance's a/b/c, so it can be handed
    // directly to Plot's implicit add() overload.
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
// Function: vertical_line
//
// Description:
// Build the vertical line x = x0. Standard form: 1*x + 0*y - x0 = 0.
//
// Inputs:
//    x0 - The x-coordinate every point on the line shares.
//
// Outputs:
//    line - The resulting Line.
////////////////////////////////////////////////////////////////////////////////////////////////////
Line vertical_line(real x0) {
    return Line(1, 0, -x0);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: horizontal_line
//
// Description:
// Build the horizontal line y = y0. Standard form: 0*x + 1*y - y0 = 0.
//
// Inputs:
//    y0 - The y-coordinate every point on the line shares.
//
// Outputs:
//    line - The resulting Line.
////////////////////////////////////////////////////////////////////////////////////////////////////
Line horizontal_line(real y0) {
    return Line(0, 1, -y0);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: line_from_slope_intercept
//
// Description:
// Build the line y = slope*x + y_intercept. Standard form: slope*x - 1*y + y_intercept = 0. Cannot
// represent a vertical line (undefined slope) — use vertical_line() for that case instead.
//
// Inputs:
//    slope       - The line's slope.
//    y_intercept - The line's y-intercept.
//
// Outputs:
//    line - The resulting Line.
////////////////////////////////////////////////////////////////////////////////////////////////////
Line line_from_slope_intercept(real slope, real y_intercept) {
    return Line(slope, -1, y_intercept);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: line_from_two_points
//
// Description:
// Build the line through p1 and p2. Standard form derived from the direction vector (dx, dy) =
// p2 - p1: dy*x - dx*y + (dx*p1.y - dy*p1.x) = 0. Works uniformly whether the two points form a
// vertical line (dx = 0), a horizontal line (dy = 0), or a slanted one — no division, so no
// special-casing needed.
//
// Inputs:
//    p1 - The first point on the line.
//    p2 - The second point on the line.
//
// Outputs:
//    line - The resulting Line.
////////////////////////////////////////////////////////////////////////////////////////////////////
Line line_from_two_points(pair p1, pair p2) {
    real dx = p2.x - p1.x;
    real dy = p2.y - p1.y;
    return Line(dy, -dx, dx * p1.y - dy * p1.x);
}
