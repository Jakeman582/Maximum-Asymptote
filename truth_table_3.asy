import MyFunctions;

unitsize(1cm);

// Propositions
bool p_1(bool a, bool b, bool c) {return a | b;}
bool p_2(bool a, bool b, bool c) {return (a | b) & c;}
bool p_3(bool a, bool b, bool c) {return (a | b) & (a | c);}

Proposition_3[] propositions = {
    Proposition_3("", "$(p \lor q) \land r$", p_2, 3)
};

pair[] highlighted_cells = {
    (3, 0), (5, 0), (7, 0)
};
pair[] hidden_cells = {
    //(0, 0), (0, 1), 
    //(1, 0), (1, 1), 
    //(2, 0), (2, 1), 
    //(3, 0), (3, 1), 
    //(4, 0), (4, 1), 
    //(5, 0), (5, 1), 
    //(6, 0), (6, 1), 
    //(7, 0), (7, 1), 
};

truth_table_3(
    1cm, 
    8, 6, 
    propositions, 
    highlighted_cells, lightgreen, 
    hidden_cells
);
