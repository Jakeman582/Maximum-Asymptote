///////////////////////////////////////////////////////////////////////////////////////////////////
// DiscreteGraph - Draws a sequence of adjacent rectangles (discrete bars)
//
// Features:
// - User-configurable step size (`dx`) and number of steps
// - Anchor for the rectangle position: "left", "mid", or "right"
// - User-provided function `real func(real x)` to compute heights
// - Windowing: `xmin`, `xmax`, `ymin`, `ymax` (auto-computed if omitted)
// - Implements `render(real width, real height, real unit)` so it integrates
//   with `Image.add()` (same pattern as `RelationDiagram`)
///////////////////////////////////////////////////////////////////////////////////////////////////

// Helper: compute a "nice" tick spacing using 1,2,5 multiples
real niceNumber(real range) {
    if (range <= 0) return 0;
    real exponent = floor(log(range) / log(10));
    int e = (int)exponent;
    real pow10 = 1;
    if (e >= 0) {
        for (int i = 0; i < e; ++i) pow10 = pow10 * 10;
    } else {
        for (int i = 0; i < -e; ++i) pow10 = pow10 / 10;
    }
    real f = range / pow10;
    real nf;
    if (f < 1.5) nf = 1;
    else if (f < 3) nf = 2;
    else if (f < 7) nf = 5;
    else nf = 10;
    return nf * pow10;
}

// Compute tick positions between lo and hi with target ~n ticks
real[] compute_ticks(real lo, real hi, int n) {
    real[] ticks = new real[];
    if (hi <= lo) return ticks;
    real range = hi - lo;
    real rawStep = range / max(1, n - 1);
    real step = niceNumber(rawStep);
    if (step == 0) return ticks;
    real first = ceil(lo / step) * step;
    for (real t = first; t <= hi + 1e-12; t += step) {
        ticks.push(t);
        // safety: break if too many
        if (ticks.length > n * 4) break;
    }
    return ticks;
}


struct DiscreteGraph {
    // Private/internal fields (users should access via getters/setters)
    real _dx;
    real _first_x;
    string _anchor; // "left" | "mid" | "right"
    int _steps;

    real _xmin;
    real _xmax;
    real _ymin;
    real _ymax;

    bool _debug_mode;

    // Stored sampling function (alias `real_function_1` is defined in MaximumMathematics.asy)
    real_function_1 _func;

    real[] _heights;

    // Sample a user function at the center of each rectangle
    void sample_with_function(real_function_1 func) {
        this._heights = new real[this._steps];
        for (int k = 0; k < this._steps; ++k) {
            real left, right, center;
            if (this._anchor == "left") {
                left = this._first_x + k * this._dx;
                right = left + this._dx;
            } else if (this._anchor == "right") {
                right = this._first_x + k * this._dx;
                left = right - this._dx;
            } else {
                center = this._first_x + k * this._dx;
                left = center - this._dx / 2.0;
                right = center + this._dx / 2.0;
            }
            center = (left + right) / 2.0;
            // Sample at the anchor point: left | center | right
            real sample_x;
            if (this._anchor == "left") sample_x = left;
            else if (this._anchor == "right") sample_x = right;
            else sample_x = center;
            this._heights[k] = func(sample_x);
        }

        // Auto-compute windows if not provided (xmin==xmax treated as unset)
        if (this._xmax == this._xmin) {
            real left0, rightN;
            if (this._anchor == "left") {
                left0 = this._first_x;
                rightN = this._first_x + this._steps * this._dx;
            } else if (this._anchor == "right") {
                left0 = this._first_x - this._dx;
                rightN = this._first_x + (this._steps - 1) * this._dx;
            } else {
                left0 = this._first_x - this._dx / 2.0;
                rightN = this._first_x + (this._steps - 1) * this._dx + this._dx / 2.0;
            }
            this._xmin = left0;
            this._xmax = rightN;
        }

        if (this._ymax == this._ymin) {
            real hmin = 1e9;
            real hmax = -1e9;
            for (real h : this._heights) {
                if (h < hmin) hmin = h;
                if (h > hmax) hmax = h;
            }
            if (hmin > 0) hmin = 0; // include baseline
            real pad = (hmax - hmin) * 0.1;
            if (pad == 0) pad = 1;
            this._ymin = hmin - pad;
            this._ymax = hmax + pad;
        }
    }

    // Constructor: sample the provided function during initialization
    // Provide sensible defaults so callers can omit common parameters.
    // - dx: width of each rectangle (default 1)
    // - first_x: x position of the first rectangle (default 0)
    // - anchor: "left" | "mid" | "right" (default "left")
    // - steps: number of rectangles/steps (default 10)
    void operator init(real dx = 1, real first_x = 0, string anchor = "left", int steps = 10,
                       real_function_1 func = identity,
                       real xmin = 0, real xmax = 0,
                       real ymin = 0, real ymax = 0) {
        this._dx = dx;
        this._first_x = first_x;
        this._anchor = anchor;
        this._steps = steps;

        this._xmin = xmin;
        this._xmax = xmax;
        this._ymin = ymin;
        this._ymax = ymax;

        this._debug_mode = false;

        // Store function pointer when possible, and sample
        this._func = func;
        this.sample_with_function(func);
    }

    // Getters
    real get_dx() { return this._dx; }
    real get_first_x() { return this._first_x; }
    string get_anchor() { return this._anchor; }
    int get_steps() { return this._steps; }
    real get_xmin() { return this._xmin; }
    real get_xmax() { return this._xmax; }
    real get_ymin() { return this._ymin; }
    real get_ymax() { return this._ymax; }
    bool get_debug_mode() { return this._debug_mode; }

    // Setters (data-only; styling is global)
    void set_dx(real dx) { this._dx = dx; }
    void set_first_x(real x0) { this._first_x = x0; }
    void set_anchor(string a) { this._anchor = a; }
    void set_steps(int s) { this._steps = s; }
    void set_window(real xmin, real xmax, real ymin, real ymax) {
        // Treat equal min/max as "unset" for that axis so callers can
        // update only the x-window without clobbering an auto-computed
        // y-window (common case: set ymin==ymax==0 to indicate "auto").
        if (xmin != xmax) {
            this._xmin = xmin;
            this._xmax = xmax;
        }
        if (ymin != ymax) {
            this._ymin = ymin;
            this._ymax = ymax;
        }
    }
    void set_debug_mode(bool enabled) { this._debug_mode = enabled; }

    // Set the sampling function (updates stored function pointer and re-samples)
    void set_function(real_function_1 func) {
        this._func = func;
        this.sample_with_function(func);
    }

    // Return true if a function pointer is stored (best-effort; may always be true)
    bool get_function_exists() {
        return true; // best-effort: callers should track alternate metadata if they need exact identity
    }

    // Return the stored function pointer (as the alias type). Callers can
    // assign this to a compatible function-pointer variable.
    real_function_1 get_function() {
        return this._func;
    }

    // Convenience: call the stored function at x and return the value.
    real call_function_at(real x) {
        return this._func(x);
    }

    // Sample a user function at the center of each rectangle
    void sample_with_function(real_function_1 func) {
        this._heights = new real[this._steps];
        for (int k = 0; k < this._steps; ++k) {
            real left, right, center;
            if (this._anchor == "left") {
                left = this._first_x + k * this._dx;
                right = left + this._dx;
            } else if (this._anchor == "right") {
                right = this._first_x + k * this._dx;
                left = right - this._dx;
            } else {
                center = this._first_x + k * this._dx;
                left = center - this._dx / 2.0;
                right = center + this._dx / 2.0;
            }
            center = (left + right) / 2.0;
            // Sample at the anchor point: left | center | right
            real sample_x;
            if (this._anchor == "left") sample_x = left;
            else if (this._anchor == "right") sample_x = right;
            else sample_x = center;
            this._heights[k] = func(sample_x);
        }

        // Auto-compute windows if not provided (xmin==xmax treated as unset)
        if (this._xmax == this._xmin) {
            real left0, rightN;
            if (this._anchor == "left") {
                left0 = this._first_x;
                rightN = this._first_x + this._steps * this._dx;
            } else if (this._anchor == "right") {
                left0 = this._first_x - this._dx;
                rightN = this._first_x + (this._steps - 1) * this._dx;
            } else {
                left0 = this._first_x - this._dx / 2.0;
                rightN = this._first_x + (this._steps - 1) * this._dx + this._dx / 2.0;
            }
            this._xmin = left0;
            this._xmax = rightN;
        }

        if (this._ymax == this._ymin) {
            real hmin = 1e9;
            real hmax = -1e9;
            for (real h : this._heights) {
                if (h < hmin) hmin = h;
                if (h > hmax) hmax = h;
            }
            if (hmin > 0) hmin = 0; // include baseline
            real pad = (hmax - hmin) * 0.1;
            if (pad == 0) pad = 1;
            this._ymin = hmin - pad;
            this._ymax = hmax + pad;
        }
    }

    // Render the diagram into a picture; uses global styling pens
    picture render(real width, real height, real unit) {
        picture pic = new picture;
        unitsize(pic, unit);

        // Mapping helpers
        real mapx(real x) {
            if (this._xmax == this._xmin) return 0;
            return (x - this._xmin) / (this._xmax - this._xmin) * width;
        }
        real mapy(real y) {
            if (this._ymax == this._ymin) return 0;
            return (y - this._ymin) / (this._ymax - this._ymin) * height;
        }

        real ybase = mapy(0);

        // Collect rectangle geometry while filling; we'll draw borders afterwards
        real[] rect_left = new real[this._steps];
        real[] rect_right = new real[this._steps];
        real[] rect_x1 = new real[this._steps];
        real[] rect_x2 = new real[this._steps];
        real[] rect_y_low = new real[this._steps];
        real[] rect_y_high = new real[this._steps];

        for (int k = 0; k < this._steps; ++k) {
            real left, right, center;
            if (this._anchor == "left") {
                left = this._first_x + k * this._dx;
                right = left + this._dx;
            } else if (this._anchor == "right") {
                right = this._first_x + k * this._dx;
                left = right - this._dx;
            } else {
                center = this._first_x + k * this._dx;
                left = center - this._dx / 2.0;
                right = center + this._dx / 2.0;
            }

            // Skip rectangles entirely outside window
            if (right <= this._xmin || left >= this._xmax) {
                rect_left[k] = left;
                rect_right[k] = right;
                rect_x1[k] = 0;
                rect_x2[k] = 0;
                rect_y_low[k] = ybase;
                rect_y_high[k] = ybase;
                continue;
            }

            // Clip to window
            real draw_left = max(left, this._xmin);
            real draw_right = min(right, this._xmax);

            // Use pre-sampled height for this rectangle (sampled at center)
            real h = this._heights[k];

            // Map to diagram coords
            real x1 = mapx(draw_left);
            real x2 = mapx(draw_right);
            real y_top = mapy(h);

            // Ensure rectangle edge meets baseline (y=0) appropriately
            real y_low = min(ybase, y_top);
            real y_high = max(ybase, y_top);

            // Fill only; we'll stroke borders in a second pass to avoid overlapping strokes
            path rect = box((x1, y_low), (x2, y_high));
            fill(pic, rect, function_color_1 + fill_pen);

            // Save geometry for border drawing
            rect_left[k] = left;
            rect_right[k] = right;
            rect_x1[k] = x1;
            rect_x2[k] = x2;
            rect_y_low[k] = y_low;
            rect_y_high[k] = y_high;
        }

        // Draw exactly N+1 vertical borders (one per boundary). Use a deterministic
        // boundary formula based on anchor so we always issue one draw call per boundary.
        real base;
        if (this._anchor == "left") base = this._first_x;
        else if (this._anchor == "right") base = this._first_x - this._dx;
        else base = this._first_x - this._dx/2.0;

        for (int j = 0; j <= this._steps; ++j) {
            real bx = base + j * this._dx; // data-space boundary
            real bx_m = mapx(bx);

            // Compute union vertical span across adjacent rectangles (use saved clipped coords)
            real union_top = -1e9;
            real union_bot = 1e9;
            // left neighbor (j-1)
            if (j - 1 >= 0 && j - 1 < this._steps) {
                union_top = max(union_top, rect_y_high[j - 1]);
                union_bot = min(union_bot, rect_y_low[j - 1]);
            }
            // right neighbor (j)
            if (j < this._steps) {
                union_top = max(union_top, rect_y_high[j]);
                union_bot = min(union_bot, rect_y_low[j]);
            }

            // If union is degenerate (no neighbor data), fallback to baseline
            if (union_top < -1e8 && union_bot > 1e8) {
                union_top = ybase;
                union_bot = ybase;
            }

            // Draw vertical border covering the union (may be off-canvas; Asymptote will clip)
            draw(pic, (bx_m, union_bot)--(bx_m, union_top), p=function_color_1 + outline_pen);
        }

        // Draw horizontal borders per-rectangle: only the border that is not on the axis
        for (int k = 0; k < this._steps; ++k) {
            real x1 = rect_x1[k];
            real x2 = rect_x2[k];
            // skipped rects have x1==x2==0
            if (x1 == x2) continue;
            real y_low = rect_y_low[k];
            real y_high = rect_y_high[k];
            // If top is not on axis, draw top edge
            if (y_high != ybase) {
                draw(pic, (x1, y_high)--(x2, y_high), p=function_color_1 + outline_pen);
            }
            // If bottom is not on axis, draw bottom edge
            if (y_low != ybase) {
                draw(pic, (x1, y_low)--(x2, y_low), p=function_color_1 + outline_pen);
            }
        }

        // Draw axes: choose zero-axis (x=0 or y=0) if inside window; otherwise draw edge axes
        real tickLenX = width * 0.02;
        real tickLenY = height * 0.02;
        real labelOffsetX = width * 0.01;
        real labelOffsetY = height * 0.02;

        // Prepare ticks
        real[] yTicks = compute_ticks(this._ymin, this._ymax, 5);
        real[] xTicks = compute_ticks(this._xmin, this._xmax, 6);

        bool x0_in = (this._xmin <= 0 && this._xmax >= 0);
        bool y0_in = (this._ymin <= 0 && this._ymax >= 0);

        // Vertical axis: use x=0 if inside, otherwise use left edge (xmin)
        real axis_x_data = x0_in ? 0 : this._xmin;
        real ax_m = mapx(axis_x_data);
        draw(pic, (ax_m, mapy(this._ymin))--(ax_m, mapy(this._ymax)), p=axis_color + axis_thickness);
        for (real t : yTicks) {
            real ym = mapy(t);
            // tick direction: to the right for left-edge axis, to the right for x=0 too
            draw(pic, (ax_m, ym)--(ax_m + tickLenX, ym), p=axis_color + axis_thickness);
            // label: align to the west of the tick (centered vertically)
            label(pic, string(t), (ax_m - tickLenX - labelOffsetX, ym), align=W, p=text_small.p);
        }

        // Horizontal axis: use y=0 if inside, otherwise use bottom edge (ymin)
        real axis_y_data = y0_in ? 0 : this._ymin;
        real ay_m = mapy(axis_y_data);
        draw(pic, (mapx(this._xmin), ay_m)--(mapx(this._xmax), ay_m), p=axis_color + axis_thickness);
        for (real t : xTicks) {
            real xm = mapx(t);
            draw(pic, (xm, ay_m)--(xm, ay_m + tickLenY), p=axis_color + axis_thickness);
            // horizontal tick labels: centered below the tick (south)
            label(pic, string(t), (xm, ay_m - tickLenY - labelOffsetY), align=S, p=text_small.p);
        }

        // Debug: draw window border
        if (this._debug_mode) {
            draw(pic, box((0,0),(width, height)), p=gray + linewidth(0.5));
        }

        return pic;
    }
};

// (No default identity overload here — callers should pass a `real_function_1` explicitly.)
