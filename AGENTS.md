## Cursor Cloud specific instructions

This is a GitHub Pages static site repository (`*.github.io`). It contains only static HTML files (currently a single Yandex Webmaster domain verification file).

### Running locally

Serve the site with Python's built-in HTTP server:

```
python3 -m http.server 8080
```

Then open `http://localhost:8080/` in a browser.

### Notes

- There is no build step, no package manager, no dependencies, no tests, and no linter.
- Changes pushed to `main` are automatically deployed via GitHub Pages.
