////////////////////////////////////////////////////////////////////////////////////////////////////
// File: ContinuousPlot.asy
//
// Description:
// Continuous function plot — the standard smooth graph of one or more functions over a shared
// viewport, as opposed to DiscretePlot's discrete bar/step sampling. add() takes a function
// directly — an explicit real_function_1 (real(real)), sampled along x and connected point-to-point,
// or an implicit_2 (real(real, real)), the curve f(x, y) = 0 traced via Asymptote's contour module —
// and tells which kind it is from the function's own type, so both can live in the same Plot, drawn
// in the order they were added. By default a function's domain (or, for implicit, search box) is the
// plot's own resolved window, since that already defines where the plot is looking; add()'s optional
// x_min/x_max (and, for implicit, y_min/y_max) override that per function, for the rare case a
// function needs a domain narrower or wider than the window (e.g. sqrt starting at x=0). Every
// function left on auto-color is resolved at render() time via the theme's plot_function_colors(),
// since the rainbow policy depends on how many functions need an auto color, not just each
// function's position — explicitly colored functions are excluded from that count entirely, so the
// auto-colored ones still spread across the full gradient among themselves. The graph itself (axes,
// grid, curves) is drawn inside a square inset from render()'s given width/height by a margin on
// each side (1 by default; see set_margin_left/right/top/bottom), which is where tick labels live —
// so nothing a Plot draws can ever land outside the area it was given to render into.
// "Plot" is a type alias for this struct (see the bottom of this file) — most callers should just
// use Plot; ContinuousPlot is the canonical name.
////////////////////////////////////////////////////////////////////////////////////////////////////

// Endpoint marker styles for the true left/right ends of an explicit function's plotted curve
// (add()'s left_marker/right_marker). Explicit only — not even a parameter on the implicit add()
// overload, since an implicit function's contour curve can be a closed loop or clipped by its own
// search box in more than one place, with no well-defined "leftmost/rightmost visible point." AUTO's
// default is ARROW at the function's true outermost visible point — whatever cut it short there, a
// domain/display edge or a window boundary. Any cut that isn't the function's true leftmost/rightmost
// point (an interior window-boundary crossing, or resuming after a NaN gap partway through) always
// draws with no marker regardless of left_marker/right_marker, since only the outermost ends are
// eligible for a marker at all. Override left_marker/right_marker when ARROW isn't right for a
// specific function — e.g. sqrt(x) is actually defined and finite at x=0, so CLOSED_DOT reads better
// there than an arrow implying the curve keeps going. NONE suppresses the marker at that end
// entirely, including AUTO's arrow.
string ARROW = "arrow";
string OPEN_DOT = "open_dot";
string CLOSED_DOT = "closed_dot";
string OPEN_INTERVAL = "open_interval";
string CLOSED_INTERVAL = "closed_interval";
string NONE = "none";
string AUTO = "auto";

// Line type constants for add()'s type parameter — plain aliases for Asymptote's own built-in
// dash-pattern pens (plain_pens.asy), so any Asymptote linetype pen works here too, not just these
// six. SOLID is the default. Applies to both explicit and implicit functions.
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

// Sentinel for add()'s optional x_min/x_max/y_min/y_max, meaning "not given — Plot substitutes its
// own resolved window edge at render() time instead." A quiet NaN (log of a negative number, rather
// than a literal 0.0/0.0, which aborts with "Divide by zero" instead of producing NaN), detected via
// self-inequality — the standard NaN test, since NaN is the only real value unequal to itself, and no
// caller would ever legitimately pass NaN as a domain bound.
real UNSET_DOMAIN = log(-1);

struct ContinuousPlot {
    // One added function together with everything needed to render it: which kind it is (explicit or
    // implicit — exactly one of explicit_fn/implicit_fn is populated, selected by which add()
    // overload built this entry), its domain/search box (if given; otherwise deferred to the plot's
    // resolved window), and its color/line style/markers/sampling. Built entirely by add(); not
    // constructed directly by callers.
    //
    // Field applicability by kind (arity):
    //    explicit_fn                     - Set only when arity == 1.
    //    implicit_fn                     - Set only when arity == 2.
    //    color, has_explicit_color, type - Used by both kinds.
    //    label                           - Used by both kinds. Shown in legend()'s right column; if
    //                                      never given, legend() falls back to "Function N".
    //    left_marker, right_marker       - Explicit only. Ignored for an implicit entry, which has
    //                                      no well-defined curve "ends."
    //    samples                        - Explicit only. Number of points sampled across the domain;
    //                                      higher values draw a smoother curve at the cost of render
    //                                      time.
    //    grid_nx, grid_ny                - Implicit only. contour()'s search grid resolution; higher
    //                                      values resolve thin or complex loops more accurately, at
    //                                      the cost of render time.
    //    x_min, x_max                    - Used by both kinds when set: the explicit function's
    //                                      evaluation domain, or the implicit function's search box
    //                                      x-range.
    //    y_min, y_max                    - Implicit only. Ignored for an explicit entry.
    //    x_min_set, x_max_set,
    //    y_min_set, y_max_set            - Whether the corresponding bound was actually given. False
    //                                      means the plot's resolved window edge is used instead.
    struct PlotEntry {
        int arity;
        real_function_1 explicit_fn;
        implicit_2 implicit_fn;
        pen color;
        bool has_explicit_color;
        pen type;
        string label;
        string left_marker;
        string right_marker;
        int samples;
        int grid_nx;
        int grid_ny;
        real x_min, x_max, y_min, y_max;
        bool x_min_set, x_max_set;
        bool y_min_set, y_max_set;
    }

    // Private/internal fields (users should access via getters/setters)
    PlotEntry[] _entries;

    // x-domain: default window left/right when neither is explicitly overridden. Independent of any
    // individual function's own domain (see add() below) — this only affects the viewport.
    real _x_min;
    real _x_max;

    // Window: the viewport. Left/right default to the domain when unset; bottom/top are always
    // auto-computed from sampled y-values (of explicit functions only) unless explicitly overridden.
    // These fields hold the most recently resolved values (refreshed on every render()), which is
    // what the getters return.
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

    // Margins around the plotted square, reserved for tick labels. The actual graph (axes, grid,
    // curves) is drawn inside a square — the largest one that fits after these margins are
    // subtracted from the given width/height — so nothing the plot draws can ever land outside the
    // box it was given to render into. Default 1 (in the render unit) on all four sides.
    real _margin_left;
    real _margin_right;
    real _margin_top;
    real _margin_bottom;

    void operator init(real x_min = -5, real x_max = 5) {
        this._x_min = x_min;
        this._x_max = x_max;

        this._entries = new PlotEntry[];

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

        this._margin_left = 1;
        this._margin_right = 1;
        this._margin_top = 1;
        this._margin_bottom = 1;
    }

    // Add an explicit function (y = f(x)) to the plot.
    //
    // color: any ordinary Asymptote pen (a named color, RGB(...), rgb(...), etc.) to
    // color-coordinate this function instead of letting the rainbow palette assign one. Left at
    // its default (the AUTO_COLOR sentinel — just omit this argument), the function's color is
    // resolved at render() time via the theme's plot_function_colors(), against however many
    // functions are left on auto-color at that point; explicitly colored functions don't count
    // against that share, so the auto-colored ones still spread across the full gradient among
    // themselves.
    //
    // type: one of SOLID/DOTTED/DASHED/LONG_DASHED/DASH_DOTTED/LONG_DASH_DOTTED above (or any other
    // Asymptote linetype pen). Applies only to the curve itself, not its endpoint markers, which are
    // always drawn with a solid outline regardless.
    //
    // left_marker/right_marker set what's drawn at this function's true left/right ends (see the
    // ARROW/OPEN_DOT/CLOSED_DOT/OPEN_INTERVAL/CLOSED_INTERVAL/NONE constants above); AUTO's default
    // is ARROW.
    //
    // samples controls how smooth the curve looks (points sampled across the domain).
    //
    // label is shown in legend()'s right column, next to this function's line-style sample. Left at
    // its default (empty), legend() falls back to "Function N" using this function's add() order.
    //
    // x_min/x_max: this function's own evaluation domain. Left unset (the default), the plot's own
    // resolved window left/right is used instead — which is what most callers want, since the window
    // already defines where the plot is looking. Override when this function needs a domain narrower
    // or wider than the window, e.g. sqrt starting at x=0 even though the window extends further
    // negative.
    void add(real_function_1 func, pen color = AUTO_COLOR, pen type = SOLID, string label = "",
             string left_marker = AUTO, string right_marker = AUTO, int samples = 200,
             real x_min = UNSET_DOMAIN, real x_max = UNSET_DOMAIN) {
        PlotEntry entry;
        entry.arity = 1;
        entry.explicit_fn = func;
        entry.color = color;
        entry.has_explicit_color = (color != AUTO_COLOR);
        entry.type = type;
        entry.label = label;
        entry.left_marker = left_marker;
        entry.right_marker = right_marker;
        entry.samples = samples;
        entry.x_min = x_min;
        entry.x_max = x_max;
        entry.x_min_set = (x_min == x_min);
        entry.x_max_set = (x_max == x_max);
        this._entries.push(entry);
    }

    // Add an implicit function (the curve f(x, y) = 0) to the plot.
    //
    // color/type: see the explicit add() overload above — same meaning, applies to the traced curve.
    //
    // nx/ny control contour()'s search grid resolution — higher values resolve thin or complex loops
    // more accurately, at the cost of render time.
    //
    // label: see the explicit add() overload above — same meaning, shown in legend()'s right column.
    //
    // x_min/x_max/y_min/y_max: the box to search for this function's curve. Left unset (the
    // default), the plot's own resolved window is used instead — see the explicit overload's
    // x_min/x_max for the same reasoning. Override when this curve needs a search box narrower or
    // wider than the window.
    void add(implicit_2 func, pen color = AUTO_COLOR, pen type = SOLID, string label = "",
              int nx = 100, int ny = nx,
              real x_min = UNSET_DOMAIN, real x_max = UNSET_DOMAIN,
              real y_min = UNSET_DOMAIN, real y_max = UNSET_DOMAIN) {
        PlotEntry entry;
        entry.arity = 2;
        entry.implicit_fn = func;
        entry.color = color;
        entry.has_explicit_color = (color != AUTO_COLOR);
        entry.type = type;
        entry.label = label;
        entry.grid_nx = nx;
        entry.grid_ny = ny;
        entry.x_min = x_min;
        entry.x_max = x_max;
        entry.y_min = y_min;
        entry.y_max = y_max;
        entry.x_min_set = (x_min == x_min);
        entry.x_max_set = (x_max == x_max);
        entry.y_min_set = (y_min == y_min);
        entry.y_max_set = (y_max == y_max);
        this._entries.push(entry);
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
    real get_margin_left() { return this._margin_left; }
    real get_margin_right() { return this._margin_right; }
    real get_margin_top() { return this._margin_top; }
    real get_margin_bottom() { return this._margin_bottom; }

    // Setters
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

    // Margin setters. Each is independent; set only the ones that need to differ from the 1cm
    // default (e.g. widen the left margin for functions whose y-values render as wide labels).
    void set_margin_left(real margin) { this._margin_left = margin; }
    void set_margin_right(real margin) { this._margin_right = margin; }
    void set_margin_top(real margin) { this._margin_top = margin; }
    void set_margin_bottom(real margin) { this._margin_bottom = margin; }

    // Convenience: set all four margins to the same value at once.
    void set_margins(real margin) {
        this._margin_left = margin;
        this._margin_right = margin;
        this._margin_top = margin;
        this._margin_bottom = margin;
    }

    // Convenience: set all four margins independently in one call.
    void set_margins(real left, real right, real top, real bottom) {
        this._margin_left = left;
        this._margin_right = right;
        this._margin_top = top;
        this._margin_bottom = bottom;
    }

    // Resolve each entry's display color: explicitly colored entries keep exactly the pen given;
    // every other entry — explicit or implicit alike — shares the rainbow palette, divided only
    // among themselves, so an explicitly colored entry doesn't consume a slot that would otherwise
    // spread the auto-colored ones further apart. Shared by render() and legend() so the legend
    // always shows exactly the colors the plot itself draws.
    pen[] resolve_colors() {
        int n = this._entries.length;
        int auto_count = 0;
        for (int f = 0; f < n; ++f) {
            if (!this._entries[f].has_explicit_color) ++auto_count;
        }
        pen[] auto_colors = plot_function_colors(auto_count);
        pen[] colors = new pen[n];
        int auto_idx = 0;
        for (int f = 0; f < n; ++f) {
            if (this._entries[f].has_explicit_color) {
                colors[f] = this._entries[f].color;
            } else {
                colors[f] = auto_colors[auto_idx];
                ++auto_idx;
            }
        }
        return colors;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Function: render
    //
    // Description:
    // Resolve the window from the domain and any explicit overrides, sample every added explicit
    // function (implicit functions aren't sampled — they're traced later via contour()), and draw
    // the curves and axes into a picture. Resolution happens here rather than at add() time because
    // the auto-computed bottom/top depend on every explicit function that has been added so far, and
    // functions can still be added after any earlier render(); resolved bounds are cached into
    // this._window_* on each call so the getters reflect the last-rendered state.
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
        // once every explicit function has been sampled.
        real left = this._window_left_set ? this._window_left : this._x_min;
        real right = this._window_right_set ? this._window_right : this._x_max;

        // Sample every explicit entry (arity == 1) over the overlap of its own domain and the
        // window — each entry can have its own domain and its own sample count, so both the sampled
        // points and whether there's any overlap at all are tracked per entry rather than once for
        // the whole plot. Implicit entries (arity == 2) contribute nothing here; they're searched
        // later via contour() against their own box, independent of this sampling pass.
        int n = this._entries.length;
        real[][] entry_xs = new real[n][];
        real[][] entry_ys = new real[n][];
        bool[] entry_has_range = new bool[n];

        real hmin = 1e9;
        real hmax = -1e9;

        for (int f = 0; f < n; ++f) {
            PlotEntry entry = this._entries[f];
            if (entry.arity != 1) continue;

            // An unset domain bound defers to the window's own edge — most functions have no
            // domain narrower than what the plot is actually showing, so this is what add()'s
            // default (no x_min/x_max given) relies on.
            real func_x_min = entry.x_min_set ? entry.x_min : left;
            real func_x_max = entry.x_max_set ? entry.x_max : right;
            real sample_min = max(func_x_min, left);
            real sample_max = min(func_x_max, right);
            entry_has_range[f] = sample_max > sample_min;
            if (!entry_has_range[f]) continue;

            int sample_count = entry.samples;
            real[] xs = new real[sample_count];
            real[] ys = new real[sample_count];
            for (int i = 0; i < sample_count; ++i) {
                real x = sample_min + i * (sample_max - sample_min) / (sample_count - 1);
                real y = entry.explicit_fn(x);
                xs[i] = x;
                ys[i] = y;
                if (y < hmin) hmin = y;
                if (y > hmax) hmax = y;
            }
            entry_xs[f] = xs;
            entry_ys[f] = ys;
        }

        // Resolve bottom/top: auto-compute from sampled y-values with padding, unless overridden.
        // Guard the case where nothing was sampled (no explicit functions in range, or none added
        // at all) with a hardcoded fallback rather than letting an inverted hmin/hmax range through.
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

        // Reserve the margins first, then take the largest square that fits in what's left — the
        // actual graph (axes, grid, curves) only ever draws inside that square, so tick labels
        // drawn outward from it land in the margin, never outside the box this render() was given.
        // Any slack left over (if the given box wasn't itself exactly square-after-margins) is
        // split evenly, centering the square+margins block within the box.
        real avail_w = width - this._margin_left - this._margin_right;
        real avail_h = height - this._margin_top - this._margin_bottom;
        real square_side = min(avail_w, avail_h);
        real extra_w = avail_w - square_side;
        real extra_h = avail_h - square_side;
        real square_x0 = this._margin_left + extra_w / 2;
        real square_y0 = this._margin_bottom + extra_h / 2;

        // Within the square, fit the numeric window preserving its aspect ratio — same reasoning
        // as before (a slope-1 line should render at an actual 45-degree angle), just measured
        // against the square's side instead of the raw given width/height.
        real x_range = right - left;
        real y_range = top - bottom;
        real data_scale = 1;
        real data_render_w = square_side;
        real data_render_h = square_side;
        if (x_range > 0 && y_range > 0) {
            data_scale = min(square_side / x_range, square_side / y_range);
            data_render_w = x_range * data_scale;
            data_render_h = y_range * data_scale;
        }
        real data_offset_x = square_x0 + (square_side - data_render_w) / 2;
        real data_offset_y = square_y0 + (square_side - data_render_h) / 2;

        real mapx(real x) {
            if (right == left) return data_offset_x;
            return data_offset_x + (x - left) * data_scale;
        }
        real mapy(real y) {
            if (top == bottom) return data_offset_y;
            return data_offset_y + (y - bottom) * data_scale;
        }

        // Whether each axis's true data value (0) actually falls inside the window — this decides
        // both whether that axis gets drawn at all (only when visible, arrow-tipped, at its true
        // interior position) and whether grid lines measure their spacing from 0 or from the
        // window's edge.
        bool x0_in = (left <= 0 && right >= 0);
        bool y0_in = (bottom <= 0 && top >= 0);
        real axis_x_data = x0_in ? 0 : left;
        real axis_y_data = y0_in ? 0 : bottom;

        // Draw the grid (if enabled) before the axes and curves, so both render on top of it.
        // Lines extend across the full window, spaced out from the axis position (0 if visible,
        // otherwise the window's edge) by delta_x/delta_y — the axis's own position (k=0) is
        // skipped, since the axis line itself (when visible) is drawn separately, on top. Bounded
        // by mapx/mapy's own window range, so grid lines never reach outside the square.
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

        // Tick marks and their number labels always live at the square's own four edges —
        // independent of where the data axis itself is drawn — so they're never crowded out by, or
        // dependent on, whatever's happening in the interior. Ticks point outward, away from the
        // square, into the margin reserved for them; labels sit just beyond the tick. Every tick
        // value gets a label here, including 0 — there's no collision to avoid, since left-edge and
        // bottom-edge labels never share a position. Drawn after the grid (so ticks sit on top of
        // it) but before the axes/functions.
        real[] yTicks = compute_ticks(bottom, top, 5);
        real[] xTicks = compute_ticks(left, right, 6);

        for (real t : yTicks) {
            real ym = mapy(t);
            draw(pic, (square_x0, ym)--(square_x0 - plot_tick_length, ym), p=axis_color + axis_thickness);
            label(pic, string(t), (square_x0 - plot_tick_length - plot_tick_label_gap, ym),
                  align=W, p=text_small);
        }
        for (real t : xTicks) {
            real xm = mapx(t);
            draw(pic, (xm, square_y0)--(xm, square_y0 - plot_tick_length), p=axis_color + axis_thickness);
            label(pic, string(t), (xm, square_y0 - plot_tick_length - plot_tick_label_gap),
                  align=S, p=text_small);
        }

        // Draw each data axis only when it's actually visible (its value, 0, falls inside the
        // window) — arrow-tipped, at its true interior position, extending across the full square.
        // An axis that doesn't cross the window gets no line at all; the tick marks and labels
        // above already cover it fully from the edge. A visible axis additionally gets small
        // crossing-ticks (no labels — the edge already has those) at the same tick values, so it
        // reads the same way a normal graph's interior axis does.
        if (x0_in) {
            real ax_m = mapx(0);
            draw(pic, (ax_m, mapy(bottom))--(ax_m, mapy(top)), p=axis_color + axis_thickness, arrow=axis_arrow);
            for (real t : yTicks) {
                real ym = mapy(t);
                draw(pic, (ax_m - plot_tick_length / 2, ym)--(ax_m + plot_tick_length / 2, ym),
                     p=axis_color + axis_thickness);
            }
        }
        if (y0_in) {
            real ay_m = mapy(0);
            draw(pic, (mapx(left), ay_m)--(mapx(right), ay_m), p=axis_color + axis_thickness, arrow=axis_arrow);
            for (real t : xTicks) {
                real xm = mapx(t);
                draw(pic, (xm, ay_m - plot_tick_length / 2)--(xm, ay_m + plot_tick_length / 2),
                     p=axis_color + axis_thickness);
            }
        }

        // When both axes are visible, also label their actual intersection with a single "0" —
        // in addition to (not instead of) the ordinary 0 labels already on both edges above —
        // offset diagonally into whichever quadrant encloses the least area, so it stays out of
        // the way of curves while still marking the true origin.
        if (x0_in && y0_in) {
            real ax_m = mapx(0);
            real ay_m = mapy(0);
            real area_top_right    = (right - 0) * (top - 0);
            real area_top_left     = (0 - left) * (top - 0);
            real area_bottom_right = (right - 0) * (0 - bottom);
            real area_bottom_left  = (0 - left) * (0 - bottom);
            real min_area = min(area_top_right, min(area_top_left, min(area_bottom_right, area_bottom_left)));

            real zero_offset = plot_tick_length + plot_tick_label_gap;
            pair zero_pos;
            if (min_area == area_bottom_left) zero_pos = (ax_m - zero_offset, ay_m - zero_offset);
            else if (min_area == area_bottom_right) zero_pos = (ax_m + zero_offset, ay_m - zero_offset);
            else if (min_area == area_top_left) zero_pos = (ax_m - zero_offset, ay_m + zero_offset);
            else zero_pos = (ax_m + zero_offset, ay_m + zero_offset);

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

        // Trim a curve's drawn path back by plot_arrow_trim from whichever end is getting an ARROW
        // marker, so the arrowhead sits fully inside the window rather than its tip landing exactly
        // on (or poking through) the border — works uniformly regardless of which edge caused the
        // cut (window boundary, domain edge, or a NaN gap), since it just shortens the already-built
        // path by a fixed physical distance rather than recomputing where the cut happened. Left
        // unchanged if the segment is too short to trim without collapsing it to nothing.
        path trim_start(path p, real d) {
            real len = arclength(p);
            if (d <= 0 || d >= len) return p;
            return subpath(p, arctime(p, d), length(p));
        }
        path trim_end(path p, real d) {
            real len = arclength(p);
            if (d <= 0 || d >= len) return p;
            return subpath(p, 0, arctime(p, len - d));
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

        // Resolve colors the same way legend() does, so the two always agree.
        pen[] colors = this.resolve_colors();

        // Draw each entry's curve, in add() order (so later entries sit on top of earlier ones,
        // same as the axes sitting beneath every function).
        for (int f = 0; f < n; ++f) {
            PlotEntry entry = this._entries[f];
            pen curve_pen = colors[f] + function_thickness + entry.type;

            if (entry.arity == 1) {
                // Draw the curve as a straight-segment polyline through its sampled points —
                // preferred over Asymptote's spline (..) operator, which can overshoot near
                // discontinuities (e.g. abs, piecewise functions). At sample_count=200 (the
                // default) straight segments already look smooth. x is already sampled only within
                // the window (see entry_xs above), but y is not — a function can still leave the
                // window vertically within that x-range (e.g. a domain wider than the auto-computed
                // or explicitly set y-window).
                //
                // Rather than drawing the full curve and clipping it afterward, the function is
                // split into one path per contiguous run of in-window, defined points, cut exactly
                // at the interpolated point where it crosses the top/bottom boundary (or, for a
                // NaN-adjacent cut, at the last valid sample — see boundary_crossing()'s caller
                // below). Segments are buffered rather than drawn immediately, so the function's
                // overall first and last segments can be identified afterward: only their outer
                // ends are eligible for the caller's left_marker/right_marker override; every
                // interior cut always uses the ordinary AUTO default (no marker at all — whatever
                // cut it, a window/domain edge or a NaN gap, the curve just stops cleanly there),
                // regardless of what the caller asked for at the function's true ends.
                if (!entry_has_range[f]) continue;

                real[] xs = entry_xs[f];
                real[] ys = entry_ys[f];
                int sample_count = entry.samples;

                path[] seg_paths = new path[];
                path segment;
                bool has_segment = false;

                for (int i = 0; i < sample_count; ++i) {
                    real yi = ys[i];
                    bool yi_finite = is_finite(yi);
                    bool yi_inside = yi_finite && yi >= bottom && yi <= top;

                    if (i == 0) {
                        if (yi_inside) {
                            segment = (mapx(xs[0]), mapy(yi));
                            has_segment = true;
                        }
                        continue;
                    }

                    real xprev = xs[i - 1];
                    real yprev = ys[i - 1];
                    bool yprev_finite = is_finite(yprev);
                    bool yprev_inside = yprev_finite && yprev >= bottom && yprev <= top;
                    real xi = xs[i];

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

                string left_marker = entry.left_marker;
                string right_marker = entry.right_marker;

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

                    // Trim only for the actual line draw — dot/interval markers below still anchor
                    // to seg_paths[s]'s true (untrimmed) endpoints, since only ARROW ends need the
                    // visual gap from the border.
                    path draw_path = seg_paths[s];
                    if (start_marker == ARROW) draw_path = trim_start(draw_path, plot_arrow_trim);
                    if (end_marker == ARROW) draw_path = trim_end(draw_path, plot_arrow_trim);

                    draw(pic, draw_path, p=curve_pen, arrow=seg_arrow);

                    if (start_marker != "" && start_marker != ARROW && start_marker != NONE) {
                        draw_endpoint_marker(start_marker, point(seg_paths[s], 0), colors[f], true);
                    }
                    if (end_marker != "" && end_marker != ARROW && end_marker != NONE) {
                        draw_endpoint_marker(end_marker, point(seg_paths[s], length(seg_paths[s])),
                                              colors[f], false);
                    }
                }
            } else {
                // Implicit: search this entry's own box for the f(x, y) = 0 curve via contour(),
                // using a throwaway picture so the returned guides come back in raw (x, y) data
                // coordinates — contour() draws through the picture's scale.x/y.T, which defaults to
                // identity on a fresh picture — then remap each node through this render's own
                // mapx/mapy before drawing, the same manual mapping every other element in this
                // render uses (verified: a fresh picture's contour() output matches raw data
                // coordinates directly, e.g. a circle of radius 2 comes back with node radii of
                // ~2.0, not scaled or offset). No markers or arrows — a contour curve can be a
                // closed loop or clipped by its own box with no well-defined "ends" the way a
                // sampled explicit curve has.
                real contour_adapter(real x, real y) {
                    return entry.implicit_fn(x, y);
                }

                // An unset box bound defers to the window's own edge, same reasoning as the
                // explicit domain fallback above — most implicit functions just want to be searched
                // for wherever the plot is already looking.
                real box_x_min = entry.x_min_set ? entry.x_min : left;
                real box_x_max = entry.x_max_set ? entry.x_max : right;
                real box_y_min = entry.y_min_set ? entry.y_min : bottom;
                real box_y_max = entry.y_max_set ? entry.y_max : top;

                picture raw_pic = new picture;
                guide[][] level_guides = contour(raw_pic, contour_adapter,
                                                  (box_x_min, box_y_min),
                                                  (box_x_max, box_y_max),
                                                  new real[] {0}, entry.grid_nx, entry.grid_ny);

                picture curve_pic = new picture;
                for (guide g : level_guides[0]) {
                    int node_count = size(g);
                    if (node_count == 0) continue;
                    guide mapped;
                    for (int k = 0; k < node_count; ++k) {
                        pair p = point(g, k);
                        pair mp = (mapx(p.x), mapy(p.y));
                        mapped = (k == 0) ? mp : mapped -- mp;
                    }
                    if (cyclic(g)) mapped = mapped -- cycle;
                    draw(curve_pic, mapped, p=curve_pen);
                }
                // Clip only this entry's curve (drawn onto a throwaway picture) to the visible
                // window, rather than clipping pic itself, which would also cut off everything else
                // already drawn (axes, grid, earlier functions).
                clip(curve_pic, box((mapx(left), mapy(bottom)), (mapx(right), mapy(top))));
                add(pic, curve_pic);
            }
        }

        // Border along the viewing window's own square — same color/thickness as a data axis, but
        // never arrow-tipped. Arrows are reserved for a data axis that's actually visible inside the
        // window (drawn earlier above); this border just frames where the window itself sits,
        // matching the same edges the tick marks are anchored to. Drawn last (after every function),
        // so a curve that runs right up to the window edge sits underneath the border, not on top
        // of it.
        draw(pic, box((square_x0, square_y0), (square_x0 + square_side, square_y0 + square_side)),
             p=axis_color + axis_thickness);

        // Debug: draw window border
        if (this._debug_mode) {
            draw(pic, box((0,0),(width, height)), p=gray + linewidth(0.5));
        }

        return pic;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Function: legend
    //
    // Description:
    // Build a standalone legend: one row per added function, in add() order, a short line-style
    // sample in its resolved color followed by its label, with a small gap between them — not two
    // separately aligned columns, just one left-aligned unit per row. Rows are stacked from the top
    // down: the first added function's row is the topmost, with each subsequent row extending
    // downward. Colors are resolved via resolve_colors(), the same method render() uses, so the
    // legend always matches whatever the plot itself actually draws.
    //
    // height is optional and only matters when placing the result in a Gallery cell (or any other
    // fixed-height frame) alongside the plot: Gallery always anchors an added picture's bottom-left
    // corner to its cell's bottom-left corner, so a legend that's only as tall as its own content
    // (the default, height=0) ends up hugging the bottom of a much taller cell instead of lining up
    // with the plot. Passing the same height given to that Gallery (or Image) positions the first
    // row at the same margin-inset height the plot's own square top sits at, so the two align.
    //
    // Inputs:
    //    height - Target frame height to align against (0, the default, sizes to content only).
    //
    // Outputs:
    //    pic - The rendered legend picture.
    ////////////////////////////////////////////////////////////////////////////////////////////////
    picture legend(real height = 0) {
        picture pic = new picture;
        unitsize(pic, diagram_unit);

        pen[] colors = this.resolve_colors();
        int n = this._entries.length;

        // Row 0 (the first added function) goes at the top, i.e. the highest y — this picture's
        // y=0 is its bottom edge, matching every other visualization in this library (content spans
        // (0,0) to (width,height), not the other way around), so placing row 0 at y=0 would instead
        // anchor it at the bottom, with every later row trailing off even further below that. When a
        // target height is given, the top row instead lines up with where the plot's own square top
        // sits within that same height (height minus this plot's own top margin).
        real top_y = (height > 0) ? (height - this._margin_top) : max(0, n - 1) * legend_row_height;

        for (int i = 0; i < n; ++i) {
            PlotEntry entry = this._entries[i];
            real y = top_y - i * legend_row_height;

            pen curve_pen = colors[i] + function_thickness + entry.type;
            draw(pic, (0, y)--(legend_line_length, y), p=curve_pen);

            string label_text = (entry.label != "") ? entry.label : ("Function " + string(i + 1));
            label(pic, label_text, (legend_line_length + legend_label_gap, y), align=E, p=text_normal);
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
