////////////////////////////////////////////////////////////////////////////////////////////////////
// File: BooleanExpression.asy
//
// Description:
// Parses a programmer-style boolean expression string (identifiers, !, &, |, ^, ->, <->, and
// parentheses; ! > & > | > ^ > -> > <-> precedence, loosest last) into an ExprNode tree, and
// provides three operations on that raw tree: collect_variables() (the distinct variable names, in
// first-seen order), evaluate_expr() (its truth value under a given assignment), and expr_to_latex()
// (a minimally-parenthesized LaTeX rendering, matching what was typed rather than any rewritten
// form). normalize() below is a separate, fourth operation: it converts the raw tree into negation
// normal form (NNF) — pushing every negation down to the leaves via De Morgan's laws, desugaring
// XOR/->/<-> into AND/OR/NOT along the way, so a NOT node never appears in a normalized tree at all
// and only LEAF/AND/OR remain; a negated variable is just a LEAF with negated=true instead. Used by
// SwitchingNetwork (which needs the normalized AND/OR/LEAF form for its series/parallel layout) and
// TruthTable (which works from the raw tree instead, so headers and evaluation match the input
// verbatim) — not specific to either.
////////////////////////////////////////////////////////////////////////////////////////////////////

int EXPR_LEAF = 0;
int EXPR_NOT = 1;
int EXPR_AND = 2;
int EXPR_OR = 3;
int EXPR_XOR = 4;
int EXPR_IMPLIES = 5;
int EXPR_IFF = 6;

// A node in a boolean expression tree.
//
// Field applicability by kind:
//    variable, negated - LEAF only. negated is always false on a freshly parsed tree (raw parse
//                        trees represent negation with a NOT node instead); normalize() below is
//                        what moves negation onto the leaf itself.
//    children          - NOT: exactly 1 child. AND/OR/XOR/IMPLIES/IFF: exactly 2 children (chains
//                        like A & B & C parse as nested binary nodes, e.g. AND(AND(A,B),C) —
//                        equivalent to a flat n-ary AND for every purpose this tree is used for).
struct ExprNode {
    int kind;
    string variable;
    bool negated;
    ExprNode[] children;
}

// Mutable scan position over the input string, shared across parse_level()'s recursive calls.
struct ParserState {
    string input;
    int pos;
    int len;

    void operator init(string input) {
        this.input = input;
        this.pos = 0;
        this.len = length(input);
    }
}

bool is_identifier_char(string c) {
    return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || (c >= "0" && c <= "9") || c == "_";
}

void skip_whitespace(ParserState s) {
    while (s.pos < s.len && substr(s.input, s.pos, 1) == " ") ++s.pos;
}

string peek_char(ParserState s) {
    skip_whitespace(s);
    if (s.pos >= s.len) return "";
    return substr(s.input, s.pos, 1);
}

// Checks whether the input, after skipping whitespace, starts with the given (possibly
// multi-character) token -- e.g. "->" or "<->" -- and consumes it if so.
bool match_token(ParserState s, string token) {
    skip_whitespace(s);
    int token_len = length(token);
    if (s.pos + token_len > s.len) return false;
    if (substr(s.input, s.pos, token_len) != token) return false;
    s.pos += token_len;
    return true;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: parse_level
//
// Description:
// Recursive-descent parser for one grammar level, folded into a single self-recursive function
// rather than the more usual one-function-per-level: Asymptote does not support mutual recursion
// between separately named functions (confirmed directly — a forward-declared function's variable
// is still null when an earlier-defined function tries to call it, and struct methods can't
// reference a sibling declared later at all), so a parenthesized sub-expression's "re-enter the
// grammar from the top" step has to be a call to this same function instead. Levels, loosest-binding
// first: 0 = <-> (IFF), 1 = -> (IMPLIES), 2 = ^ (XOR), 3 = | (OR), 4 = & (AND), 5 = ! / atom
// (highest) — matching ! > & > | > ^ > -> > <-> binding order. Every binary level is
// left-associative.
//
// Inputs:
//    s     - Shared mutable scan position; advanced past whatever this call consumes.
//    level - Grammar level to parse at (0 through 5 — see above).
//
// Outputs:
//    node - The parsed subtree for this level.
////////////////////////////////////////////////////////////////////////////////////////////////////
ExprNode parse_level(ParserState s, int level) {
    if (level == 0) {
        ExprNode left = parse_level(s, 1);
        while (match_token(s, "<->")) {
            ExprNode right = parse_level(s, 1);
            ExprNode n = new ExprNode;
            n.kind = EXPR_IFF;
            n.children = new ExprNode[] {left, right};
            left = n;
        }
        return left;
    } else if (level == 1) {
        ExprNode left = parse_level(s, 2);
        while (match_token(s, "->")) {
            ExprNode right = parse_level(s, 2);
            ExprNode n = new ExprNode;
            n.kind = EXPR_IMPLIES;
            n.children = new ExprNode[] {left, right};
            left = n;
        }
        return left;
    } else if (level == 2) {
        ExprNode left = parse_level(s, 3);
        while (peek_char(s) == "^") {
            ++s.pos;
            ExprNode right = parse_level(s, 3);
            ExprNode n = new ExprNode;
            n.kind = EXPR_XOR;
            n.children = new ExprNode[] {left, right};
            left = n;
        }
        return left;
    } else if (level == 3) {
        ExprNode left = parse_level(s, 4);
        while (peek_char(s) == "|") {
            ++s.pos;
            ExprNode right = parse_level(s, 4);
            ExprNode n = new ExprNode;
            n.kind = EXPR_OR;
            n.children = new ExprNode[] {left, right};
            left = n;
        }
        return left;
    } else if (level == 4) {
        ExprNode left = parse_level(s, 5);
        while (peek_char(s) == "&") {
            ++s.pos;
            ExprNode right = parse_level(s, 5);
            ExprNode n = new ExprNode;
            n.kind = EXPR_AND;
            n.children = new ExprNode[] {left, right};
            left = n;
        }
        return left;
    } else {
        if (peek_char(s) == "!") {
            ++s.pos;
            ExprNode child = parse_level(s, 5);   // right-recursive, so !!A parses as NOT(NOT(A))
            ExprNode n = new ExprNode;
            n.kind = EXPR_NOT;
            n.children = new ExprNode[] {child};
            return n;
        }
        if (peek_char(s) == "(") {
            ++s.pos;
            ExprNode e = parse_level(s, 0);
            if (peek_char(s) != ")") {
                abort("BooleanExpression: expected ')' in expression: " + s.input);
            }
            ++s.pos;
            return e;
        }
        skip_whitespace(s);
        int start = s.pos;
        while (s.pos < s.len && is_identifier_char(substr(s.input, s.pos, 1))) ++s.pos;
        if (s.pos == start) {
            abort("BooleanExpression: expected a variable name at position " + string(start)
                  + " in expression: " + s.input);
        }
        ExprNode n = new ExprNode;
        n.kind = EXPR_LEAF;
        n.variable = substr(s.input, start, s.pos - start);
        return n;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: parse_boolean_expression
//
// Description:
// Parse a full boolean expression string into a raw ExprNode tree (still containing NOT/XOR/
// IMPLIES/IFF nodes exactly as written — see normalize() to convert to negation normal form).
// Aborts if the expression contains anything left over after a complete parse (e.g. a stray
// trailing character or an unmatched paren).
//
// Inputs:
//    input - The expression string, e.g. "A & (B | !C)" or "p -> (q <-> r)".
//
// Outputs:
//    root - The raw parsed tree.
////////////////////////////////////////////////////////////////////////////////////////////////////
ExprNode parse_boolean_expression(string input) {
    ParserState s = ParserState(input);
    ExprNode result = parse_level(s, 0);
    skip_whitespace(s);
    if (s.pos != s.len) {
        abort("BooleanExpression: unexpected character '" + peek_char(s) + "' at position "
              + string(s.pos) + " in expression: " + input);
    }
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: collect_variables
//
// Description:
// Walk a raw (or normalized) expression tree and return every distinct variable name it mentions,
// in first-seen order (left to right, depth first).
//
// Inputs:
//    node - Subtree to collect from.
//
// Outputs:
//    variables - Distinct variable names, in first-seen order.
////////////////////////////////////////////////////////////////////////////////////////////////////
string[] collect_variables(ExprNode node) {
    if (node.kind == EXPR_LEAF) {
        return new string[] {node.variable};
    }
    if (node.kind == EXPR_NOT) {
        return collect_variables(node.children[0]);
    }

    // AND, OR, XOR, IMPLIES, and IFF all have exactly two children.
    string[] left = collect_variables(node.children[0]);
    string[] right = collect_variables(node.children[1]);
    string[] result = left;
    for (int i = 0; i < right.length; ++i) {
        bool found = false;
        for (int j = 0; j < result.length; ++j) {
            if (result[j] == right[i]) { found = true; break; }
        }
        if (!found) result.push(right[i]);
    }
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: evaluate_expr
//
// Description:
// Evaluate a raw (or normalized) expression tree's truth value under a given variable assignment.
// AND/OR/XOR/IMPLIES/IFF are evaluated via Asymptote's own real bool operators (&&, ||, ^, ==) once
// both children are reduced to plain bool values -- only the input STRING syntax is custom here, not
// how two already-known bools get combined.
//
// Inputs:
//    node           - Subtree to evaluate.
//    variable_names - Variable names, in the same order as variable_values (see collect_variables).
//    variable_values - This assignment's truth value for each name in variable_names.
//
// Outputs:
//    result - The subtree's truth value under this assignment.
////////////////////////////////////////////////////////////////////////////////////////////////////
bool evaluate_expr(ExprNode node, string[] variable_names, bool[] variable_values) {
    if (node.kind == EXPR_LEAF) {
        for (int i = 0; i < variable_names.length; ++i) {
            if (variable_names[i] == node.variable) {
                return node.negated ? !variable_values[i] : variable_values[i];
            }
        }
        abort("BooleanExpression: unknown variable '" + node.variable + "'");
    }
    if (node.kind == EXPR_NOT) {
        return !evaluate_expr(node.children[0], variable_names, variable_values);
    }

    bool left = evaluate_expr(node.children[0], variable_names, variable_values);
    bool right = evaluate_expr(node.children[1], variable_names, variable_values);
    if (node.kind == EXPR_AND) return left && right;
    if (node.kind == EXPR_OR) return left || right;
    if (node.kind == EXPR_XOR) return left ^ right;
    if (node.kind == EXPR_IMPLIES) return !left || right;
    return left == right;   // EXPR_IFF
}

// Binding strength for expr_to_latex()'s minimal-parenthesization logic -- higher binds tighter.
// Mirrors parse_level()'s levels above, just numbered the opposite way (tightest first).
int expr_precedence(int kind) {
    if (kind == EXPR_NOT) return 5;
    if (kind == EXPR_AND) return 4;
    if (kind == EXPR_OR) return 3;
    if (kind == EXPR_XOR) return 2;
    if (kind == EXPR_IMPLIES) return 1;
    return 0;   // EXPR_IFF
}

string expr_operator_latex(int kind) {
    if (kind == EXPR_AND) return " \land ";
    if (kind == EXPR_XOR) return " \veebar ";
    if (kind == EXPR_OR) return " \lor ";
    if (kind == EXPR_IMPLIES) return " \rightarrow ";
    return " \leftrightarrow ";   // EXPR_IFF
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: expr_to_latex
//
// Description:
// Render a raw (or normalized) expression tree back out as LaTeX, matching what was typed rather
// than any logically-equivalent rewrite -- call this on the tree parse_boolean_expression() returns
// directly, not on normalize()'s output. Parentheses are added only where the grammar actually
// requires them (a child whose own operator binds looser than its parent needs), via the standard
// technique of threading the minimum precedence a child may render at without parentheses down
// through the recursion; a left child may match its parent's own precedence exactly (safe for a
// left-associative grammar), a right child may not.
//
// Inputs:
//    node           - Subtree to render.
//    min_precedence - The precedence this subtree must meet or exceed to avoid being wrapped in
//                      parentheses (0 at the top-level call -- never wrap the whole expression).
//
// Outputs:
//    latex - The rendered LaTeX source, with no surrounding $ delimiters.
////////////////////////////////////////////////////////////////////////////////////////////////////
string expr_to_latex(ExprNode node, int min_precedence = 0) {
    if (node.kind == EXPR_LEAF) {
        return node.negated ? "\neg " + node.variable : node.variable;
    }

    int own_precedence = expr_precedence(node.kind);
    string result;
    if (node.kind == EXPR_NOT) {
        result = "\neg " + expr_to_latex(node.children[0], own_precedence);
    } else {
        string left = expr_to_latex(node.children[0], own_precedence);
        string right = expr_to_latex(node.children[1], own_precedence + 1);
        result = left + expr_operator_latex(node.kind) + right;
    }

    return own_precedence < min_precedence ? "(" + result + ")" : result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: normalize
//
// Description:
// Convert a raw expression tree into negation normal form: XOR/IMPLIES/IFF are first desugared into
// their AND/OR/NOT equivalents (a -> b as !a | b; a ^ b as (a & !b) | (!a & b); a <-> b as
// (a & b) | (!a & !b)), then every NOT is pushed down to the leaves via De Morgan's laws
// (NOT(AND(a,b)) = OR(NOT a, NOT b); NOT(OR(a,b)) = AND(NOT a, NOT b)) and double negations cancel,
// so the returned tree contains only LEAF, AND, and OR nodes — a LEAF's own negated field carries
// what would otherwise have been a NOT wrapping it.
//
// Inputs:
//    node   - Subtree to normalize.
//    negate - Whether this subtree is under an odd number of enclosing NOTs (pass false at the
//             top-level call).
//
// Outputs:
//    node - The normalized subtree.
////////////////////////////////////////////////////////////////////////////////////////////////////
ExprNode normalize(ExprNode node, bool negate) {
    if (node.kind == EXPR_LEAF) {
        ExprNode n = new ExprNode;
        n.kind = EXPR_LEAF;
        n.variable = node.variable;
        n.negated = negate;
        return n;
    } else if (node.kind == EXPR_NOT) {
        return normalize(node.children[0], !negate);
    } else if (node.kind == EXPR_IMPLIES) {
        // a -> b  ==  !a | b
        ExprNode not_a = new ExprNode;
        not_a.kind = EXPR_NOT;
        not_a.children = new ExprNode[] {node.children[0]};
        ExprNode n = new ExprNode;
        n.kind = EXPR_OR;
        n.children = new ExprNode[] {not_a, node.children[1]};
        return normalize(n, negate);
    } else if (node.kind == EXPR_XOR) {
        // a ^ b  ==  (a & !b) | (!a & b)
        ExprNode a = node.children[0];
        ExprNode b = node.children[1];
        ExprNode not_a = new ExprNode; not_a.kind = EXPR_NOT; not_a.children = new ExprNode[] {a};
        ExprNode not_b = new ExprNode; not_b.kind = EXPR_NOT; not_b.children = new ExprNode[] {b};
        ExprNode left = new ExprNode; left.kind = EXPR_AND; left.children = new ExprNode[] {a, not_b};
        ExprNode right = new ExprNode; right.kind = EXPR_AND; right.children = new ExprNode[] {not_a, b};
        ExprNode n = new ExprNode;
        n.kind = EXPR_OR;
        n.children = new ExprNode[] {left, right};
        return normalize(n, negate);
    } else if (node.kind == EXPR_IFF) {
        // a <-> b  ==  (a & b) | (!a & !b)
        ExprNode a = node.children[0];
        ExprNode b = node.children[1];
        ExprNode not_a = new ExprNode; not_a.kind = EXPR_NOT; not_a.children = new ExprNode[] {a};
        ExprNode not_b = new ExprNode; not_b.kind = EXPR_NOT; not_b.children = new ExprNode[] {b};
        ExprNode left = new ExprNode; left.kind = EXPR_AND; left.children = new ExprNode[] {a, b};
        ExprNode right = new ExprNode; right.kind = EXPR_AND; right.children = new ExprNode[] {not_a, not_b};
        ExprNode n = new ExprNode;
        n.kind = EXPR_OR;
        n.children = new ExprNode[] {left, right};
        return normalize(n, negate);
    } else if (node.kind == EXPR_AND) {
        ExprNode a = normalize(node.children[0], negate);
        ExprNode b = normalize(node.children[1], negate);
        ExprNode n = new ExprNode;
        n.kind = negate ? EXPR_OR : EXPR_AND;
        n.children = new ExprNode[] {a, b};
        return n;
    } else {
        ExprNode a = normalize(node.children[0], negate);
        ExprNode b = normalize(node.children[1], negate);
        ExprNode n = new ExprNode;
        n.kind = negate ? EXPR_AND : EXPR_OR;
        n.children = new ExprNode[] {a, b};
        return n;
    }
}
