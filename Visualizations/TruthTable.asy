////////////////////////////////////////////////////////////////////////////////////////////////////
// File: TruthTable.asy
//
// Description:
// Provide a simple truth table visualization for boolean expressions over a list of variables.
// The table draws itself only; naming and captions belong to the surrounding Image layer.
////////////////////////////////////////////////////////////////////////////////////////////////////

using bool_array_function = bool(bool[]);

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: bool_to_text
//
// Description:
// Convert a boolean value to a compact display label.
//
// Inputs:
//    value - The boolean value to convert.
//
// Outputs:
//    result - The display label "1" for true and "0" for false.
////////////////////////////////////////////////////////////////////////////////////////////////////
string bool_to_text(bool value) {
    return value ? "1" : "0";
}

struct TruthTableColumn {
    string _label;
    bool_array_function _evaluator;

    void operator init(string label, bool_array_function evaluator) {
        this._label = label;
        this._evaluator = evaluator;
    }
};

struct TruthTable {
    string[] _variable_labels;
    string[] _column_labels;
    TruthTableColumn[] _columns;
    bool[][] _results;
    string _title;
    bool _debug_mode;

    void operator init(string[] variable_labels, string[] column_labels, bool_array_function[] evaluators, string title = "Truth Table") {
        this._variable_labels = variable_labels;
        this._column_labels = column_labels;
        this._title = title;
        this._debug_mode = false;

        int variable_count = this._variable_labels.length;
        int row_count = 1;
        if (variable_count > 0) {
            for (int i = 0; i < variable_count; ++i) {
                row_count *= 2;
            }
        }

        this._columns = new TruthTableColumn[this._column_labels.length];
        this._results = new bool[this._column_labels.length][];
        for (int c = 0; c < this._column_labels.length; ++c) {
            this._columns[c] = TruthTableColumn(this._column_labels[c], evaluators[c]);
            this._results[c] = new bool[row_count];
        }

        for (int row = 0; row < row_count; ++row) {
            bool[] values = new bool[variable_count];
            for (int col = 0; col < variable_count; ++col) {
                int pattern = row;
                for (int shift = 0; shift < variable_count - 1 - col; ++shift) {
                    pattern = (int)(pattern / 2);
                }
                int bit = pattern % 2;
                values[col] = (bit == 1);
            }
            for (int c = 0; c < this._column_labels.length; ++c) {
                this._results[c][row] = this._columns[c]._evaluator(values);
            }
        }
    }

    void set_debug_mode(bool enabled) { this._debug_mode = enabled; }
    void set_title(string title) { this._title = title; }

    // Number of data rows (2 raised to the variable count).
    int row_count() {
        int count = 1;
        for (int i = 0; i < this._variable_labels.length; ++i) {
            count *= 2;
        }
        return count;
    }

    // Truth value of variable `col` in data row `row`, following the standard descending bit order.
    bool variable_value(int row, int col) {
        int pattern = row;
        for (int shift = 0; shift < this._variable_labels.length - 1 - col; ++shift) {
            pattern = (int)(pattern / 2);
        }
        return (pattern % 2) == 1;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Function: render
    //
    // Description:
    // Render the truth table so it exactly fills the (width, height) box the Image hands down (the
    // image size minus its padding), matching the other visualizations. Column widths are the natural
    // content widths of each column scaled proportionally to fill `width`; row heights fill `height`
    // with the header row kept proportionally taller than the data rows. Cell text is centered.
    //
    // Layout:
    //   - Top row is the header row: header_2 typography, every cell filled with the table header color.
    //   - Variable-column data cells are filled with the table sub header color.
    //   - Expression-column data cells are left white.
    //
    // Inputs:
    //    width  - Width of the box to fill, in diagram units.
    //    height - Height of the box to fill, in diagram units.
    //    unit   - The unit scale used for the picture.
    //
    // Outputs:
    //    pic - The rendered picture containing the truth table.
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    picture render(real width, real height, real unit) {
        picture pic = new picture;
        unitsize(pic, unit);

        int variable_count = this._variable_labels.length;
        int expression_count = this._columns.length;
        int column_count = variable_count + expression_count;
        int rows = this.row_count();
        int total_rows = rows + 1;                  // Data rows plus the header row.

        real horizontal_padding = 0.15;             // Breathing room on each side of cell text.
        real vertical_padding = 0.12;               // Breathing room above and below cell text.

        // Floor for a column's content width: the widest body glyph, so a column is never narrower
        // than a single "0"/"1".
        real cell_size = max(measure_text_width("0", text_normal.p),
                             measure_text_width("1", text_normal.p));

        // Collect every column's header label in left-to-right order (variables, then expressions).
        string[] header_labels = new string[column_count];
        for (int c = 0; c < variable_count; ++c) {
            header_labels[c] = this._variable_labels[c];
        }
        for (int c = 0; c < expression_count; ++c) {
            header_labels[variable_count + c] = this._columns[c]._label;
        }

        // Natural content width per column (widest of its header label and a body glyph). These are
        // used only as relative ratios: they are scaled below so the columns fill `width` exactly.
        real[] natural_column_widths = new real[column_count];
        real natural_total_width = 0;
        for (int c = 0; c < column_count; ++c) {
            real header_width = measure_text_width(header_labels[c], header_2.p);
            natural_column_widths[c] = max(header_width, cell_size) + 2 * horizontal_padding;
            natural_total_width += natural_column_widths[c];
        }

        // Natural row heights: the header row is sized to its tallest label (the larger header pen),
        // data rows to the body glyph. Kept as ratios and scaled below so the rows fill `height`.
        real natural_header_height = measure_text_height("0", header_2.p);
        for (int c = 0; c < column_count; ++c) {
            natural_header_height = max(natural_header_height, measure_text_height(header_labels[c], header_2.p));
        }
        natural_header_height += 2 * vertical_padding;
        real natural_data_height = max(measure_text_height("0", text_normal.p),
                                       measure_text_height("1", text_normal.p)) + 2 * vertical_padding;
        real natural_total_height = natural_header_height + rows * natural_data_height;

        // Fill the given box: scale the natural widths/heights so the table spans exactly
        // width x height, preserving the relative column widths and the header-taller-than-data ratio.
        real total_width = width;
        real total_height = height;

        real[] column_widths = new real[column_count];
        for (int c = 0; c < column_count; ++c) {
            column_widths[c] = natural_column_widths[c] / natural_total_width * total_width;
        }
        real header_row_height = natural_header_height / natural_total_height * total_height;
        real data_row_height = natural_data_height / natural_total_height * total_height;

        // Left edge of each column.
        real[] column_left = new real[column_count + 1];
        column_left[0] = 0;
        for (int c = 0; c < column_count; ++c) {
            column_left[c + 1] = column_left[c] + column_widths[c];
        }

        // Top edge of visual row `i` (0 = header row, 1.. = data rows), measured from the top. Row 0
        // spans the header height; every row below it spans one data height.
        real row_top(int i) {
            if (i <= 0) return total_height;
            return total_height - header_row_height - (i - 1) * data_row_height;
        }

        // Vertical center of visual row `i`, used to center cell text within its cell.
        real row_center(int i) { return (row_top(i) + row_top(i + 1)) / 2; }

        // Fill cell backgrounds before drawing text and grid lines.
        for (int c = 0; c < column_count; ++c) {
            real x_left = column_left[c];
            real x_right = column_left[c + 1];

            fill(pic, box((x_left, row_top(1)), (x_right, row_top(0))), table_header);

            if (c < variable_count) {
                for (int r = 1; r <= rows; ++r) {
                    fill(pic, box((x_left, row_top(r + 1)), (x_right, row_top(r))), table_sub_header);
                }
            }
        }

        // Header row text (header_2 typography, centered horizontally and vertically in its cell).
        for (int c = 0; c < column_count; ++c) {
            real x_center = (column_left[c] + column_left[c + 1]) / 2;
            label(pic, header_labels[c], (x_center, row_center(0)), p=header_2.p);
        }

        // Data row text (text_normal typography, centered horizontally and vertically in its cell).
        for (int r = 0; r < rows; ++r) {
            real y_center = row_center(r + 1);
            for (int c = 0; c < variable_count; ++c) {
                real x_center = (column_left[c] + column_left[c + 1]) / 2;
                label(pic, bool_to_text(this.variable_value(r, c)), (x_center, y_center),
                      p=text_normal.p);
            }
            for (int c = 0; c < expression_count; ++c) {
                int column = variable_count + c;
                real x_center = (column_left[column] + column_left[column + 1]) / 2;
                label(pic, bool_to_text(this._results[c][r]), (x_center, y_center),
                      p=text_normal.p);
            }
        }

        // Grid lines: every column boundary and every row boundary, plus the outer border.
        for (int c = 0; c <= column_count; ++c) {
            draw(pic, (column_left[c], 0)--(column_left[c], total_height), p=outline_pen);
        }
        for (int i = 0; i <= total_rows; ++i) {
            draw(pic, (0, row_top(i))--(total_width, row_top(i)), p=outline_pen);
        }

        if (this._debug_mode) {
            draw(pic, box((0, 0), (total_width, total_height)), p=gray + linewidth(0.5));
        }

        return pic;
    }
};
