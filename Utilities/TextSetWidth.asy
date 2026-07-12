///////////////////////////////////////////////////////////////////////////////////////////////////
// TextSetWidth - Calculate width needed for a set of labels
//
// Note: This file expects the following to be defined in the including scope:
//   - measure_text_size() function (from Utilities/TextMeasurement.asy)
///////////////////////////////////////////////////////////////////////////////////////////////////

// Measure the true rendered width of text using a given pen
real estimate_text_width(string text, pen typo_pen) {
    if (length(text) == 0) {
        return 0;
    }

    return measure_text_size(text, typo_pen).x;
}

// Calculate the width needed for a set of labels
// Returns the width needed to accommodate the largest string in the array
real set_text_width(string[] strings, pen typo_pen) {
    if (strings.length == 0) {
        return 0;
    }
    
    real max_width = 0;
    for (string s : strings) {
        real width = estimate_text_width(s, typo_pen);
        max_width = max(max_width, width);
    }
    
    return max_width;
}

