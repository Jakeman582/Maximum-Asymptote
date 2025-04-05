import MaximumMathematics;

string[] A = {"1", "2", "3", "4", "5"};
string[] B = {"a", "b", "c", "d", "e"};

pair[] relation = {
    (0, 1),
    (1, 1),
    (2, 1),
    (3, 4),
    (4, 4)
};

arrow_diagram_2(
    1cm, 8,
    "A", A,
    "B", B,
    relation
);