///////////////////////////////////////////////////////////////////////////////////////////////////
// Text measurement utility functions
// Measures the true rendered size of text (including LaTeX math) by typesetting it and reading
// back the bounding box. Asymptote renders labels through LaTeX, so a string such as
// "$p \land q$" is measured at its real glyph extent rather than its raw character count.
///////////////////////////////////////////////////////////////////////////////////////////////////

// A label is "truesize" content: its bounding box is reported in PostScript points (bp), not in
// the picture's unit, regardless of unitsize. Convert points to centimeters to match the rest of
// the library, which works in cm (1 bp = 1/72 inch, 1 inch = 2.54 cm).
real bp_to_cm = 2.54 / 72;

// Measure the true rendered size of text with a given pen.
// Returns (width, height) in centimeters.
pair measure_text_size(string text, pen p) {
    if (length(text) == 0) {
        return (0, 0);
    }

    // Typeset the text into a throwaway picture and read its bounding box. Center alignment keeps
    // the box symmetric around the origin; only its extent matters here.
    picture temp_pic = new picture;
    unitsize(temp_pic, 1cm);
    label(temp_pic, text, (0, 0), p=p, align=Center);

    pair lo = min(temp_pic);
    pair hi = max(temp_pic);

    return ((hi.x - lo.x) * bp_to_cm, (hi.y - lo.y) * bp_to_cm);
}

// Measure the true rendered width of text with a given pen.
// Returns the width in centimeters.
real measure_text_width(string text, pen p) {
    return measure_text_size(text, p).x;
}

// Measure the true rendered height of text with a given pen.
// Returns the height in centimeters.
real measure_text_height(string text, pen p) {
    return measure_text_size(text, p).y;
}

// Find a single character width that accommodates every character in a sample (monospace-like).
// Measures a sample of characters with the given pen and returns the widest.
// Useful for deriving a square cell size for grid layouts.
real find_universal_char_width(pen p) {
    string sample_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,;:!?()[]{}";

    real max_width = 0;
    for (int i = 0; i < length(sample_chars); ++i) {
        string ch = substr(sample_chars, i, 1);
        max_width = max(max_width, measure_text_width(ch, p));
    }

    return max_width;
}
