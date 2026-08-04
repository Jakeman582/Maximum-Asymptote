////////////////////////////////////////////////////////////////////////////////////////////////////
// File: TruthTable.asy
//
// Description:
// A truth table built up one boolean expression at a time. add("p & q") parses the expression
// (see Utilities/BooleanExpression.asy), discovers any variable names it introduces that haven't
// been seen yet, and adds a column for it -- there's nothing to configure up front, since the
// variable columns and row count both fall directly out of whatever's been added by the time
// render() runs. Variable columns are kept sorted alphabetically at all times (re-sorted inside
// add() whenever a new one appears); expression columns stay in add() order. Each expression's
// column header is rendered as LaTeX, exactly as typed (not a logically-equivalent rewrite) -- see
// expr_to_latex() for how. The table draws itself only; naming and captions belong to the
// surrounding Image layer.
//
// Highlighting: highlight_row(row)/highlight_column(column)/highlight(row, column) mark cells for a
// brighter fill at render time -- see render()'s own header comment for exactly which cells each one
// touches. `row` is always a 0-indexed data row (0..row_count()-1); `column` is always a 0-indexed
// expression column (0 = the first add()'ed expression), never a variable column -- there's no
// highlighted variant of the variable header's gray, so only expression columns are ever
// individually targetable.
////////////////////////////////////////////////////////////////////////////////////////////////////

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

struct TruthTable {
    string[] _variables;    // Discovered variable names, kept sorted alphabetically at all times.
    ExprNode[] _trees;      // Each added expression's raw parse tree, one per column, in add() order.
    string[] _headers;      // Each column's LaTeX header (expr_to_latex(tree), no $ delimiters yet).

    int[] _highlighted_rows;          // Rows passed to highlight_row().
    int[] _highlighted_columns;       // Expression columns passed to highlight_column().
    int[] _highlighted_cell_rows;     // Parallel to _highlighted_cell_columns: each pair is one highlight(row, column) call.
    int[] _highlighted_cell_columns;

    void operator init() {
        this._variables = new string[];
        this._trees = new ExprNode[];
        this._headers = new string[];
        this._highlighted_rows = new int[];
        this._highlighted_columns = new int[];
        this._highlighted_cell_rows = new int[];
        this._highlighted_cell_columns = new int[];
    }

    // Parse and add one expression column, e.g. add("p & q") or add("p -> (q <-> r)"). Any variable
    // names this expression introduces that no earlier add() call already discovered are merged into
    // the variable list, which is then re-sorted alphabetically -- there's no separate step to
    // declare variables, and no way to control variable column order directly.
    void add(string expression) {
        ExprNode tree = parse_boolean_expression(expression);

        string[] expression_variables = collect_variables(tree);
        bool found_new_variable = false;
        for (int i = 0; i < expression_variables.length; ++i) {
            bool already_known = false;
            for (int j = 0; j < this._variables.length; ++j) {
                if (this._variables[j] == expression_variables[i]) { already_known = true; break; }
            }
            if (!already_known) {
                this._variables.push(expression_variables[i]);
                found_new_variable = true;
            }
        }
        if (found_new_variable) this._variables = sort(this._variables);

        this._trees.push(tree);
        this._headers.push(expr_to_latex(tree));
    }

    // Highlight every cell in data row `row` (0-indexed): every atomic-proposition value cell in the
    // row turns table_variable_value_highlight_color, and every expression (interior) value cell in
    // the row turns table_highlight_color. No header cell is affected.
    void highlight_row(int row) {
        this._highlighted_rows.push(row);
    }

    // Highlight expression column `column` (0-indexed among added expressions, not counting variable
    // columns): its header cell turns table_expression_header_highlight_color, and every one of its
    // value cells turns table_highlight_color. No other column is affected.
    void highlight_column(int column) {
        this._highlighted_columns.push(column);
    }

    // Highlight the single interior cell at data row `row`, expression column `column` with
    // table_highlight_color -- and, so the highlighted row and column are easy to trace, that row's
    // atomic-proposition cells (table_variable_value_highlight_color) and that column's header
    // (table_expression_header_highlight_color). No other interior cell is affected: every other cell
    // in the same row or column stays the plain white table_expression_value_color.
    void highlight(int row, int column) {
        this._highlighted_cell_rows.push(row);
        this._highlighted_cell_columns.push(column);
    }

    bool is_row_highlighted(int row) {
        for (int i = 0; i < this._highlighted_rows.length; ++i) {
            if (this._highlighted_rows[i] == row) return true;
        }
        return false;
    }

    bool is_column_highlighted(int column) {
        for (int i = 0; i < this._highlighted_columns.length; ++i) {
            if (this._highlighted_columns[i] == column) return true;
        }
        return false;
    }

    bool is_cell_highlighted(int row, int column) {
        for (int i = 0; i < this._highlighted_cell_rows.length; ++i) {
            if (this._highlighted_cell_rows[i] == row && this._highlighted_cell_columns[i] == column) return true;
        }
        return false;
    }

    bool row_has_highlighted_cell(int row) {
        for (int i = 0; i < this._highlighted_cell_rows.length; ++i) {
            if (this._highlighted_cell_rows[i] == row) return true;
        }
        return false;
    }

    bool column_has_highlighted_cell(int column) {
        for (int i = 0; i < this._highlighted_cell_columns.length; ++i) {
            if (this._highlighted_cell_columns[i] == column) return true;
        }
        return false;
    }

    // Number of data rows (2 raised to the variable count).
    int row_count() {
        int count = 1;
        for (int i = 0; i < this._variables.length; ++i) {
            count *= 2;
        }
        return count;
    }

    // Truth value of variable `col` in data row `row`. Rows cycle through every combination the same
    // way normal digits count: the right-most variable column changes every row (fastest), the
    // left-most changes only once every 2^(n-1) rows (slowest).
    bool variable_value(int row, int col) {
        int pattern = row;
        for (int shift = 0; shift < this._variables.length - 1 - col; ++shift) {
            pattern = (int)(pattern / 2);
        }
        return (pattern % 2) == 1;
    }

    // Fill for the atomic-proposition value cell at data row `row`.
    pen variable_cell_fill(int row) {
        if (this.is_row_highlighted(row)) return table_variable_value_highlight_color;
        if (this.row_has_highlighted_cell(row)) return table_variable_value_highlight_color;
        return table_variable_value_color;
    }

    // Fill for the expression header cell at expression column `column`.
    pen expression_header_fill(int column) {
        if (this.is_column_highlighted(column)) return table_expression_header_highlight_color;
        if (this.column_has_highlighted_cell(column)) return table_expression_header_highlight_color;
        return table_expression_header_color;
    }

    // Fill for the interior (expression) value cell at data row `row`, expression column `column`.
    // Only an exact target -- either an explicit highlight() cell, or a cell in a row/column passed
    // to highlight_row()/highlight_column() -- ever turns yellow; every other interior cell stays
    // white, even one that shares a row or column with a highlighted cell.
    pen expression_cell_fill(int row, int column) {
        if (this.is_cell_highlighted(row, column)) return table_highlight_color;
        if (this.is_row_highlighted(row) || this.is_column_highlighted(column)) return table_highlight_color;
        return table_expression_value_color;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Function: render
    //
    // Description:
    // Render the truth table so it exactly fills the (width, height) box the Image hands down (the
    // image size minus its padding), matching the other visualizations. Column widths are the natural
    // content widths of each column scaled proportionally to fill `width`; row heights fill `height`.
    // Every expression column's values are evaluated fresh from its own tree here, rather than cached
    // from add() time, since the full variable set (and so the row count) isn't final until every
    // add() call has happened. Aborts if any highlight_row/highlight_column/highlight() call named a
    // row or column past the table's actual (final) size.
    //
    // Layout:
    //   - Every cell -- header and data alike -- renders at the same font size (text_normal).
    //   - Atomic-proposition (variable) header cells: table_variable_header_color (light gray),
    //     never highlighted.
    //   - Expression header cells: table_expression_header_color (light tinted orange), or
    //     table_expression_header_highlight_color if that column was passed to highlight_column() or
    //     highlight().
    //   - Atomic-proposition value cells: table_variable_value_color (light tinted blue), or
    //     table_variable_value_highlight_color if that row was passed to highlight_row() or
    //     highlight().
    //   - Every other ("interior") cell -- an expression's evaluated value -- is
    //     table_expression_value_color (white) by default, independent of any Image/Gallery
    //     background; table_highlight_color if it's an exact highlight_row()/highlight_column()/
    //     highlight() target. Merely sharing a row or column with a highlight() target, without being
    //     a target itself, has no effect -- that cell stays plain white.
    //   - All values (0/1) are right-aligned within their cell; headers stay centered.
    //   - The outer border, the boundary between the atomic-proposition and expression columns, and
    //     the boundary between the header row and the data rows all use outline_pen; every other
    //     row/column separator uses table_minor_pen (half its thickness).
    //
    // Inputs:
    //    width  - Width of the box to fill, in diagram units.
    //    height - Height of the box to fill, in diagram units.
    //    unit   - The unit scale used for the picture.
    //
    // Outputs:
    //    pic - The rendered picture containing the truth table.
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    picture render(real width, real height, real unit = diagram_unit) {
        picture pic = new picture;
        unitsize(pic, unit);

        int variable_count = this._variables.length;
        int expression_count = this._trees.length;
        int column_count = variable_count + expression_count;
        int rows = this.row_count();
        int total_rows = rows + 1;                  // Data rows plus the header row.

        for (int i = 0; i < this._highlighted_rows.length; ++i) {
            if (this._highlighted_rows[i] < 0 || this._highlighted_rows[i] >= rows) {
                abort("TruthTable.highlight_row: row " + (string)this._highlighted_rows[i]
                      + " is out of range (table has " + (string)rows + " rows)");
            }
        }
        for (int i = 0; i < this._highlighted_columns.length; ++i) {
            if (this._highlighted_columns[i] < 0 || this._highlighted_columns[i] >= expression_count) {
                abort("TruthTable.highlight_column: column " + (string)this._highlighted_columns[i]
                      + " is out of range (table has " + (string)expression_count + " expression columns)");
            }
        }
        for (int i = 0; i < this._highlighted_cell_rows.length; ++i) {
            if (this._highlighted_cell_rows[i] < 0 || this._highlighted_cell_rows[i] >= rows) {
                abort("TruthTable.highlight: row " + (string)this._highlighted_cell_rows[i]
                      + " is out of range (table has " + (string)rows + " rows)");
            }
            if (this._highlighted_cell_columns[i] < 0 || this._highlighted_cell_columns[i] >= expression_count) {
                abort("TruthTable.highlight: column " + (string)this._highlighted_cell_columns[i]
                      + " is out of range (table has " + (string)expression_count + " expression columns)");
            }
        }

        real horizontal_padding = 0.15;              // Breathing room on each side of cell text.
        real vertical_padding = 0.12;                // Breathing room above and below cell text.

        // Floor for a column's content width: the widest body glyph, so a column is never narrower
        // than a single "0"/"1".
        real cell_size = max(measure_text_width("0", text_normal),
                             measure_text_width("1", text_normal));

        // Collect every column's header label in left-to-right order (atomic propositions, sorted
        // alphabetically, then expressions in add() order), each wrapped as LaTeX math so variable
        // names and expressions render with the same look.
        string[] header_labels = new string[column_count];
        for (int c = 0; c < variable_count; ++c) {
            header_labels[c] = "$" + this._variables[c] + "$";
        }
        for (int c = 0; c < expression_count; ++c) {
            header_labels[variable_count + c] = "$" + this._headers[c] + "$";
        }

        // Natural content width per column (widest of its header label and a body glyph) -- wide
        // enough for an expression's rendered LaTeX header, however long it is. These are used only
        // as relative ratios: they are scaled below so the columns fill `width` exactly.
        real[] natural_column_widths = new real[column_count];
        real natural_total_width = 0;
        for (int c = 0; c < column_count; ++c) {
            real header_width = measure_text_width(header_labels[c], text_normal);
            natural_column_widths[c] = max(header_width, cell_size) + 2 * horizontal_padding;
            natural_total_width += natural_column_widths[c];
        }

        // Natural row heights. Kept as ratios and scaled below so the rows fill `height`.
        real natural_header_height = measure_text_height("0", text_normal);
        for (int c = 0; c < column_count; ++c) {
            natural_header_height = max(natural_header_height, measure_text_height(header_labels[c], text_normal));
        }
        natural_header_height += 2 * vertical_padding;
        real natural_data_height = max(measure_text_height("0", text_normal),
                                       measure_text_height("1", text_normal)) + 2 * vertical_padding;
        real natural_total_height = natural_header_height + rows * natural_data_height;

        // Fill the given box: scale the natural widths/heights so the table spans exactly
        // width x height, preserving the relative column widths and row heights.
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

        // Vertical center of visual row `i`, used to center header text within its cell.
        real row_center(int i) { return (row_top(i) + row_top(i + 1)) / 2; }

        // Fill cell backgrounds before drawing text and grid lines. Header fills are one color per
        // column (variable columns never highlight; expression columns check highlight_column()/
        // highlight()); data fills are computed per cell, since row-based highlighting can vary
        // within a single column.
        for (int c = 0; c < column_count; ++c) {
            real x_left = column_left[c];
            real x_right = column_left[c + 1];
            bool is_variable_column = c < variable_count;
            int expr_column = c - variable_count;   // Only meaningful when !is_variable_column.

            pen header_fill = is_variable_column ? table_variable_header_color : this.expression_header_fill(expr_column);
            fill(pic, box((x_left, row_top(1)), (x_right, row_top(0))), header_fill);

            for (int r = 1; r <= rows; ++r) {
                int data_row = r - 1;   // 0-indexed, matching variable_value()'s row parameter.
                pen data_fill = is_variable_column
                    ? this.variable_cell_fill(data_row)
                    : this.expression_cell_fill(data_row, expr_column);
                fill(pic, box((x_left, row_top(r + 1)), (x_right, row_top(r))), data_fill);
            }
        }

        // Header row text: centered horizontally and vertically in its cell.
        for (int c = 0; c < column_count; ++c) {
            real x_center = (column_left[c] + column_left[c + 1]) / 2;
            label(pic, header_labels[c], (x_center, row_center(0)), p=text_normal);
        }

        // Data row text: right-aligned within its cell, anchored horizontal_padding in from the
        // column's right edge. Every row's variable assignment is built once and reused for all
        // expression columns.
        for (int r = 0; r < rows; ++r) {
            real y_center = row_center(r + 1);

            bool[] values = new bool[variable_count];
            for (int c = 0; c < variable_count; ++c) {
                values[c] = this.variable_value(r, c);
            }

            for (int c = 0; c < variable_count; ++c) {
                real x_right = column_left[c + 1] - horizontal_padding;
                label(pic, bool_to_text(values[c]), (x_right, y_center), align=W, p=text_normal);
            }
            for (int c = 0; c < expression_count; ++c) {
                int column = variable_count + c;
                real x_right = column_left[column + 1] - horizontal_padding;
                bool result = evaluate_expr(this._trees[c], this._variables, values);
                label(pic, bool_to_text(result), (x_right, y_center), align=W, p=text_normal);
            }
        }

        // Grid lines. The outer border, the boundary between the atomic-proposition and expression
        // columns, and the boundary between the header row and the data rows all use outline_pen;
        // every other row/column separator uses table_minor_pen (half its thickness).
        for (int c = 0; c <= column_count; ++c) {
            bool is_major = c == 0 || c == column_count || c == variable_count;
            draw(pic, (column_left[c], 0)--(column_left[c], total_height), p=is_major ? outline_pen : table_minor_pen);
        }
        for (int i = 0; i <= total_rows; ++i) {
            bool is_major = i == 0 || i == total_rows || i == 1;
            draw(pic, (0, row_top(i))--(total_width, row_top(i)), p=is_major ? outline_pen : table_minor_pen);
        }

        return pic;
    }
};
