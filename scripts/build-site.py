#!/usr/bin/env python3
"""Builds the documentation site into website/ (static HTML, Rust-book style: menu on the left).

    python3 scripts/build-site.py

The home page `/` is the documentation; the install page lives at `/installation/`.
Sources: docs/book/*.md (the guide), docs/*.md (reference), pieces/ (generated reference), ROADMAP.md, CHANGELOG.md.
"""
import html, os, re, shutil, sys, glob
import markdown

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SITE = os.path.join(ROOT, "website")
VERSION = re.search(r'version = "([^"]+)"', open(os.path.join(ROOT, "compiler/kite.toml")).read()).group(1)

KEYWORDS = set("make class type enum use extern async await return if orif else while until infinit for in to break continue try failed finally match case const and or not true false null thread alloc alloc_n free".split())
TYPES = set("int float bool string ptr".split())

def highlight(code, lang):
    if lang not in ("", "kite", "ki"):
        return html.escape(code)
    out = []
    pat = re.compile(r'(//[^\n]*)|(f?"(?:[^"\\\n]|\\.)*")|(\b\d+(?:\.\d+)?\b)|([A-Za-z_]\w*)|(\s+|.)', re.S)
    for m in pat.finditer(code):
        com, st, num, word, other = m.groups()
        if com: out.append('<span class="c">%s</span>' % html.escape(com))
        elif st: out.append('<span class="s">%s</span>' % html.escape(st))
        elif num: out.append('<span class="n">%s</span>' % num)
        elif word:
            if word in KEYWORDS: out.append('<span class="k">%s</span>' % word)
            elif word in TYPES: out.append('<span class="t">%s</span>' % word)
            else: out.append(html.escape(word))
        else: out.append(html.escape(other))
    return "".join(out)

def render_md(text):
    md = markdown.Markdown(extensions=["fenced_code", "tables", "toc", "sane_lists"], extension_configs={"toc": {"permalink": False}})
    body = md.convert(text)
    def repl(m):
        lang = m.group(1) or ""
        code = html.unescape(m.group(2))
        return '<pre class="code"><code>%s</code></pre>' % highlight(code, lang)
    body = re.sub(r'<pre><code(?: class="language-(\w+)")?>(.*?)</code></pre>', repl, body, flags=re.S)
    return body, md.toc_tokens

def read(path):
    return open(os.path.join(ROOT, path), encoding="utf-8").read()

# ---- reference generated from the registry --------------------------------------------------------
def pieces_reference():
    out = ["# Standard pieces", "", "Generated from `pieces/` (run `python3 scripts/build-site.py`). Import a default piece with `use std.<name>` "
           "and call it as `<name>.function(...)`; community pieces are declared in `[dependencies]` and imported by name.", ""]
    for tier, title in (("std", "Default pieces"), ("community", "Community pieces")):
        base = os.path.join(ROOT, "pieces", tier)
        out += ["## " + title, ""]
        for name in sorted(os.listdir(base)):
            pdir = os.path.join(base, name)
            if not os.path.isdir(pdir): continue
            vers = sorted(os.listdir(pdir))
            if not vers: continue
            v = vers[-1]
            toml = open(os.path.join(pdir, v, "kite.toml")).read()
            desc = re.search(r'description = "(.*)"', toml).group(1)
            src = open(os.path.join(pdir, v, "src", "lib.ki")).read()
            use = ("use std." + name) if tier == "std" else ("use " + name)
            out += ["### `%s`" % name, "", "%s  \n`%s` · version %s" % (desc, use, v), ""]
            funcs = re.findall(r'(?m)^((?:\s*//[^\n]*\n)*)make (\w+)\(([^)]*)\)(?: -> ([^\n:]+))?:', src)
            if funcs:
                out.append("| function | description |")
                out.append("|----------|-------------|")
                for comment, fname, params, ret in funcs:
                    doc = " ".join(l.strip()[2:].strip() for l in comment.strip().split("\n") if l.strip().startswith("//"))
                    sig = "%s(%s)%s" % (fname, params, (" -> " + ret.strip()) if ret else "")
                    out.append("| `%s` | %s |" % (sig.replace("|", "\\|"), doc.replace("|", "\\|")))
                out.append("")
    return "\n".join(out)

# ---- site structure -----------------------------------------------------------------------------
# (url, title, group, markdown source or callable)
PAGES = [
    ("/", "Introduction", "Getting started", lambda: read("docs/book/00-introduction.md")),
    ("/installation/", "Installation", "Getting started", None),   # the install page (hand-written)
    ("/guide/first-project/", "Your first project", "Guide", lambda: read("docs/book/01-first-project.md")),
    ("/guide/variables/", "Variables and types", "Guide", lambda: read("docs/book/02-variables.md")),
    ("/guide/control-flow/", "Control flow", "Guide", lambda: read("docs/book/03-control-flow.md")),
    ("/guide/functions/", "Functions and constants", "Guide", lambda: read("docs/book/04-functions.md")),
    ("/guide/collections/", "Collections", "Guide", lambda: read("docs/book/05-collections.md")),
    ("/guide/records/", "Records, classes and enums", "Guide", lambda: read("docs/book/06-records.md")),
    ("/guide/pieces/", "Pieces (packages)", "Guide", lambda: read("docs/book/07-pieces.md")),
    ("/guide/memory/", "Memory, pointers and threads", "Guide", lambda: read("docs/book/08-memory.md")),
    ("/guide/style/", "Writing readable Kite", "Guide", lambda: read("docs/book/09-style.md")),
    ("/reference/language/", "Language reference", "Reference", lambda: read("docs/language.md")),
    ("/reference/builtins/", "Built-in functions", "Reference", lambda: read("docs/builtins.md")),
    ("/reference/std-pieces/", "Standard pieces", "Reference", pieces_reference),
    ("/reference/cli/", "The kite command", "Reference", lambda: read("docs/book/10-cli.md")),
    ("/reference/pieces-registry/", "Pieces and the registry", "Reference", lambda: read("docs/pieces.md")),
    ("/reference/targets/", "Targets, OS and freestanding", "Reference", lambda: read("docs/targets.md")),
    ("/reference/c-interop/", "Calling C", "Reference", lambda: read("docs/c-interop.md")),
    ("/reference/memory/", "Memory model", "Reference", lambda: read("docs/memory.md")),
    ("/reference/editors/", "Editors", "Reference", lambda: read("docs/editors.md")),
    ("/project/roadmap/", "Roadmap", "Project", lambda: read("ROADMAP.md")),
    ("/project/changelog/", "Changelog", "Project", lambda: read("CHANGELOG.md")),
    ("/project/architecture/", "Architecture", "Project", lambda: read("docs/architecture.md")),
    ("/project/bootstrap/", "Bootstrap", "Project", lambda: read("docs/bootstrap.md")),
]

def fix_links(body):
    # repository-relative links such as docs/foo.md -> GitHub
    return re.sub(r'href="(?:\./)?docs/([\w\-]+)\.md"', r'href="https://github.com/kite-language/kite/blob/main/docs/\1.md"', body)

TEMPLATE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title} — Kite</title>
<link rel="icon" href="/kite-32.png">
<link rel="stylesheet" href="/docs.css">
</head>
<body>
<header class="top">
  <button id="menu" aria-label="Menu">☰</button>
  <a class="brand" href="/"><img src="/kite-64.png" alt="" width="28" height="28"> Kite</a>
  <span class="ver">v{version}</span>
  <nav><a href="/">Docs</a><a href="/installation/">Install</a><a href="/project/roadmap/">Roadmap</a><a href="https://github.com/kite-language/kite">GitHub</a></nav>
</header>
<div class="layout">
<aside id="side"><input id="filter" type="search" placeholder="Filter pages…" aria-label="Filter pages">
{menu}
</aside>
<main>
<article>
{body}
</article>
<footer class="pager">{prev}{next}</footer>
</main>
</div>
<script src="/docs.js"></script>
</body>
</html>
"""

def build_menu(current):
    groups = []
    for url, title, group, _ in PAGES:
        if not groups or groups[-1][0] != group: groups.append((group, []))
        groups[-1][1].append((url, title))
    out = []
    for g, items in groups:
        out.append('<h4>%s</h4><ul>' % g)
        for url, title in items:
            cls = ' class="cur"' if url == current else ''
            out.append('<li><a%s href="%s">%s</a></li>' % (cls, url, html.escape(title)))
        out.append('</ul>')
    return "\n".join(out)

def write_page(url, title, body, idx):
    prev = nxt = ""
    if idx > 0: prev = '<a class="prev" href="%s">← %s</a>' % (PAGES[idx-1][0], html.escape(PAGES[idx-1][1]))
    if idx < len(PAGES)-1: nxt = '<a class="next" href="%s">%s →</a>' % (PAGES[idx+1][0], html.escape(PAGES[idx+1][1]))
    page = TEMPLATE.format(title=html.escape(title), version=VERSION, menu=build_menu(url), body=body, prev=prev, next=nxt)
    path = os.path.join(SITE, url.strip("/"), "index.html") if url != "/" else os.path.join(SITE, "index.html")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "w", encoding="utf-8").write(page)

def main():
    # keep the install page: it was website/index.html before the docs took over `/`
    inst = os.path.join(SITE, "installation", "index.html")
    old = os.path.join(SITE, "index.html")
    if os.path.exists(old) and "install.sh" in open(old, encoding="utf-8").read() and "docs.css" not in open(old, encoding="utf-8").read():
        os.makedirs(os.path.dirname(inst), exist_ok=True)
        shutil.copy(old, inst)
    for idx, (url, title, group, src) in enumerate(PAGES):
        if src is None: continue
        body, _ = render_md(src())
        write_page(url, title, fix_links(body), idx)
    # the install page gets the docs link in its own header
    if os.path.exists(inst):
        t = open(inst, encoding="utf-8").read()
        if 'href="/"' not in t.split("</header>")[0]:
            t = t.replace("</header>", '<p class="docs-link"><a href="/">Read the documentation →</a></p></header>', 1)
        t = t.replace("v0.4.4", "v" + VERSION).replace("v0.4.3", "v" + VERSION).replace("v0.4.2", "v" + VERSION)
        open(inst, "w", encoding="utf-8").write(t)
    open(os.path.join(SITE, "_redirects"), "w").write("/install /installation/ 301\n/install/ /installation/ 301\n/docs / 302\n/docs/ / 302\n/guide /guide/first-project/ 302\n/guide/ /guide/first-project/ 302\n/reference /reference/language/ 302\n/reference/ /reference/language/ 302\n")
    print("site built:", len(PAGES), "pages, version", VERSION)

main()
