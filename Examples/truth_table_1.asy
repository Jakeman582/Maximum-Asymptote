import MyFunctions;

unitsize(1cm);

// Propositions
bool p_1(bool a) {return !a;}

Proposition_1[] propositions = {
    Proposition_1("", "$\neg p$", p_1, 1)
};

pair[] highlighted_cells = {
    //(1, 1), (0, 0), (1, 0)
};
pair[] hidden_cells = {
    //(0, 1)
};

truth_table_1(
    1cm, 
    3, 4, 
    propositions, 
    highlighted_cells, lightgreen, 
    hidden_cells
);