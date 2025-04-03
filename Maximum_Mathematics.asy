import three;

unitsize(1cm);

void drawcircle(pair center, real radius, pen p=black) {
    draw(circle(center, radius), p);
}

void drawbox(triple corner, real width, real length, real height) {
    surface s = shift(corner) * scale(width, length, height) * unitcube;
    draw(s, surfacepen = white);
}

void arrow_diagram_2(
    picture pic = currentpicture,
    real unit, real length, 
    string A_string, string[] A, 
    string B_string, string[] B, 
    pair[] relation, 
    string caption, real caption_margin = 0.1
) {

    // Several scaling factors for text and dots
    real dot_factor = 0.5;
    real element_text_factor = 1.5;
    real set_text_factor = 3;
    real caption_text_factor = 1.5;
    real label_zone = 0.2;
    real caption_zone = 0.05;
    real set_zone = 1.0 - label_zone - caption_zone;

    // Setting up the canvas dimensions
    real x_min = -0.5 * length;
    real x_max = 0.5 * length;
    real y_min = -0.5 * length;
    real y_max = 0.5 * length;

    unitsize(pic, unit);

    // Setting up the drawing and text pens
    pen dot_pen = linewidth(dot_factor * length);
    pen element_pen = fontsize(element_text_factor * length);
    pen set_pen = fontsize(set_text_factor * length);
    pen caption_pen = fontsize(caption_text_factor * length);

    // The set labels will appear in their own zone
    real label_zone_top = y_max;
    real label_zone_height = label_zone * length;

    // The caption label will appear in the bottom zone
    real caption_zone_top = y_min + length * caption_zone;
    real caption_zone_height = caption_zone * length;

    // The sets will use the bulk part of the height
    real set_zone_top = y_max - label_zone_height;
    real set_zone_height = set_zone * length;

    // The sets need to be at the 1/5 and 4/5 lines of the image
    real divider_x = 1.0 / 5.0;
    real A_x = x_min + (length * divider_x);
    real B_x = x_max - (length * divider_x);

    // Set location for the first set's label
    pair A_label = (A_x, label_zone_top - label_zone_height/2.0);

    // Set locations for the first set of labels
    real A_element_height = set_zone_height / A.length;
    pair[] A_locations = {};
    for(int i = 0; i < A.length; ++i){
        A_locations.push((A_x, set_zone_top - i * A_element_height - A_element_height/2.0));
    }

    // Set location for the second set's label
    pair B_label = (B_x, label_zone_top - label_zone_height/2.0);

    // Set locations for the second set of labels
    real B_element_height = set_zone_height / B.length;
    pair[] B_locations = {};
    for(int i = 0; i < B.length; ++i) {
        B_locations.push((B_x, set_zone_top - i * B_element_height - B_element_height/2.0));
    }

    // Draw a background box
    fill(pic, box((x_min, y_min) + caption_margin*S, (x_max, y_max)), white);

    // Draw the set labels and set elements
    label(pic, A_string, A_label, p = set_pen);
    label(pic, B_string, B_label, p = set_pen);

    for(int i = 0; i < A.length; ++i) {
        dot(pic, A_locations[i], p = dot_pen);
        label(pic, A[i], A_locations[i] + 0.5W, p = element_pen);
    }

    for(int i = 0; i < B.length; ++i) {
        dot(pic, B_locations[i], p = dot_pen);
        label(pic, B[i], B_locations[i] + 0.5E, p = element_pen);
    }

    // Now we draw the arrows representing the relation
    for(int i = 0; i < relation.length; ++i) {

        int index_1 = (int) relation[i].x;
        int index_2 = (int) relation[i].y;

        draw(
            pic, 
            A_locations[index_1]--B_locations[index_2],
            arrow = Arrow,
            margin = Margin(0, 3)
        );
    }

    // Draw the caption label
    label(pic, caption, (0, caption_zone_top - caption_zone_height / 2.0), p = caption_pen);
}

void arrow_diagram_3(
    picture pic = currentpicture,
    real unit, 
    real width, real height, 
    string A_string, string[] A, 
    string B_string, string[] B, 
    string C_string, string[] C,
    pair[] relation_AB,
    pair[] relation_BC, 
    string caption, real caption_margin = 0.1
) {

    // Several scaling factors for text and dots
    real dot_factor = 0.5;
    real element_text_factor = 1.5;
    real set_text_factor = 3;
    real caption_text_factor = 1.5;
    real label_zone = 0.2;
    real caption_zone = 0.05;
    real set_zone = 1.0 - label_zone - caption_zone;

    // Setting up the canvas dimensions
    real x_min = -0.5 * width;
    real x_max = 0.5 * width;
    real y_min = -0.5 * height;
    real y_max = 0.5 * height;

    unitsize(pic, unit);

    // Setting up the drawing and text pens
    pen dot_pen = linewidth(dot_factor * height);
    pen element_pen = fontsize(element_text_factor * height);
    pen set_pen = fontsize(set_text_factor * height);
    pen caption_pen = fontsize(caption_text_factor * height);

    // The set labels will appear in their own zone
    real label_zone_top = y_max;
    real label_zone_height = label_zone * height;

    // The caption label will appear in the bottom zone
    real caption_zone_top = y_min + height * caption_zone;
    real caption_zone_height = caption_zone * height;

    // The sets will use the bulk part of the height
    real set_zone_top = y_max - label_zone_height;
    real set_zone_height = set_zone * height;

    // The sets need to be at the 1/5, 1/2, and 4/5 lines of the image
    real divider_1 = 1.0 / 8.0;
    real divider_2 = 1.0 / 2.0;
    real divider_3 = 7.0 / 8.0;
    real A_x = x_min + (width * divider_1);
    real B_x = x_min + (width * divider_2);
    real C_x = x_min + (width * divider_3);

    // Set location for the first set's label
    pair A_label = (A_x, label_zone_top - label_zone_height/2.0);

    // Set locations for the first set of labels
    real A_element_height = set_zone_height / A.length;
    pair[] A_locations = {};
    for(int i = 0; i < A.length; ++i){
        A_locations.push((A_x, set_zone_top - i * A_element_height - A_element_height/2.0));
    }

    // Set location for the second set's label
    pair B_label = (B_x, label_zone_top - label_zone_height/2.0);

    // Set locations for the second set of labels
    real B_element_height = set_zone_height / B.length;
    pair[] B_locations = {};
    for(int i = 0; i < B.length; ++i) {
        B_locations.push((B_x, set_zone_top - i * B_element_height - B_element_height/2.0));
    }

    // Set location for the third set's label
    pair C_label = (C_x, label_zone_top - label_zone_height/2.0);

    // Set locations for the third set of labels
    real C_element_height = set_zone_height / C.length;
    pair[] C_locations = {};
    for(int i = 0; i < C.length; ++i) {
        C_locations.push((C_x, set_zone_top - i * C_element_height - C_element_height/2.0));
    }

    // Draw a background box
    fill(pic, box((x_min, y_min) + caption_margin*S, (x_max, y_max)), white);

    // Draw the set labels and set elements
    label(pic, A_string, A_label, p = set_pen);
    label(pic, B_string, B_label, p = set_pen);
    label(pic, C_string, C_label, p = set_pen);

    for(int i = 0; i < A.length; ++i) {
        dot(pic, A_locations[i] + 0.5E, p = dot_pen);
        label(pic, A[i], A_locations[i], p = element_pen);
    }

    for(int i = 0; i < B.length; ++i) {
        dot(pic, B_locations[i] + 0.5W, p = dot_pen);
        label(pic, B[i], B_locations[i], p = element_pen);
        dot(pic, B_locations[i] + 0.5E, p = dot_pen);
    }

    for(int i = 0; i < C.length; ++i) {
        dot(pic, C_locations[i] + 0.5W, p = dot_pen);
        label(pic, C[i], C_locations[i], p = element_pen);
    }

    // Now we draw the arrows representing the relation from A to B
    for(int i = 0; i < relation_AB.length; ++i) {

        int index_1 = (int) relation_AB[i].x;
        int index_2 = (int) relation_AB[i].y;

        draw(
            pic, 
            (A_locations[index_1] + 0.5E)--(B_locations[index_2] + 0.5W),
            arrow = Arrow,
            margin = Margin(0, 3)
        );
    }

    // Now we draw the arrows representing the relation from B to C
    for(int i = 0; i < relation_BC.length; ++i) {

        int index_1 = (int) relation_BC[i].x;
        int index_2 = (int) relation_BC[i].y;

        draw(
            pic, 
            (B_locations[index_1] + 0.5E)--(C_locations[index_2] + 0.5W),
            arrow = Arrow,
            margin = Margin(0, 3)
        );
    }

    // Draw the caption label
    label(pic, caption, (0, caption_zone_top - caption_zone_height / 2.0), p = caption_pen);
}

bool[] logical_values = {false, true};

using proposition_1 = bool(bool);
struct Proposition_1 {
    string text_upper;
    string text_lower;
    proposition_1 value;
    real weight;

    void operator init(string text_upper, string text_lower, proposition_1 value, real weight) {
        this.text_upper = text_upper;
        this.text_lower = text_lower;
        this.value = value;
        this.weight = weight;
    }
};

void truth_table_1(
    picture pic = currentpicture,
    real unit = 1cm,
    real width, real height, 
    real header_row_factor = 1/4, 
    string p_1 = "p",
    Proposition_1[] propositions, 
    pair[] highlighted_cells = {}, pen highlight_color = lightyellow,
    pair[] hidden_cells = {}
) {

    ///////////////////////////////////////////////////////////////////////////
    // IMAGE CONFIGURATION
    ///////////////////////////////////////////////////////////////////////////

    unitsize(pic, unit);

    // Settings to control various aspects of the image
    pen border_pen = linewidth(2);
    pen header_pen = fontsize(0.6cm);

    // Count the number of columns needed
    int label_columns = 1;
    int expression_columns = propositions.length;
    int columns = label_columns + expression_columns;

    // Calculate how wide each column should be, based on each proposition's weight. The label columns are 
    // assumed to have a weight of one.
    real total_weight = 1;
    for(Proposition_1 proposition : propositions) {
        total_weight = total_weight + proposition.weight;
    }

    // Use the total weight to calculate the column's width
    real[] column_widths = {width / total_weight};
    for(Proposition_1 proposition : propositions) {
        column_widths.push(width * proposition.weight / total_weight);
    }

    // Accumulate the column widths so we can access their left coordinates more easily
    real[] column_lefts;
    real current_x = 0;
    for(int i = 0; i < columns; ++i) {
        column_lefts.push(current_x);
        current_x += column_widths[i];
    }

    // Count the number of rows needed. If any of the upper text strings are non-empty, then we'll need 
    // another header row for those labels
    int header_rows = 1;
    for(Proposition_1 proposition : propositions) {
        if(length(proposition.text_upper) > 0) {
            header_rows = 2;
        }
    }
    int expression_rows = 2;
    int rows = header_rows + expression_rows;

    // Every row should have the same height, though the header row be different
    real header_row_height = header_row_factor * height;
    real expression_row_height = (height - header_rows * header_row_height) / expression_rows;

    // Calculate the height of each row for easier access later
    real[] row_heights = {header_row_height};
    if(header_rows > 1) {row_heights.push(header_row_height);}
    for(int i = 0; i < expression_rows; ++i) {
        row_heights.push(expression_row_height);
    }

    // Accumulate the row heights so we can more easily access the top coordinate of each cell later more easily
    real[] row_tops = {height};
    real current_y = height - header_row_height;
    if(header_rows > 1) {
        row_tops.push(height - header_row_height);
        current_y -= header_row_height;
    }
    for(int i = header_rows; i < rows; ++i) {
        row_tops.push(current_y - expression_row_height);
        current_y -= expression_row_height;
    }

    ///////////////////////////////////////////////////////////////////////////
    // IMAGE DRAWING
    ///////////////////////////////////////////////////////////////////////////

    // Draw a border around the entire table
    fill(pic, box((0, 0) + 0.1SW, (width, height) + 0.1NE), black);

    // Draw the background of the truth table. The header should be a gray color, while the columns with 
    // the label values should be a lighter gray, but still darker than white.
    fill(pic, box((0, height), (width, height - (header_rows * header_row_height))), gray);
    fill(pic, box((0, 0), (column_widths[0], expression_rows * expression_row_height)), mediumgray);
    fill(pic, box((column_widths[0], 0), (width, height - (header_rows * header_row_height))), white);

    // Draw the background of any highlighted cells using the highlight color
    real base_x = column_widths[0];
    real base_y = height - (header_rows * header_row_height);
    for(pair cell : highlighted_cells) {
        real left = column_lefts[1 + (int)cell.y];
        real right = left + column_widths[1 + (int)cell.y];
        real bottom = base_y - (expression_row_height * ((int)cell.x + 1));
        real top = bottom + expression_row_height;
        fill(pic, box((left, bottom), (right, top)), p = highlight_color);
    }

    // Draw any upper header labels if necessary
    if(header_rows > 1) {
        current_y = height;
        current_x = column_widths[0];
        for(int i = 0; i < propositions.length; ++i) {
            label(pic, 
                propositions[i].text_upper, 
                (current_x + column_widths[i + 1]/2, current_y - header_row_height/2),
                p = header_pen
            );
            current_x += column_widths[i + 1];
        }
    }

    // Draw the header row labels
    current_y = height;
    if(header_rows > 1) {current_y -= header_row_height;}
    label(pic, p_1, (column_widths[0]/2, current_y - header_row_height/2), p = header_pen);

    // Draw the label values
    current_y = height - header_rows * header_row_height;
    for(bool a : logical_values) {
        label(pic, a ? "1" : "0", (column_widths[0]/2, current_y - expression_row_height/2));
        current_y -= expression_row_height;
    }

    // Draw the expression row proposition labels
    current_x = column_widths[0];
    current_y = height;
    if(header_rows > 1) {current_y -= header_row_height;}
    for(int i = 0; i < propositions.length; ++i) {
        label(pic, propositions[i].text_lower, (current_x + column_widths[i + 1]/2, current_y - header_row_height/2), p = header_pen);
        current_x += column_widths[i + 1];
    }

    // Draw the values of each proposition in the expression rows
    current_y = height - header_rows * header_row_height;
    for(bool a : logical_values) {
        current_x = column_widths[0];
        for(int i = 0; i < propositions.length; ++i) {
            string value = propositions[i].value(a) ? "1" : "0";
            label(pic, value, (current_x + column_widths[i + 1]/2, current_y - expression_row_height/2));
            current_x += column_widths[i + 1];
        }
        current_y -= expression_row_height;
    }

    // Draw a white box over any hidden cells
    real base_x = column_widths[0];
    real base_y = height - (header_rows * header_row_height);
    for(pair cell : hidden_cells) {
        real left = column_lefts[1 + (int)cell.y];
        real right = left + column_widths[1 + (int)cell.y];
        real bottom = base_y - (expression_row_height * ((int)cell.x + 1));
        real top = bottom + expression_row_height;
        fill(pic, box((left, bottom), (right, top)), white);
    }

    // Draw the border between the label columns and the expression columns
    current_x = column_widths[0];
    draw(pic, (current_x, 0)--(current_x, height), p = border_pen);

    // Draw the remaining borders for the expression columns
    for(int i = 1; i < column_widths.length; ++i) {
        draw(pic, (current_x, 0)--(current_x, height));
        current_x = current_x + column_widths[i];
    }

    // Draw the header row borders
    current_y = height - header_row_height;
    if(header_rows > 1) {
        draw(pic, (column_widths[0], current_y)--(width, current_y));
        current_y -= header_row_height;
    }
    draw(pic, (0, current_y)--(width, current_y), p = border_pen);

    // Draw the expression row borders
    for(int i = 1; i < expression_rows; ++i) {
        current_y = current_y - expression_row_height;
        draw(pic, (0, current_y)--(width, current_y));
    }

    // Draw any upper header labels if necessary
    if(header_rows > 1) {
        current_y = height;
        current_x = column_widths[0];
        for(int i = 0; i < propositions.length; ++i) {
            label(pic, 
                propositions[i].text_upper, 
                (current_x + column_widths[i + 1]/2, current_y - header_row_height/2),
                p = header_pen
            );
            current_x += column_widths[i + 1];
        }
    }

}

using proposition_2 = bool(bool, bool);
struct Proposition_2 {
    string text_upper;
    string text_lower;
    proposition_2 value;
    real weight;

    void operator init(string text_upper, string text_lower, proposition_2 value, real weight) {
        this.text_upper = text_upper;
        this.text_lower = text_lower;
        this.value = value;
        this.weight = weight;
    }
};

void truth_table_2(
    picture pic = currentpicture,
    real unit = 1cm,
    real width, real height, 
    real header_row_factor = 1/6, 
    string p_1 = "p", string p_2 = "q",
    Proposition_2[] propositions, 
    pair[] highlighted_cells = {}, pen highlight_color = lightyellow,
    pair[] hidden_cells = {}
) {

    ///////////////////////////////////////////////////////////////////////////
    // IMAGE CONFIGURATION
    ///////////////////////////////////////////////////////////////////////////

    unitsize(pic, unit);

    // Settings to control various aspects of the image
    pen border_pen = linewidth(2);
    pen header_pen = fontsize(0.6cm);

    // Count the number of columns needed
    int label_columns = 2;
    int expression_columns = propositions.length;
    int columns = label_columns + expression_columns;

    // Calculate how wide each column should be, based on each proposition's weight. The label columns are 
    // assumed to have a weight of one.
    real total_weight = 2;
    for(Proposition_2 proposition : propositions) {
        total_weight = total_weight + proposition.weight;
    }

    // Use the total weight to calculate the column's width
    real[] column_widths = {width / total_weight, width / total_weight};
    for(Proposition_2 proposition : propositions) {
        column_widths.push(width * proposition.weight / total_weight);
    }

    // Accumulate the column widths so we can access their left coordinates more easily
    real[] column_lefts;
    real current_x = 0;
    for(int i = 0; i < columns; ++i) {
        column_lefts.push(current_x);
        current_x += column_widths[i];
    }

    // Count the number of rows needed. If any of the upper text strings are non-empty, then we'll need 
    // another header row for those labels
    int header_rows = 1;
    for(Proposition_2 proposition : propositions) {
        if(length(proposition.text_upper) > 0) {
            header_rows = 2;
        }
    }
    int expression_rows = 4;
    int rows = header_rows + expression_rows;

    // Every row should have the same height, though the header row be different
    real header_row_height = header_row_factor * height;
    real expression_row_height = (height - header_rows * header_row_height) / expression_rows;

    // Calculate the height of each row for easier access later
    real[] row_heights = {header_row_height};
    if(header_rows > 1) {row_heights.push(header_row_height);}
    for(int i = 0; i < expression_rows; ++i) {
        row_heights.push(expression_row_height);
    }

    // Accumulate the row heights so we can more easily access the top coordinate of each cell later more easily
    real[] row_tops = {height};
    real current_y = height - header_row_height;
    if(header_rows > 1) {
        row_tops.push(height - header_row_height);
        current_y -= header_row_height;
    }
    for(int i = header_rows; i < rows; ++i) {
        row_tops.push(current_y - expression_row_height);
        current_y -= expression_row_height;
    }

    ///////////////////////////////////////////////////////////////////////////
    // IMAGE DRAWING
    ///////////////////////////////////////////////////////////////////////////

    // Draw a border around the entire table
    fill(pic, box((0, 0) + 0.1SW, (width, height) + 0.1NE), black);

    // Draw the background of the truth table. The header should be a gray color, while the columns with 
    // the label values should be a lighter gray, but still darker than white.
    fill(pic, box((0, height), (width, height - (header_rows * header_row_height))), gray);
    fill(pic, box((0, 0), (column_widths[0] + column_widths[1], expression_rows * expression_row_height)), mediumgray);
    fill(pic, box((column_widths[0] + column_widths[1], 0), (width, height - (header_rows * header_row_height))), white);

    // Draw the background of any highlighted cells using the highlight color
    real base_x = column_widths[0] + column_widths[1];
    real base_y = height - (header_rows * header_row_height);
    for(pair cell : highlighted_cells) {
        real left = column_lefts[2 + (int)cell.y];
        real right = left + column_widths[2 + (int)cell.y];
        real bottom = base_y - (expression_row_height * ((int)cell.x + 1));
        real top = bottom + expression_row_height;
        fill(pic, box((left, bottom), (right, top)), p = highlight_color);
    }

    // Draw any upper header labels if necessary
    if(header_rows > 1) {
        current_y = height;
        current_x = column_widths[0] + column_widths[1];
        for(int i = 0; i < propositions.length; ++i) {
            label(pic, 
                propositions[i].text_upper, 
                (current_x + column_widths[i + 2]/2, current_y - header_row_height/2),
                p = header_pen
            );
            current_x += column_widths[i + 2];
        }
    }

    // Draw the header row labels
    current_y = height;
    if(header_rows > 1) {current_y -= header_row_height;}
    label(pic, p_1, (column_widths[0]/2, current_y - header_row_height/2), p = header_pen);
    label(pic, p_2, (column_widths[0] + (column_widths[1]/2), current_y - header_row_height/2), p = header_pen);

    // Draw the label values
    current_y = height - header_rows * header_row_height;
    for(bool a : logical_values) {
        for(bool b : logical_values) {
            label(pic, a ? "1" : "0", (column_widths[0]/2, current_y - expression_row_height/2));
            label(pic, b ? "1" : "0", (column_widths[0] + column_widths[1]/2, current_y - expression_row_height/2));
            current_y -= expression_row_height;
        }
    }

    // Draw the expression row proposition labels
    current_x = column_widths[0] + column_widths[1];
    current_y = height;
    if(header_rows > 1) {current_y -= header_row_height;}
    for(int i = 0; i < propositions.length; ++i) {
        label(pic, propositions[i].text_lower, (current_x + column_widths[i + 2]/2, current_y - header_row_height/2), p = header_pen);
        current_x += column_widths[i + 2];
    }

    // Draw the values of each proposition in the expression rows
    current_y = height - header_rows * header_row_height;
    for(bool a : logical_values) {
        for(bool b : logical_values) {
            current_x = column_widths[0] + column_widths[1];
            for(int i = 0; i < propositions.length; ++i) {
                string value = propositions[i].value(a, b) ? "1" : "0";
                label(pic, value, (current_x + column_widths[i + 2]/2, current_y - expression_row_height/2));
                current_x += column_widths[i + 2];
            }
            current_y -= expression_row_height;
        }
    }

    // Draw a white box over any hidden cells
    real base_x = column_widths[0] + column_widths[1];
    real base_y = height - (header_rows * header_row_height);
    for(pair cell : hidden_cells) {
        real left = column_lefts[2 + (int)cell.y];
        real right = left + column_widths[2 + (int)cell.y];
        real bottom = base_y - (expression_row_height * ((int)cell.x + 1));
        real top = bottom + expression_row_height;
        fill(pic, box((left, bottom), (right, top)), white);
    }

    // Draw the column border for the label columns
    current_x = column_widths[0];
    draw(pic, (current_x, 0)--(current_x, height));

    // Draw the border between the label columns and the expression columns
    current_x += column_widths[1];
    draw(pic, (current_x, 0)--(current_x, height), p = border_pen);

    // Draw the remaining borders for the expression columns
    for(int i = 2; i < column_widths.length; ++i) {
        draw(pic, (current_x, 0)--(current_x, height));
        current_x = current_x + column_widths[i];
    }

    // Draw the header row borders
    real current_y = height - header_row_height;
    if(header_rows > 1) {
        draw(pic, (column_widths[0] + column_widths[1], current_y)--(width, current_y));
        current_y -= header_row_height;
    }
    draw(pic, (0, current_y)--(width, current_y), p = border_pen);

    // Draw the expression row borders
    for(int i = 1; i < expression_rows; ++i) {
        current_y = current_y - expression_row_height;
        draw(pic, (0, current_y)--(width, current_y));
    }

    // Draw any upper header labels if necessary
    if(header_rows > 1) {
        current_y = height;
        current_x = column_widths[0] + column_widths[1];
        for(int i = 0; i < propositions.length; ++i) {
            label(pic, 
                propositions[i].text_upper, 
                (current_x + column_widths[i + 2]/2, current_y - header_row_height/2),
                p = header_pen
            );
            current_x += column_widths[i + 2];
        }
    }

}

using proposition_3 = bool(bool, bool, bool);
struct Proposition_3 {
    string text_upper;
    string text_lower;
    proposition_3 value;
    real weight;

    void operator init(string text_upper, string text_lower, proposition_3 value, real weight) {
        this.text_upper = text_upper;
        this.text_lower = text_lower;
        this.value = value;
        this.weight = weight;
    }
};

void truth_table_3(
    picture pic = currentpicture,
    real unit = 1cm,
    real width, real height, 
    real header_row_factor = 1 / 8, 
    string p_1 = "p", string p_2 = "q", string p_3 = "r",
    Proposition_3[] propositions, 
    pair[] highlighted_cells = {}, pen highlight_color = lightyellow,
    pair[] hidden_cells = {}
) {

    ///////////////////////////////////////////////////////////////////////////
    // IMAGE CONFIGURATION
    ///////////////////////////////////////////////////////////////////////////

    unitsize(pic, unit);

    // Settings to control various aspects of the image
    pen border_pen = linewidth(2);
    pen header_pen = fontsize(0.6cm);

    // Count the number of columns needed
    int label_columns = 3;
    int expression_columns = propositions.length;
    int columns = label_columns + expression_columns;

    // Calculate how wide each column should be, based on each proposition's weight. The label columns are 
    // assumed to have a weight of one.
    real total_weight = 3;
    for(Proposition_3 proposition : propositions) {
        total_weight = total_weight + proposition.weight;
    }

    // Use the total weight to calculate how wide each column should be
    real[] column_widths = {width / total_weight, width / total_weight, width / total_weight};
    for(Proposition_3 proposition : propositions) {
        column_widths.push(width * proposition.weight / total_weight);
    }

    // Accumulate the column widths so we can access their left coordinates more easily
    real[] column_lefts;
    real current_x = 0;
    for(int i = 0; i < columns; ++i) {
        column_lefts.push(current_x);
        current_x += column_widths[i];
    }

    // Count the number of rows needed. If any of the text_1 strings of the given propositions are non
    // empty, then we'll need a row for the extra header labels
    int header_rows = 1;
    for(Proposition_3 proposition : propositions) {
        if(length(proposition.text_upper) > 0) {
            header_rows = 2;
        }
    }
    int expression_rows = 8;
    int rows = header_rows + expression_rows;

    // Every row should have the same height, though the header rows be different
    real header_row_height = header_row_factor * height;
    real expression_row_height = (height - header_rows * header_row_height) / expression_rows;

    // Calculate the height of each row for easier access later
    real[] row_heights = {header_row_height};
    if(header_rows > 1) {row_heights.push(header_row_height);}
    for(int i = 0; i < expression_rows; ++i) {
        row_heights.push(expression_row_height);
    }

    // Accumulate the row heights so we can more easily access the top coordinate of each cell later more easily
    real[] row_tops = {height};
    real current_y = height - header_row_height;
    if(header_rows > 1) {
        row_tops.push(height - header_row_height);
        current_y -= header_row_height;
    }
    for(int i = header_rows; i < rows; ++i) {
        row_tops.push(current_y - expression_row_height);
        current_y -= expression_row_height;
    }

    ///////////////////////////////////////////////////////////////////////////
    // IMAGE DRAWING
    ///////////////////////////////////////////////////////////////////////////

    // Draw a border around the entire table
    fill(pic, box((0, 0) + 0.1SW, (width, height) + 0.1NE), black);

    // Draw the background of the truth table. The header should be a gray color, while the columns with 
    // the label values should be a lighter gray, but still darker than white.
    fill(pic, box((0, height), (width, height - (header_rows * header_row_height))), gray);
    fill(pic, box((0, 0), (column_widths[0] + column_widths[1] + column_widths[2], expression_rows * expression_row_height)), mediumgray);
    fill(pic, box((column_widths[0] + column_widths[1] + column_widths[2], 0), (width, height - (header_rows * header_row_height))), white);

    // Draw the background of any highlighted cells using the highlight color
    real base_x = column_widths[0] + column_widths[1] + column_widths[2];
    real base_y = height - (header_rows * header_row_height);
    for(pair cell : highlighted_cells) {
        real left = column_lefts[3 + (int)cell.y];
        real right = left + column_widths[3 + (int)cell.y];
        real bottom = base_y - (expression_row_height * ((int)cell.x + 1));
        real top = bottom + expression_row_height;
        fill(pic, box((left, bottom), (right, top)), p = highlight_color);
    }

    // Draw any upper header labels if necessary
    if(header_rows > 1) {
        current_y = height;
        current_x = column_widths[0] + column_widths[1] + column_widths[2];
        for(int i = 0; i < propositions.length; ++i) {
            label(pic, 
                propositions[i].text_upper, 
                (current_x + column_widths[i + 3]/2, current_y - header_row_height/2),
                p = header_pen
            );
            current_x += column_widths[i + 3];
        }
    }

    // Draw the header row labels
    current_y = height;
    if(header_rows > 1) {current_y -= header_row_height;}
    label(pic, p_1, (column_widths[0]/2, current_y - header_row_height/2), p = header_pen);
    label(pic, p_2, (column_widths[0] + (column_widths[1]/2), current_y - header_row_height/2), p = header_pen);
    label(pic, p_3, (column_widths[0] + column_widths[1] + (column_widths[2]/2), current_y - header_row_height/2), p = header_pen);

    // Draw the label values
    current_y = height - header_rows * header_row_height;
    for(bool a : logical_values) {
        for(bool b : logical_values) {
            for(bool c : logical_values) {
                label(pic, a ? "1" : "0", (column_widths[0]/2, current_y - expression_row_height/2));
                label(pic, b ? "1" : "0", (column_widths[0] + column_widths[1]/2, current_y - expression_row_height/2));
                label(pic, c ? "1" : "0", (column_widths[0] + column_widths[1] + column_widths[2]/2, current_y - expression_row_height/2));
                current_y -= expression_row_height;
            }
        }
    }

    // Draw the expression row proposition labels
    current_x = column_widths[0] + column_widths[1] + column_widths[2];
    current_y = height;
    if(header_rows > 1) {current_y -= header_row_height;}
    for(int i = 0; i < propositions.length; ++i) {
        label(pic, propositions[i].text_lower, (current_x + column_widths[i + 3]/2, current_y - header_row_height/2), p = header_pen);
        current_x += column_widths[i + 3];
    }

    // Draw the values of each proposition in the expression rows
    current_y = height - header_rows * header_row_height;
    for(bool a : logical_values) {
        for(bool b : logical_values) {
            for(bool c : logical_values) {
                current_x = column_widths[0] + column_widths[1] + column_widths[2];
                for(int i = 0; i < propositions.length; ++i) {
                    string value = propositions[i].value(a, b, c) ? "1" : "0";
                    label(pic, value, (current_x + column_widths[i + 3]/2, current_y - expression_row_height/2));
                    current_x += column_widths[i + 3];
                }
                current_y -= expression_row_height;
            }
        }
    }

    // Draw a white box over any hidden cells
    real base_x = column_widths[0] + column_widths[1] + column_widths[2];
    real base_y = height - (header_rows * header_row_height);
    for(pair cell : hidden_cells) {
        real left = column_lefts[3 + (int)cell.y];
        real right = left + column_widths[3 + (int)cell.y];
        real bottom = base_y - (expression_row_height * ((int)cell.x + 1));
        real top = bottom + expression_row_height;
        fill(pic, box((left, bottom), (right, top)), white);
    }

    // Draw the first and second column border for the label columns
    current_x = column_widths[0];
    draw(pic, (current_x, 0)--(current_x, height));
    current_x += column_widths[1];
    draw(pic, (current_x, 0)--(current_x, height));

    // Draw the border between the label columns and the expression columns
    current_x += column_widths[2];
    draw(pic, (current_x, 0)--(current_x, height), p = border_pen);

    // Draw the remaining borders for the expression columns
    for(int i = 3; i < column_widths.length; ++i) {
        draw(pic, (current_x, 0)--(current_x, height));
        current_x = current_x + column_widths[i];
    }

    // Draw the header row borders
    real current_y = height - header_row_height;
    if(header_rows > 1) {
        draw(pic, (column_widths[0] + column_widths[1] + column_widths[2], current_y)--(width, current_y));
        current_y -= header_row_height;
    }
    draw(pic, (0, current_y)--(width, current_y), p = border_pen);

    // Draw the expression row borders
    for(int i = 1; i < expression_rows; ++i) {
        current_y = current_y - expression_row_height;
        draw(pic, (0, current_y)--(width, current_y));
    }

}