////////////////////////////////////////////////////////////////////////////////////////////////////
// File: AxisTicks.asy
//
// Description:
// Compute "nice" axis tick spacing and positions (1/2/5 multiples of a power of ten), shared by
// every plot-style visualization that draws its own axes.
////////////////////////////////////////////////////////////////////////////////////////////////////

// Helper: compute a "nice" tick spacing using 1,2,5 multiples
real niceNumber(real range) {
    if (range <= 0) return 0;
    real exponent = floor(log(range) / log(10));
    int e = (int)exponent;
    real pow10 = 1;
    if (e >= 0) {
        for (int i = 0; i < e; ++i) pow10 = pow10 * 10;
    } else {
        for (int i = 0; i < -e; ++i) pow10 = pow10 / 10;
    }
    real f = range / pow10;
    real nf;
    if (f < 1.5) nf = 1;
    else if (f < 3) nf = 2;
    else if (f < 7) nf = 5;
    else nf = 10;
    return nf * pow10;
}

// Compute tick positions between lo and hi with target ~n ticks
real[] compute_ticks(real lo, real hi, int n) {
    real[] ticks = new real[];
    if (hi <= lo) return ticks;
    real range = hi - lo;
    real rawStep = range / max(1, n - 1);
    real step = niceNumber(rawStep);
    if (step == 0) return ticks;
    real first = ceil(lo / step) * step;
    for (real t = first; t <= hi + 1e-12; t += step) {
        ticks.push(t);
        // safety: break if too many
        if (ticks.length > n * 4) break;
    }
    return ticks;
}
