---
title: Installation
nav_order: 2
---

# Installation
{: .no_toc }

Clone the repository anywhere you like:

```bash
git clone https://github.com/Jakeman582/Maximum-Asymptote.git ~/.asy/Maximum-Asymptote
```

Asymptote doesn't search subfolders of `~/.asy`, so point your config file (`~/.asy/config.asy`) at the clone:

```asy
dir += "/absolute/path/to/Maximum-Asymptote";
```

Then import it in any `.asy` file:

```asy
import MaximumMathematics;
```

Update anytime with `git pull` — there is no separate build or install step.

{: .note }
**Requirements:** Asymptote 2.70+ and a LaTeX installation (used for mathematical notation).
