---
title: Output and viewing
nav_order: 7
---

# Output and viewing

The library does not override your output format. Choose one the standard Asymptote way:

```asy
settings.outformat = "svg";   // or "pdf", "eps", "png"
```

```bash
asy mydiagram.asy            # uses your configured format
asy -f svg mydiagram.asy     # force SVG
```

{: .note }
**Tip:** if you rasterize the SVG output to PNG to preview it, use a WebKit-based tool (e.g. `qlmanage` on macOS) or a browser. ImageMagick does not resolve the glyph references in Asymptote's SVG and will drop characters, making a correct figure look broken.
