import MaximumMathematics;

unitsize(1cm);

real width = 8;
real height = 5;

pair[] highlighted_cells = {
    //(1, 1), (0, 0), (1, 0)
};
pair[] hidden_cells = {
    //(0, 1)
};

// Propositions
bool p_1(bool a, bool b) {return (!a) | b;}
bool p_2(bool a, bool b) {return (a & b) |  ((!a) & (!b));}

picture fig_1;
Proposition_2[] propositions_1 = {
    Proposition_2("", "$p \rightarrow q$", p_1, 2)
};
truth_table_2(
    fig_1,
    1cm, 
    width, height, 
    propositions_1, 
    highlighted_cells, lightgreen, 
    hidden_cells
);

picture fig_2;
Proposition_2[] propositions_2 = {
    Proposition_2("", "$p \leftrightarrow q$", p_2, 2)
};
truth_table_2(
    fig_2,
    1cm, 
    width, height, 
    propositions_2, 
    highlighted_cells, lightgreen, 
    hidden_cells
);

add(fig_1);
add(fig_2, (width, 0) + 0.5E);