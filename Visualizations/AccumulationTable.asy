///////////////////////////////////////////////////////////////////////////////////////////////////
// AccumulationTable - Simple table visualization for iterative accumulation
//
// Usage:
//   // Define an accumulation function: a_next = f(a_current)
//   real accum_func(real x) { return x * 1.05; }
//   AccumulationTable t = AccumulationTable(1000, 8, accum_func);
//   picture p = t.render(12, 8, 1cm);
//   add(currentpicture, p);
//
// The table shows three columns: Step | Accumulated | Change
///////////////////////////////////////////////////////////////////////////////////////////////////

// Basic helper: format a real to `dp` decimal places (simple rounding)
string _fmt(real v, int dp) {
    // Use exp(dp*log(10)) instead of pow to avoid missing pow binding
    real mult = exp(dp * log(10));
    real r = round(v * mult) / mult;
    return string(r);
}

struct AccumulationTable {
    real _seed;
    int _steps; // number of iterations (rows will be 0.._steps inclusive)
    real_function_1 _func;

    real[] _accum; // length _steps+1
    real[] _delta; // length _steps+1 (delta[0] == 0)

    string _title; // top header
    string[] _subheaders; // four subheaders

    // Styling flags
    bool _debug_mode;

    void operator init(real seed = 0, int steps = 10, real_function_1 func = identity,
                       string title = "Accumulation Table") {
        this._seed = seed;
        this._steps = steps;
        this._func = func;
        this._title = title;
        this._subheaders = new string[4];
        this._subheaders[0] = "Step";
        this._subheaders[1] = "Current Total";
        this._subheaders[2] = "Change";
        this._subheaders[3] = "Next Total";
        this._debug_mode = false;

        // Allocate arrays (steps + 1, including iteration 0)
        int rows = this._steps + 1;
        this._accum = new real[rows];
        this._delta = new real[rows];

        // Compute sequence
        this._accum[0] = this._seed;
        this._delta[0] = 0;
        for (int k = 1; k < rows; ++k) {
            this._accum[k] = this._func(this._accum[k - 1]);
            this._delta[k] = this._accum[k] - this._accum[k - 1];
        }
    }

    void set_debug_mode(bool enabled) { this._debug_mode = enabled; }

    // Subheader customization
    void set_step_header(string label) { this._subheaders[0] = label; }
    void set_accum_header(string label) { this._subheaders[1] = label; }
    void set_change_header(string label) { this._subheaders[2] = label; }
    void set_next_total_header(string label) { this._subheaders[3] = label; }
    void set_title(string title) { this._title = title; }

    // Render the table into a picture. Parameters follow the same pattern as
    // other Visualizations: render(width, height, unit) where width/height are
    // in diagram units and `unit` is the unitsize used for the picture.
    picture render(real width, real height, real unit) {
        picture pic = new picture;
        unitsize(pic, unit);

        int rows = this._steps + 1;

        // Reserve vertical space: header + subheader + rows
        real headerH = height * 0.14;
        real subH = height * 0.10;
        real bodyH = max(0, height - headerH - subH);
        real rowH = bodyH / rows;

        // Use fixed proportional column widths so the table always fits `width`.
        // Ratios chosen: Step : Accumulated : Change : Next Total = 1 : 2.5 : 2 : 2.5
        real totalRatio = 1 + 2.5 + 2 + 2.5;
        real col0_w = width * (1.0 / totalRatio);
        real col1_w = width * (2.5 / totalRatio);
        real col2_w = width * (2.0 / totalRatio);
        real col3_w = width * (2.5 / totalRatio);
        real cell_padding = 0.08 * min(col0_w, min(col1_w, min(col2_w, col3_w))); // inset for left-aligned labels

        // Starting origin is (0,0) at bottom-left in Image conventions
        real origin_x = 0;
        real origin_y = 0;

        // Top of the table
        real top_y = origin_y + height;

        // Draw header background
        fill(pic, box((origin_x, top_y - headerH), (origin_x + width, top_y)), function_color_1 + fill_pen);
        label(pic, this._title, (origin_x + width / 2, top_y - headerH / 2), p=header_2.p);

        // Draw subheader background
        real sub_top = top_y - headerH;
        fill(pic, box((origin_x, sub_top - subH), (origin_x + width, sub_top)), function_color_2 + fill_pen);
        // Body starts below the subheader band
        real body_top = sub_top - subH;

        // Column left positions
        real x0 = origin_x;
        real x1 = x0 + col0_w;
        real x2 = x1 + col1_w;
        real x3 = x2 + col2_w;
        real x4 = x3 + col3_w;

        // Draw subheader texts (centered in each cell horizontally)
        label(pic, this._subheaders[0], (x0 + cell_padding, sub_top - subH / 2), align=E, p=text_normal.p);
        label(pic, this._subheaders[1], (x1 + cell_padding, sub_top - subH / 2), align=E, p=text_normal.p);
        label(pic, this._subheaders[2], (x2 + cell_padding, sub_top - subH / 2), align=E, p=text_normal.p);
        label(pic, this._subheaders[3], (x3 + cell_padding, sub_top - subH / 2), align=E, p=text_normal.p);

        // Draw horizontal lines: top of header already filled; separator below subheader
        draw(pic, (x0, sub_top)--(x4, sub_top), p=outline_pen);      // header/subheader separator
        draw(pic, (x0, body_top)--(x4, body_top), p=outline_pen);    // subheader/body separator

        // Rows: iterate from 0 (topmost row under subheader) downwards
        for (int r = 0; r < rows; ++r) {
            // Row bottom y (we place row 0 at top of body area)
            real row_top = body_top - r * rowH;
            real row_bot = body_top - (r + 1) * rowH;

            // Optional: alternate row shading
            if (r % 2 == 1) {
                // subtle off-white shading for alternate rows
                fill(pic, box((x0, row_bot), (x4, row_top)), rgb(0.99, 0.99, 0.99));
            }

            // Draw horizontal line for this row top
            draw(pic, (x0, row_top)--(x4, row_top), p=outline_pen);

            // Cell centers for labels
            pair c0 = (x0 + cell_padding, row_bot + rowH / 2);
            pair c1 = (x1 + cell_padding, row_bot + rowH / 2);
            pair c2 = (x2 + cell_padding, row_bot + rowH / 2);
            pair c3 = (x3 + cell_padding, row_bot + rowH / 2);

            // Text values
            string s0 = string(r);
            string s1 = _fmt(this._accum[r], 2);
            label(pic, s0, c0, align=E, p=text_normal.p);
            label(pic, s1, c1, align=E, p=text_normal.p);

            bool is_last_row = (r == rows - 1);
            if (is_last_row) {
                // Last row: no "next" change, mark with an X.
                pair tl = (x2, row_top);
                pair tr = (x3, row_top);
                pair bl = (x2, row_bot);
                pair br = (x3, row_bot);
                draw(pic, tl--br, p=outline_pen);
                draw(pic, bl--tr, p=outline_pen);

                pair tl2 = (x3, row_top);
                pair tr2 = (x4, row_top);
                pair bl2 = (x3, row_bot);
                pair br2 = (x4, row_bot);
                draw(pic, tl2--br2, p=outline_pen);
                draw(pic, bl2--tr2, p=outline_pen);
            } else {
                string s2 = _fmt(this._accum[r + 1] - this._accum[r], 2);
                string s3 = _fmt(this._accum[r + 1], 2);
                label(pic, s2, c2, align=E, p=text_normal.p);
                label(pic, s3, c3, align=E, p=text_normal.p);
            }
        }

        // Bottom border
        draw(pic, (x0, origin_y)--(x4, origin_y), p=outline_pen);

        // Vertical separators drawn last so they are visible over row fills.
        // Outer borders span the full table; inner column dividers skip the header band.
        draw(pic, (x0, top_y)--(x0, origin_y), p=outline_pen);
        draw(pic, (x4, top_y)--(x4, origin_y), p=outline_pen);
        draw(pic, (x1, sub_top)--(x1, origin_y), p=outline_pen);
        draw(pic, (x2, sub_top)--(x2, origin_y), p=outline_pen);
        draw(pic, (x3, sub_top)--(x3, origin_y), p=outline_pen);
        draw(pic, (x0, top_y)--(x4, top_y), p=outline_pen); // top border of the table

        if (this._debug_mode) {
            draw(pic, box((0,0),(width, height)), p=gray + linewidth(0.5));
        }

        return pic;
    }
};
