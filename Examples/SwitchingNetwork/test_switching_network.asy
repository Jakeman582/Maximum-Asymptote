import MaximumMathematics;

// Example: a classic two-way "multiplexer" switching network — (A & B) | (!A & C) — showing all
// three constructs at once: conjunction (series), disjunction (parallel), and negation (a barred
// switch label). When A is true, current can only flow through the top branch (needs B); when A is
// false, only through the bottom branch (needs C).

SwitchingNetwork sn = SwitchingNetwork("(A & B) | (!A & C)");

Image img = Image();
img.width(10);
img.height(10);
img.padding(0.5);
img.caption_title("Figure");
img.caption_text("$(A \wedge B) \vee (\bar{A} \wedge C)$, a two-way multiplexer.");
img.add(sn);

// Note: run `asy Examples/SwitchingNetwork/test_switching_network.asy` to render
