////////////////////////////////////////////////////////////////////////////////////////////////////
// File: ContinuousPlot.asy
//
// Description:
// Continuous function plot — the standard smooth graph of one or more real(real) functions over a
// shared x-domain and viewport, as opposed to DiscretePlot's discrete bar/step sampling. Functions
// are added via add(), with an optional explicit pen for color-coordinating specific functions;
// every function left on auto-color is resolved at render() time via the theme's
// plot_function_colors(), since the rainbow policy depends on how many functions need an auto
// color, not just each function's position — explicitly colored functions are excluded from that
// count entirely, so the auto-colored ones still spread across the full gradient among themselves.
// "Plot" is a type alias for this struct (see the bottom of this file) — most callers should just
// use Plot; ContinuousPlot is the canonical name.
////////////////////////////////////////////////////////////////////////////////////////////////////

// Endpoint marker styles for the true left/right ends of a function's plotted curve (add()'s
// left_marker/right_marker). AUTO's default is ARROW at the function's true outermost visible
// point — whatever cut it short there, a domain/display edge or a window boundary. Any cut that
// isn't the function's true leftmost/rightmost point (an interior window-boundary crossing, or
// resuming after a NaN gap partway through) always draws with no marker regardless of
// left_marker/right_marker, since only the outermost ends are eligible for a marker at all.
// Override left_marker/right_marker when ARROW isn't right for a specific function — e.g. sqrt(x)
// is actually defined and finite at x=0, so CLOSED_DOT reads better there than an arrow implying
// the curve keeps going. NONE suppresses the marker at that end entirely, including AUTO's arrow.
string ARROW = "arrow";
string OPEN_DOT = "open_dot";
string CLOSED_DOT = "closed_dot";
string OPEN_INTERVAL = "open_interval";
string CLOSED_INTERVAL = "closed_interval";
string NONE = "none";
string AUTO = "auto";

// Line type constants for add()'s type parameter — plain aliases for Asymptote's own built-in
// dash-pattern pens (plain_pens.asy), so any Asymptote linetype pen works here too, not just these
// six. SOLID is the default.
pen SOLID = solid;
pen DOTTED = dotted;
pen DASHED = dashed;
pen LONG_DASHED = longdashed;
pen DASH_DOTTED = dashdotted;
pen LONG_DASH_DOTTED = longdashdotted;

// Sentinel for add()'s color parameter, meaning "no explicit color — auto-assign one from the
// rainbow palette at render() time." An out-of-gamut RGB value, since it must be a pen no caller
// would ever legitimately want to pass; ordinary pens (including black) always compare unequal to
// it (verified: colors() clamps it to (0,0,0) on query, but pen equality does not, so this is safe).
pen AUTO_COLOR = rgb(-1, -1, -1);

struct ContinuousPlot {
    // Private/internal fields (users should access via getters/setters)
    real_function_1[] _functions;
    string[] _left_markers;
    string[] _right_markers;
    bool[] _has_explicit_color;
    pen[] _explicit_colors;
    pen[] _types;

    // x-domain: the range over which functions are evaluated. The curve does not extend past this,
    // even if the window is wider.
    real _x_min;
    real _x_max;

    // Window: the viewport. Left/right default to the domain when unset; bottom/top are always
    // auto-computed from sampled y-values unless explicitly overridden. These fields hold the most
    // recently resolved values (refreshed on every render()), which is what the getters return.
    real _window_left;
    real _window_right;
    real _window_bottom;
    real _window_top;
    bool _window_left_set;
    bool _window_right_set;
    bool _window_bottom_set;
    bool _window_top_set;

    bool _debug_mode;

    // Grid: off by default. Lines start at the axes and extend outward by delta_x/delta_y —
    // not the "nice round number" spacing the tick marks use, but exactly the spacing given.
    bool _grid_enabled;
    real _grid_delta_x;
    real _grid_delta_y;

    void operator init(real x_min = -5, real x_max = 5) {
        this._x_min = x_min;
        this._x_max = x_max;

        this._functions = new real_function_1[];
        this._left_markers = new string[];
        this._right_markers = new string[];
        this._has_explicit_color = new bool[];
        this._explicit_colors = new pen[];
        this._types = new pen[];

        this._window_left = 0;
        this._window_right = 0;
        this._window_bottom = 0;
        this._window_top = 0;
        this._window_left_set = false;
        this._window_right_set = false;
        this._window_bottom_set = false;
        this._window_top_set = false;

        this._debug_mode = false;

        this._grid_enabled = false;
        this._grid_delta_x = 1;
        this._grid_delta_y = 1;
    }

    // Add a function to the plot.
    //
    // color: any ordinary Asymptote pen (a named color, RGB(...), rgb(...), etc.) to
    // color-coordinate this function instead of letting the rainbow palette assign one. Left at
    // its default (the AUTO_COLOR sentinel — just omit this argument), the function's color is
    // resolved at render() time via the theme's plot_function_colors(), against however many
    // functions are left on auto-color at that point; explicitly colored functions don't count
    // against that share, so the auto-colored ones still spread across the full gradient among
    // themselves. color and type are separate parameters (rather than folded into one pen the
    // caller composes with +) specifically so type can be set independently of an auto-assigned
    // color — combining them into one pen would make "auto color, explicit type" inexpressible.
    //
    // type: one of SOLID/DOTTED/DASHED/LONG_DASHED/DASH_DOTTED/LONG_DASH_DOTTED above (or any
    // other Asymptote linetype pen). Applies only to the curve itself, not its endpoint markers,
    // which are always drawn with a solid outline regardless.
    //
    // left_marker/right_marker set what's drawn at this function's true left/right ends (see the
    // ARROW/OPEN_DOT/CLOSED_DOT/OPEN_INTERVAL/CLOSED_INTERVAL/NONE constants above); AUTO's default
    // is ARROW. These only apply to the function's overall first/last visible point — any other cut
    // (an interior window-boundary crossing, or the start of a new run after a NaN gap) always
    // draws with no marker, regardless of what's asked for at the function's true ends.
    void add(real_function_1 func, pen color = AUTO_COLOR, pen type = SOLID,
             string left_marker = AUTO, string right_marker = AUTO) {
        this._functions.push(func);
        this._left_markers.push(left_marker);
        this._right_markers.push(right_marker);
        this._has_explicit_color.push(color != AUTO_COLOR);
        this._explicit_colors.push(color);
        this._types.push(type);
    }

    // Getters
    real get_x_min() { return this._x_min; }
    real get_x_max() { return this._x_max; }
    real get_window_left() { return this._window_left; }
    real get_window_right() { return this._window_right; }
    real get_window_bottom() { return this._window_bottom; }
    real get_window_top() { return this._window_top; }
    bool get_debug_mode() { return this._debug_mode; }
    real get_grid_delta_x() { return this._grid_delta_x; }
    real get_grid_delta_y() { return this._grid_delta_y; }
    bool get_grid_mode() { return this._grid_enabled; }

    // Setters
    void set_x_min(real x_min) { this._x_min = x_min; }
    void set_x_max(real x_max) { this._x_max = x_max; }
    void set_window_left(real left) { this._window_left = left; this._window_left_set = true; }
    void set_window_right(real right) { this._window_right = right; this._window_right_set = true; }
    void set_window_bottom(real bottom) { this._window_bottom = bottom; this._window_bottom_set = true; }
    void set_window_top(real top) { this._window_top = top; this._window_top_set = true; }

    // Convenience: set all four window bounds at once (unconditionally, no "unset" sentinel).
    void set_window(real left, real right, real bottom, real top) {
        set_window_left(left);
        set_window_right(right);
        set_window_bottom(bottom);
        set_window_top(top);
    }

    void set_debug_mode(bool enabled) { this._debug_mode = enabled; }

    // Grid setters. Lines start at the axes and extend outward by delta_x (vertical lines) and
    // delta_y (horizontal lines) — the axis itself isn't redrawn as a grid line.
    void set_grid_delta_x(real delta_x) { this._grid_delta_x = delta_x; }
    void set_grid_delta_y(real delta_y) { this._grid_delta_y = delta_y; }
    void set_grid_mode(bool enabled) { this._grid_enabled = enabled; }

    // Convenience: set both deltas and enable the grid in one call.
    void set_grid(real delta_x = 1, real delta_y = 1) {
        this._grid_delta_x = delta_x;
        this._grid_delta_y = delta_y;
        this._grid_enabled = true;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Function: render
    //
    // Description:
    // Resolve the window from the domain and any explicit overrides, sample every added function,
    // and draw the curves and axes into a picture. Resolution happens here rather than at add()
    // time because the auto-computed bottom/top depend on every function that has been added so
    // far, and functions can still be added after any earlier render(); resolved bounds are cached
    // into this._window_* on each call so the getters reflect the last-rendered state.
    //
    // Inputs:
    //    width  - Plot width in the given unit.
    //    height - Plot height in the given unit.
    //    unit   - Unit size for the returned picture.
    //
    // Outputs:
    //    pic - The rendered picture containing the plot.
    ////////////////////////////////////////////////////////////////////////////////////////////////
    picture render(real width, real height, real unit) {
        picture pic = new picture;
        unitsize(pic, unit);

        // Resolve the viewport: left/right default to the domain, bottom/top are resolved below
        // once every function has been sampled.
        real left = this._window_left_set ? this._window_left : this._x_min;
        real right = this._window_right_set ? this._window_right : this._x_max;

        // Sample only where domain and window overlap — the curve doesn't extend past the domain,
        // and there's no need to sample outside the visible window.
        real sample_min = max(this._x_min, left);
        real sample_max = min(this._x_max, right);
        bool has_range = sample_max > sample_min;

        int sample_count = 200; // matches Asymptote's own graph module default (ngraph)
        real[] sample_xs = new real[0];
        real[][] sample_ys = new real[this._functions.length][];

        real hmin = 1e9;
        real hmax = -1e9;

        if (has_range) {
            sample_xs = new real[sample_count];
            for (int i = 0; i < sample_count; ++i) {
                sample_xs[i] = sample_min + i * (sample_max - sample_min) / (sample_count - 1);
            }
            for (int f = 0; f < this._functions.length; ++f) {
                real[] ys = new real[sample_count];
                for (int i = 0; i < sample_count; ++i) {
                    ys[i] = this._functions[f](sample_xs[i]);
                    if (ys[i] < hmin) hmin = ys[i];
                    if (ys[i] > hmax) hmax = ys[i];
                }
                sample_ys[f] = ys;
            }
        }

        // Resolve bottom/top: auto-compute from sampled y-values with padding, unless overridden.
        // Guard the case where nothing was sampled (no functions added, or a degenerate range) with
        // a hardcoded fallback rather than letting an inverted hmin/hmax range through.
        real bottom = this._window_bottom;
        real top = this._window_top;
        if (!this._window_bottom_set || !this._window_top_set) {
            real auto_bottom, auto_top;
            if (hmin <= hmax) {
                real pad = (hmax - hmin) * 0.1;
                if (pad == 0) pad = 1;
                auto_bottom = hmin - pad;
                auto_top = hmax + pad;
            } else {
                auto_bottom = -1;
                auto_top = 1;
            }
            if (!this._window_bottom_set) bottom = auto_bottom;
            if (!this._window_top_set) top = auto_top;
        }

        // Cache the resolved viewport so getters reflect the last-rendered state.
        this._window_left = left;
        this._window_right = right;
        this._window_bottom = bottom;
        this._window_top = top;

        // Mapping helpers: use one uniform scale for both axes so a data slope renders at its
        // true geometric angle (e.g. a slope-1 line looks like an actual 45-degree line) —
        // independently stretching x and y to fill width/height distorts slopes whenever the
        // box's aspect ratio doesn't match the window's. The smaller of the two per-axis scales
        // is used for both, and the resulting (smaller) render area is centered within the given
        // width/height — like letterboxing — leaving blank margin on whichever axis had room to
        // spare, rather than growing the numeric window to fill it.
        real x_range = right - left;
        real y_range = top - bottom;
        real scale = 1;
        real render_width = width;
        real render_height = height;
        if (x_range > 0 && y_range > 0) {
            scale = min(width / x_range, height / y_range);
            render_width = x_range * scale;
            render_height = y_range * scale;
        }
        real offset_x = (width - render_width) / 2;
        real offset_y = (height - render_height) / 2;

        real mapx(real x) {
            if (right == left) return offset_x;
            return offset_x + (x - left) * scale;
        }
        real mapy(real y) {
            if (top == bottom) return offset_y;
            return offset_y + (y - bottom) * scale;
        }

        // Where the axes themselves sit: at x=0/y=0 if that's inside the window, otherwise at the
        // window's edge. Computed once here so both the grid (below) and the axes (drawn later)
        // agree on exactly where "the axis" is.
        bool x0_in = (left <= 0 && right >= 0);
        bool y0_in = (bottom <= 0 && top >= 0);
        real axis_x_data = x0_in ? 0 : left;
        real axis_y_data = y0_in ? 0 : bottom;

        // Draw the grid (if enabled) before the curves and axes, so both render on top of it.
        // Lines start at the axes and extend outward every delta_x/delta_y — the axis's own
        // position (k=0) is skipped, since the axis line itself is drawn separately, on top.
        if (this._grid_enabled) {
            if (this._grid_delta_x > 0) {
                int k_min = (int)ceil((left - axis_x_data) / this._grid_delta_x - 1e-9);
                int k_max = (int)floor((right - axis_x_data) / this._grid_delta_x + 1e-9);
                for (int k = k_min; k <= k_max; ++k) {
                    if (k == 0) continue;
                    real gx = mapx(axis_x_data + k * this._grid_delta_x);
                    draw(pic, (gx, mapy(bottom))--(gx, mapy(top)), p=grid_color + grid_thickness);
                }
            }
            if (this._grid_delta_y > 0) {
                int k_min = (int)ceil((bottom - axis_y_data) / this._grid_delta_y - 1e-9);
                int k_max = (int)floor((top - axis_y_data) / this._grid_delta_y + 1e-9);
                for (int k = k_min; k <= k_max; ++k) {
                    if (k == 0) continue;
                    real gy = mapy(axis_y_data + k * this._grid_delta_y);
                    draw(pic, (mapx(left), gy)--(mapx(right), gy), p=grid_color + grid_thickness);
                }
            }
        }

        // Draw axes: choose zero-axis (x=0 or y=0) if inside window; otherwise draw edge axes.
        // Arrow-tipped (axis_arrow is bidirectional) since the axis extends beyond the visible window.
        // Tick/label sizing is based on the actual rendered plot area, not the full given box, so
        // they stay proportionate to the plot even when it's letterboxed within a larger box.
        // Drawn after the grid (so axes sit on top of it) but before the functions (so functions,
        // drawn next in add() order, sit on top of the axes).
        real tickLenX = render_width * 0.02;
        real tickLenY = render_height * 0.02;
        real labelOffsetX = render_width * 0.01;
        real labelOffsetY = render_height * 0.02;

        real[] yTicks = compute_ticks(bottom, top, 5);
        real[] xTicks = compute_ticks(left, right, 6);

        // When both axes cross zero, the "0" tick on each axis lands right at their shared
        // intersection — labeling it twice (once west, once south) is redundant clutter. Skip
        // both individual zero ticks in that case and draw a single "0" near the intersection
        // instead, once the axes themselves are drawn below.
        bool origin_visible = x0_in && y0_in;

        real ax_m = mapx(axis_x_data);
        draw(pic, (ax_m, mapy(bottom))--(ax_m, mapy(top)), p=axis_color + axis_thickness, arrow=axis_arrow);
        for (real t : yTicks) {
            if (origin_visible && abs(t) < 1e-9) continue;
            real ym = mapy(t);
            draw(pic, (ax_m, ym)--(ax_m + tickLenX, ym), p=axis_color + axis_thickness);
            label(pic, string(t), (ax_m - tickLenX - labelOffsetX, ym), align=W, p=text_small);
        }

        real ay_m = mapy(axis_y_data);
        draw(pic, (mapx(left), ay_m)--(mapx(right), ay_m), p=axis_color + axis_thickness, arrow=axis_arrow);
        for (real t : xTicks) {
            if (origin_visible && abs(t) < 1e-9) continue;
            real xm = mapx(t);
            draw(pic, (xm, ay_m)--(xm, ay_m + tickLenY), p=axis_color + axis_thickness);
            label(pic, string(t), (xm, ay_m - tickLenY - labelOffsetY), align=S, p=text_small);
        }

        // Single "0" label at the axis intersection, offset diagonally into whichever quadrant
        // encloses the least area — that's the quadrant least likely to already be busy with
        // curves, so the label stays out of the way while still sitting next to the origin.
        if (origin_visible) {
            real area_top_right    = (right - 0) * (top - 0);
            real area_top_left     = (0 - left) * (top - 0);
            real area_bottom_right = (right - 0) * (0 - bottom);
            real area_bottom_left  = (0 - left) * (0 - bottom);
            real min_area = min(area_top_right, min(area_top_left, min(area_bottom_right, area_bottom_left)));

            real zero_offset_x = tickLenX + labelOffsetX;
            real zero_offset_y = tickLenY + labelOffsetY;
            pair zero_pos;
            if (min_area == area_bottom_left) zero_pos = (ax_m - zero_offset_x, ay_m - zero_offset_y);
            else if (min_area == area_bottom_right) zero_pos = (ax_m + zero_offset_x, ay_m - zero_offset_y);
            else if (min_area == area_top_left) zero_pos = (ax_m - zero_offset_x, ay_m + zero_offset_y);
            else zero_pos = (ax_m + zero_offset_x, ay_m + zero_offset_y);

            label(pic, "0", zero_pos, p=text_small);
        }

        // A sample can be NaN (e.g. log/sqrt of a negative number) where the function is simply
        // undefined, rather than merely outside the window. Asymptote comparisons with NaN are
        // always false, so is_finite() must be checked explicitly — self-inequality is the
        // standard NaN test (NaN is the only value unequal to itself); the magnitude bound also
        // excludes the rare case of true infinity.
        bool is_finite(real y) {
            return y == y && y > -1e300 && y < 1e300;
        }

        // Interpolate the (x,y) point where the segment from (x0,y0) to (x1,y1) crosses whichever
        // window boundary the outside endpoint violates. Only called with two finite endpoints —
        // a NaN endpoint has no meaningful crossing, since the function isn't continuous through it.
        pair boundary_crossing(real x0, real y0, real x1, real y1, bool start_inside) {
            real outside_y = start_inside ? y1 : y0;
            real target = outside_y > top ? top : bottom;
            real t = (target - y0) / (y1 - y0);
            return (x0 + t * (x1 - x0), target);
        }

        // Draw a non-arrow endpoint marker at a resolved (already-mapped) point. ARROW and "no
        // marker" are handled by the caller via draw()'s arrow= parameter instead — this only
        // covers the dot/interval styles, which need their own drawing calls.
        void draw_endpoint_marker(string marker, pair p, pen fill_color, bool is_left) {
            if (marker == OPEN_DOT) {
                filldraw(pic, circle(p, plot_endpoint_dot_radius), figure_background_color,
                         fill_color + function_thickness);
            } else if (marker == CLOSED_DOT) {
                filldraw(pic, circle(p, plot_endpoint_dot_radius), fill_color,
                         fill_color + function_thickness);
            } else if (marker == OPEN_INTERVAL || marker == CLOSED_INTERVAL) {
                string glyph = is_left ?
                    (marker == OPEN_INTERVAL ? "(" : "[") :
                    (marker == OPEN_INTERVAL ? ")" : "]");
                label(pic, glyph, p, align=(is_left ? E : W), p=fill_color + text_normal);
            }
        }

        // Draw each function's curve as a straight-segment polyline through its sampled points —
        // preferred over Asymptote's spline (..) operator, which can overshoot near discontinuities
        // (e.g. abs, piecewise functions). At sample_count=200 straight segments already look smooth.
        // x is already sampled only within the window (see sample_min/sample_max above), but y is
        // not — a function can still leave the window vertically within that x-range (e.g. a domain
        // wider than the auto-computed or explicitly set y-window).
        //
        // Rather than drawing the full curve and clipping it afterward, each function is split into
        // one path per contiguous run of in-window, defined points, cut exactly at the interpolated
        // point where it crosses the top/bottom boundary (or, for a NaN-adjacent cut, at the last
        // valid sample — see boundary_crossing()'s caller below). Segments are buffered rather than
        // drawn immediately, so the function's overall first and last segments can be identified
        // afterward: only their outer ends are eligible for the caller's left_marker/right_marker
        // override; every interior cut always uses the ordinary AUTO default (no marker at all —
        // whatever cut it, a window/domain edge or a NaN gap, the curve just stops cleanly there),
        // regardless of what the caller asked for at the function's true ends.
        if (has_range) {
            // Resolve colors: explicitly colored functions keep exactly the pen given; every
            // other function shares the rainbow palette, divided only among themselves — an
            // explicitly colored function doesn't consume a slot that would otherwise spread the
            // auto-colored ones further apart.
            int auto_count = 0;
            for (int f = 0; f < this._functions.length; ++f) {
                if (!this._has_explicit_color[f]) ++auto_count;
            }
            pen[] auto_colors = plot_function_colors(auto_count);
            pen[] colors = new pen[this._functions.length];
            int auto_idx = 0;
            for (int f = 0; f < this._functions.length; ++f) {
                if (this._has_explicit_color[f]) {
                    colors[f] = this._explicit_colors[f];
                } else {
                    colors[f] = auto_colors[auto_idx];
                    ++auto_idx;
                }
            }

            for (int f = 0; f < this._functions.length; ++f) {
                pen curve_pen = colors[f] + function_thickness + this._types[f];

                path[] seg_paths = new path[];

                path segment;
                bool has_segment = false;

                for (int i = 0; i < sample_count; ++i) {
                    real yi = sample_ys[f][i];
                    bool yi_finite = is_finite(yi);
                    bool yi_inside = yi_finite && yi >= bottom && yi <= top;

                    if (i == 0) {
                        if (yi_inside) {
                            segment = (mapx(sample_xs[0]), mapy(yi));
                            has_segment = true;
                        }
                        continue;
                    }

                    real xprev = sample_xs[i - 1];
                    real yprev = sample_ys[f][i - 1];
                    bool yprev_finite = is_finite(yprev);
                    bool yprev_inside = yprev_finite && yprev >= bottom && yprev <= top;
                    real xi = sample_xs[i];

                    if (yprev_inside && yi_inside) {
                        segment = segment -- (mapx(xi), mapy(yi));
                    } else if (yprev_inside && !yi_inside) {
                        if (yi_finite) {
                            pair cross = boundary_crossing(xprev, yprev, xi, yi, true);
                            segment = segment -- (mapx(cross.x), mapy(cross.y));
                        }
                        seg_paths.push(segment);
                        has_segment = false;
                    } else if (!yprev_inside && yi_inside) {
                        if (yprev_finite) {
                            pair cross = boundary_crossing(xprev, yprev, xi, yi, false);
                            segment = (mapx(cross.x), mapy(cross.y)) -- (mapx(xi), mapy(yi));
                        } else {
                            segment = (mapx(xi), mapy(yi));
                        }
                        has_segment = true;
                    }
                    // Otherwise still outside the window or undefined: nothing to draw yet.
                }

                if (has_segment) {
                    seg_paths.push(segment);
                }

                string left_marker = this._left_markers[f];
                string right_marker = this._right_markers[f];

                for (int s = 0; s < seg_paths.length; ++s) {
                    bool is_first = (s == 0);
                    bool is_last = (s == seg_paths.length - 1);

                    // Intermediate cuts (not the function's true first/last segment) always draw
                    // with no marker, regardless of why the cut happened. The true outermost ends
                    // default to ARROW (AUTO), overridden by an explicit left_marker/right_marker.
                    string start_marker = "";
                    if (is_first) start_marker = (left_marker == AUTO) ? ARROW : left_marker;

                    string end_marker = "";
                    if (is_last) end_marker = (right_marker == AUTO) ? ARROW : right_marker;

                    arrowbar seg_arrow = None;
                    if (start_marker == ARROW && end_marker == ARROW) seg_arrow = function_arrow;
                    else if (start_marker == ARROW) seg_arrow = function_begin_arrow;
                    else if (end_marker == ARROW) seg_arrow = function_end_arrow;

                    draw(pic, seg_paths[s], p=curve_pen, arrow=seg_arrow);

                    if (start_marker != "" && start_marker != ARROW && start_marker != NONE) {
                        draw_endpoint_marker(start_marker, point(seg_paths[s], 0), colors[f], true);
                    }
                    if (end_marker != "" && end_marker != ARROW && end_marker != NONE) {
                        draw_endpoint_marker(end_marker, point(seg_paths[s], length(seg_paths[s])),
                                              colors[f], false);
                    }
                }
            }
        }

        // Debug: draw window border
        if (this._debug_mode) {
            draw(pic, box((0,0),(width, height)), p=gray + linewidth(0.5));
        }

        return pic;
    }
};

// "Plot" alias: most callers should write Plot(...) rather than ContinuousPlot(...). typedef makes
// the two type names fully interchangeable (variables, parameters, assignments); this wrapper
// function is what makes Plot(...) work as a constructor call.
typedef ContinuousPlot Plot;
Plot Plot(real x_min = -5, real x_max = 5) {
    return ContinuousPlot(x_min, x_max);
}
