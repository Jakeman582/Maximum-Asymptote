///////////////////////////////////////////////////////////////////////////////////////////////////
// TextSetWidth - Calculate width needed for a set of labels
// 
// Note: This file expects the following to be defined in the including scope:
//   - TypographyPen struct
///////////////////////////////////////////////////////////////////////////////////////////////////

// Estimate text width using a TypographyPen struct
// This ensures the pen and its spacing estimate are always used together
real estimate_text_width(string text, TypographyPen typo_pen) {
    if (length(text) == 0) {
        return 0;
    }
    
    // Use the char_width_estimate from the struct if available
    if (typo_pen.char_width_estimate > 0) {
        return length(text) * typo_pen.char_width_estimate;
    }
    
    // Fallback: simple estimate if char_width_estimate not set
    return length(text) * 0.4;
}

// Calculate the width needed for a set of labels
// Returns the width needed to accommodate the largest string in the array
// Uses the TypographyPen's char_width_estimate for consistent spacing
real set_text_width(string[] strings, TypographyPen typo_pen) {
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

