import MyFunctions;

unitsize(1cm);

// Propositions
bool p_1(bool a, bool b) {
    return a & ((!a) & b);
}

Proposition_2[] propositions = {
    Proposition_2("", "$\neg p \land (p \land q)$", p_1, 2)
};

pair[] highlighted_cells = {
    //(1, 1), (0, 0), (1, 0)
};

pair[] hidden_cells = {
    //(0, 0), (0, 1), (0, 2), 
    //(1, 0), (1, 1), (1, 2), 
    //(2, 0), (2, 1), (2, 2), 
    //(3, 0), (3, 1), (3, 2)
};

truth_table_2(
    1cm, 
    7, 5, 
    propositions, 
    highlighted_cells, lightgreen, 
    hidden_cells
);
