import MaximumMathematics;

string[] variables = {"p", "q"};
string[] column_labels = {"$\neg p$", "$\neg q$", "$\neg p \land \neg q$", "$p \land q$", "$\neg(p \land q)$"};

bool not_p(bool[] values) { return !values[0]; }
bool not_q(bool[] values) { return !values[1]; }
bool not_p_and_not_q(bool[] values) { return !values[0] && !values[1]; }
bool p_and_q(bool[] values) { return values[0] && values[1]; }
bool not_p_and_q(bool[] values) { return !(values[0] && values[1]); }

bool_array_function[] evaluators = {not_p, not_q, not_p_and_not_q, p_and_q, not_p_and_q};

TruthTable table = TruthTable(variables, column_labels, evaluators);

Image img = Image(14, 5);
img.set_diagram_padding(0.2);
img.add(table);
