#!/usr/bin/env python3
"""Builds the documentation site into website/ (static HTML; menu on the left, outline on the right).

    python3 scripts/build-site.py

Languages: English at `/`, French at `/fr/`, Spanish at `/es/`.
Sources: docs/book/*.md (guide), docs/*.md (reference), docs/installation.md, pieces/ (generated reference),
ROADMAP.md, CHANGELOG.md. A translation of a page lives in docs/i18n/<lang>/<same path without the leading `docs/`>;
a page without translation falls back to English and shows a notice.
"""
import html, os, re, sys
import markdown

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SITE = os.path.join(ROOT, "website")
VERSION = re.search(r'version = "([^"]+)"', open(os.path.join(ROOT, "compiler/kite.toml")).read()).group(1)
BASE = "https://kite-lang.pages.dev"
LANGS = ["en", "fr", "es"]
LANG_NAMES = {"en": "English", "fr": "Français", "es": "Español"}

UI = {
    "en": {"docs": "Docs", "install": "Install", "roadmap": "Roadmap", "filter": "Filter pages…", "menu": "Menu",
           "toc": "On this page", "prev": "Previous", "next": "Next", "edit": "Edit this page on GitHub", "lang": "Language",
           "untranslated": "This page is not translated yet; the English version is shown.", "copy": "Copy", "copied": "Copied",
           "tagline": "Reads like Python, runs like C.", "updated": "Kite", "skip": "Skip to the content",
           "groups": {"start": "Getting started", "guide": "Guide", "reference": "Reference", "project": "Project"}},
    "fr": {"docs": "Documentation", "install": "Installation", "roadmap": "Feuille de route", "filter": "Filtrer les pages…", "menu": "Menu",
           "toc": "Sur cette page", "prev": "Précédent", "next": "Suivant", "edit": "Modifier cette page sur GitHub", "lang": "Langue",
           "untranslated": "Cette page n'est pas encore traduite ; la version anglaise est affichée.", "copy": "Copier", "copied": "Copié",
           "tagline": "Lisible comme Python, rapide comme C.", "updated": "Kite", "skip": "Aller au contenu",
           "groups": {"start": "Pour commencer", "guide": "Guide", "reference": "Référence", "project": "Projet"}},
    "es": {"docs": "Documentación", "install": "Instalación", "roadmap": "Hoja de ruta", "filter": "Filtrar páginas…", "menu": "Menú",
           "toc": "En esta página", "prev": "Anterior", "next": "Siguiente", "edit": "Editar esta página en GitHub", "lang": "Idioma",
           "untranslated": "Esta página aún no está traducida; se muestra la versión en inglés.", "copy": "Copiar", "copied": "Copiado",
           "tagline": "Se lee como Python, corre como C.", "updated": "Kite", "skip": "Saltar al contenido",
           "groups": {"start": "Primeros pasos", "guide": "Guía", "reference": "Referencia", "project": "Proyecto"}},
}

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

CALLOUTS = {"note": "note", "remarque": "note", "nota": "note", "tip": "tip", "astuce": "tip", "consejo": "tip",
            "warning": "warn", "attention": "warn", "aviso": "warn", "advertencia": "warn"}

def render_md(text):
    md = markdown.Markdown(extensions=["fenced_code", "tables", "toc", "sane_lists"], extension_configs={"toc": {"permalink": False, "toc_depth": "2-3"}})
    body = md.convert(text)
    def repl(m):
        lang = m.group(1) or ""
        code = html.unescape(m.group(2))
        label = lang if lang else "kite"
        return ('<div class="codeblock"><span class="lang">%s</span><button class="copy" type="button">copy</button>'
                '<pre class="code"><code>%s</code></pre></div>') % (label, highlight(code, lang))
    body = re.sub(r'<pre><code(?: class="language-(\w+)")?>(.*?)</code></pre>', repl, body, flags=re.S)
    def callout(m):
        kind = CALLOUTS.get(m.group(1).lower())
        return '<blockquote class="callout %s"><p><strong>%s%s</strong>' % (kind, m.group(1), m.group(2)) if kind else m.group(0)
    body = re.sub(r'<blockquote>\s*<p><strong>([A-Za-zéÉ]+)( ?:?)</strong>', callout, body)
    return body, md.toc_tokens

def read(path):
    return open(os.path.join(ROOT, path), encoding="utf-8").read()

# ---- reference generated from the registry (English only: names and signatures) --------------------
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
            has_pub = re.search(r'(?m)^pub (?:make|type|class|enum|const) ', src) is not None
            pre = r'pub ' if has_pub else r''
            funcs = re.findall(r'(?m)^((?:\s*//[^\n]*\n)*)' + pre + r'make (\w+)\(([^)]*)\)(?: -> ([^\n:]+))?:', src)
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
# (url, group, key, source path relative to the repository or callable, translatable)
PAGES = [
    ("/", "start", "intro", "docs/book/00-introduction.md", True),
    ("/installation/", "start", "installation", "docs/installation.md", True),
    ("/guide/first-project/", "guide", "first", "docs/book/01-first-project.md", True),
    ("/guide/variables/", "guide", "variables", "docs/book/02-variables.md", True),
    ("/guide/control-flow/", "guide", "control", "docs/book/03-control-flow.md", True),
    ("/guide/functions/", "guide", "functions", "docs/book/04-functions.md", True),
    ("/guide/collections/", "guide", "collections", "docs/book/05-collections.md", True),
    ("/guide/records/", "guide", "records", "docs/book/06-records.md", True),
    ("/guide/function-values/", "guide", "fnvalues", "docs/book/15-function-values.md", True),
    ("/guide/generics/", "guide", "generics", "docs/book/13-generics.md", True),
    ("/guide/errors/", "guide", "errors", "docs/book/16-errors.md", True),
    ("/guide/pieces/", "guide", "pieces", "docs/book/07-pieces.md", True),
    ("/guide/conditional/", "guide", "conditional", "docs/book/14-conditional.md", True),
    ("/guide/memory/", "guide", "memory", "docs/book/08-memory.md", True),
    ("/guide/style/", "guide", "style", "docs/book/09-style.md", True),
    ("/guide/cheatsheet/", "guide", "cheat", "docs/book/11-cheatsheet.md", True),
    ("/guide/troubleshooting/", "guide", "trouble", "docs/book/12-troubleshooting.md", True),
    ("/reference/language/", "reference", "language", "docs/language.md", True),
    ("/reference/builtins/", "reference", "builtins", "docs/builtins.md", True),
    ("/reference/std-pieces/", "reference", "stdpieces", pieces_reference, False),
    ("/reference/cli/", "reference", "cli", "docs/book/10-cli.md", True),
    ("/reference/pieces-registry/", "reference", "registry", "docs/pieces.md", True),
    ("/reference/targets/", "reference", "targets", "docs/targets.md", True),
    ("/reference/c-interop/", "reference", "cinterop", "docs/c-interop.md", True),
    ("/reference/memory/", "reference", "memmodel", "docs/memory.md", True),
    ("/reference/editors/", "reference", "editors", "docs/editors.md", True),
    ("/project/roadmap/", "project", "roadmap", "ROADMAP.md", False),
    ("/project/changelog/", "project", "changelog", "CHANGELOG.md", False),
    ("/project/architecture/", "project", "architecture", "docs/architecture.md", True),
    ("/project/bootstrap/", "project", "bootstrap", "docs/bootstrap.md", True),
]
TITLES = {
    "en": dict(intro="Introduction", installation="Installation", first="Your first project", variables="Variables and types",
               control="Control flow", functions="Functions and constants", collections="Collections", records="Records, classes and enums", generics="Generics", errors="Errors: Result, Option and ?", fnvalues="Function values and lambdas", conditional="Conditional compilation",
               pieces="Pieces (packages)", memory="Memory, pointers and threads", style="Writing readable Kite", cheat="Cheat sheet",
               trouble="Troubleshooting", language="Language reference", builtins="Built-in functions", stdpieces="Standard pieces",
               cli="The kite command", registry="Pieces and the registry", targets="Targets, OS and freestanding", cinterop="Calling C",
               memmodel="Memory model", editors="Editors", roadmap="Roadmap", changelog="Changelog", architecture="Architecture", bootstrap="Bootstrap"),
    "fr": dict(intro="Introduction", installation="Installation", first="Votre premier projet", variables="Variables et types",
               control="Structures de contrôle", functions="Fonctions et constantes", collections="Collections", records="Records, classes et enums", generics="Génériques", errors="Erreurs : Result, Option et ?", fnvalues="Valeurs de fonction et lambdas", conditional="Compilation conditionnelle",
               pieces="Pièces (paquets)", memory="Mémoire, pointeurs et threads", style="Écrire du Kite lisible", cheat="Aide-mémoire",
               trouble="Dépannage", language="Référence du langage", builtins="Fonctions intégrées", stdpieces="Pièces standard",
               cli="La commande kite", registry="Pièces et registre", targets="Cibles, OS et freestanding", cinterop="Appeler du C",
               memmodel="Modèle mémoire", editors="Éditeurs", roadmap="Feuille de route", changelog="Journal des modifications", architecture="Architecture", bootstrap="Bootstrap"),
    "es": dict(intro="Introducción", installation="Instalación", first="Tu primer proyecto", variables="Variables y tipos",
               control="Control de flujo", functions="Funciones y constantes", collections="Colecciones", records="Registros, clases y enums", generics="Genéricos", errors="Errores: Result, Option y ?", fnvalues="Valores de función y lambdas", conditional="Compilación condicional",
               pieces="Piezas (paquetes)", memory="Memoria, punteros e hilos", style="Escribir Kite legible", cheat="Hoja de referencia rápida",
               trouble="Solución de problemas", language="Referencia del lenguaje", builtins="Funciones integradas", stdpieces="Piezas estándar",
               cli="El comando kite", registry="Piezas y registro", targets="Destinos, SO y freestanding", cinterop="Llamar a C",
               memmodel="Modelo de memoria", editors="Editores", roadmap="Hoja de ruta", changelog="Registro de cambios", architecture="Arquitectura", bootstrap="Bootstrap"),
}

def i18n_path(lang, src):
    if lang == "en" or not isinstance(src, str) or not src.startswith("docs/"):
        return None
    p = os.path.join("docs", "i18n", lang, src[len("docs/"):])
    return p if os.path.exists(os.path.join(ROOT, p)) else None

def lang_prefix(lang): return "" if lang == "en" else "/" + lang

def localize_links(body, lang):
    pre = lang_prefix(lang)
    if pre:
        body = re.sub(r'href="(/(?:installation|guide|reference|project)/[^"]*)"', lambda m: 'href="%s%s"' % (pre, m.group(1)), body)
        body = body.replace('href="/"', 'href="%s/"' % pre)
    return re.sub(r'href="(?:\./)?docs/([\w\-]+)\.md"', r'href="https://github.com/kite-language/kite/blob/main/docs/\1.md"', body)

TEMPLATE = """<!doctype html>
<html lang="{lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title} — Kite</title>
<meta name="description" content="{desc}">
<link rel="icon" href="/kite-32.png">
<link rel="canonical" href="{canon}">
{alternates}
<link rel="stylesheet" href="/docs.css">
</head>
<body>
<a class="skip" href="#content">{skip}</a>
<header class="top">
  <button id="menu" aria-label="{menu}">☰</button>
  <a class="brand" href="{home}"><img src="/kite-64.png" alt="" width="28" height="28"> Kite</a>
  <span class="ver">v{version}</span>
  <nav><a href="{home}">{t_docs}</a><a href="{pre}/installation/">{t_install}</a><a href="{pre}/project/roadmap/">{t_roadmap}</a><a href="https://github.com/kite-language/kite">GitHub</a></nav>
  <div class="langs" aria-label="{t_lang}">{langs}</div>
</header>
<div class="layout">
<aside id="side"><input id="filter" type="search" placeholder="{filter}" aria-label="{filter}">
{menu_html}
</aside>
<main id="content">
<div class="crumbs">{crumbs}</div>
{notice}<article>
{body}
</article>
<footer class="pager">{prev}{next}</footer>
<p class="edit"><a href="{edit_url}">{t_edit}</a></p>
</main>
<nav class="toc" aria-label="{t_toc}">{toc}</nav>
</div>
<script>window.KITE_I18N = {{copy: "{t_copy}", copied: "{t_copied}"}};</script>
<script src="/docs.js"></script>
</body>
</html>
"""

def build_menu(lang, current):
    ui = UI[lang]; pre = lang_prefix(lang)
    out, last = [], None
    for url, group, key, src, tr in PAGES:
        if group != last:
            if last is not None: out.append("</ul></details>")
            out.append('<details class="grp" open><summary>%s</summary><ul>' % ui["groups"][group])
            last = group
        cls = ' class="cur" aria-current="page"' if url == current else ""
        out.append('<li><a%s href="%s%s">%s</a></li>' % (cls, pre, url, html.escape(TITLES[lang][key])))
    out.append("</ul></details>")
    return "\n".join(out)

def build_toc(tokens, lang):
    items = []
    for t in tokens:
        for h in [t] + t.get("children", []):
            pass
    def walk(ts, level):
        s = ""
        for t in ts:
            if t["level"] < 2: 
                s += walk(t.get("children", []), level); continue
            s += '<li class="l%d"><a href="#%s">%s</a></li>' % (t["level"], t["id"], html.escape(t["name"]))
            s += walk(t.get("children", []), level)
        return s
    inner = walk(tokens, 1)
    if not inner: return ""
    return '<h5>%s</h5><ul>%s</ul>' % (UI[lang]["toc"], inner)

def description(body):
    m = re.search(r"<p>(.*?)</p>", body, re.S)
    text = re.sub(r"<[^>]+>", "", m.group(1)) if m else "Kite"
    return html.escape(re.sub(r"\s+", " ", text)[:180], quote=True)

def write_page(lang, idx, body, toc_tokens, translated):
    url, group, key, src, tr = PAGES[idx]
    ui = UI[lang]; pre = lang_prefix(lang)
    title = TITLES[lang][key]
    prev = nxt = ""
    if idx > 0:
        u, g, k, s, t = PAGES[idx - 1]
        prev = '<a class="prev" href="%s%s"><small>%s</small>← %s</a>' % (pre, u, ui["prev"], html.escape(TITLES[lang][k]))
    if idx < len(PAGES) - 1:
        u, g, k, s, t = PAGES[idx + 1]
        nxt = '<a class="next" href="%s%s"><small>%s</small>%s →</a>' % (pre, u, ui["next"], html.escape(TITLES[lang][k]))
    alternates = "\n".join('<link rel="alternate" hreflang="%s" href="%s%s%s">' % (l, BASE, lang_prefix(l), url) for l in LANGS)
    alternates += '\n<link rel="alternate" hreflang="x-default" href="%s%s">' % (BASE, url)
    langs = "".join('<a%s href="%s%s" hreflang="%s" lang="%s">%s</a>' % (' class="on"' if l == lang else "", lang_prefix(l), url, l, l, l.upper()) for l in LANGS)
    notice = '<div class="callout note notice">%s</div>\n' % ui["untranslated"] if (tr and lang != "en" and not translated) else ""
    crumbs = "%s › %s" % (ui["groups"][group], html.escape(title))
    edit_src = src if isinstance(src, str) else "pieces"
    if translated and lang != "en": edit_src = i18n_path(lang, src)
    page = TEMPLATE.format(lang=lang, title=html.escape(title), desc=description(body), canon=BASE + pre + url, alternates=alternates,
                           skip=ui["skip"], menu=ui["menu"], home=pre + "/", version=VERSION, pre=pre, t_docs=ui["docs"], t_install=ui["install"],
                           t_roadmap=ui["roadmap"], t_lang=ui["lang"], langs=langs, filter=ui["filter"], menu_html=build_menu(lang, url),
                           crumbs=crumbs, notice=notice, body=body, prev=prev, next=nxt, t_edit=ui["edit"],
                           edit_url="https://github.com/kite-language/kite/blob/main/" + edit_src, t_toc=ui["toc"], toc=build_toc(toc_tokens, lang),
                           t_copy=ui["copy"], t_copied=ui["copied"])
    path = os.path.join(SITE, lang_prefix(lang).strip("/"), url.strip("/"), "index.html")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "w", encoding="utf-8").write(page)

def main():
    count = 0
    missing = {l: [] for l in LANGS if l != "en"}
    for lang in LANGS:
        for idx, (url, group, key, src, tr) in enumerate(PAGES):
            tpath = i18n_path(lang, src)
            if tpath: text = read(tpath)
            else:
                text = src() if callable(src) else read(src)
                if lang != "en" and tr: missing[lang].append(url)
            body, tokens = render_md(text)
            write_page(lang, idx, localize_links(body, lang), tokens, bool(tpath))
            count += 1
    urls = [BASE + lang_prefix(l) + u for l in LANGS for (u, g, k, s, t) in PAGES]
    open(os.path.join(SITE, "sitemap.xml"), "w").write('<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
        + "".join("<url><loc>%s</loc></url>\n" % u for u in urls) + "</urlset>\n")
    open(os.path.join(SITE, "_redirects"), "w").write("".join(
        "%s%s %s%s 302\n" % (p, a, p, b) for p in ("", "/fr", "/es") for (a, b) in (("/guide", "/guide/first-project/"), ("/guide/", "/guide/first-project/"), ("/reference", "/reference/language/"), ("/reference/", "/reference/language/")))
        + "/install /installation/ 301\n/install/ /installation/ 301\n/docs / 302\n/docs/ / 302\n")
    print("site built:", count, "pages (%d languages), version %s" % (len(LANGS), VERSION))
    for l, m in missing.items():
        print("  %s: %d page(s) use the English fallback%s" % (l, len(m), (": " + ", ".join(m)) if m else ""))

main()
