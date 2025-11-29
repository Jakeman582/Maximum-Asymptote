///////////////////////////////////////////////////////////////////////////////////////////////////
// Text wrapping utility functions
///////////////////////////////////////////////////////////////////////////////////////////////////

// Estimate character width for text_normal font (0.55cm)
// This is an approximation - actual width varies by character, but should be sufficient
// for fixed-font caption text wrapping
real estimate_char_width_normal = 0.25;  // Approximate width per character in cm for text_normal

// Wrap text to fit within a given width
// Returns an array of strings, one per line
string[] wrap_text(string text, real max_width, real char_width = estimate_char_width_normal) {
    if (length(text) == 0) {
        return new string[] {""};
    }
    
    // Split text into words (split on spaces)
    string[] words = split(text, " ");
    
    if (words.length == 0) {
        return new string[] {""};
    }
    
    string[] lines = new string[];
    string current_line = "";
    
    for (int i = 0; i < words.length; ++i) {
        string word = words[i];
        string test_line = current_line;
        
        // Add word to current line (with space if not first word)
        if (length(current_line) > 0) {
            test_line = test_line + " " + word;
        } else {
            test_line = word;
        }
        
        // Estimate width of test line
        real test_width = length(test_line) * char_width;
        
        // If line would exceed max width, start a new line
        if (test_width > max_width && length(current_line) > 0) {
            // Save current line and start new one
            lines.push(current_line);
            current_line = word;
        } else {
            // Add word to current line
            current_line = test_line;
        }
    }
    
    // Add the last line if it's not empty
    if (length(current_line) > 0) {
        lines.push(current_line);
    }
    
    return lines;
}

