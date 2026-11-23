// menu toggle, sidebar filter, copy buttons, outline highlighting, heading anchors
const $ = (s, r = document) => r.querySelector(s), $$ = (s, r = document) => [...r.querySelectorAll(s)];
$('#menu')?.addEventListener('click', () => $('#side').classList.toggle('open'));

$('#filter')?.addEventListener('input', e => {
  const q = e.target.value.trim().toLowerCase();
  $$('#side li').forEach(li => { li.style.display = !q || li.textContent.toLowerCase().includes(q) ? '' : 'none'; });
  $$('#side .grp').forEach(g => {
    const any = $$('li', g).some(li => li.style.display !== 'none');
    g.style.display = any ? '' : 'none';
    if (q && any) g.open = true;
  });
});

const i18n = window.KITE_I18N || { copy: 'Copy', copied: 'Copied' };
$$('.codeblock .copy').forEach(btn => {
  btn.textContent = i18n.copy;
  btn.addEventListener('click', async () => {
    const text = $('code', btn.parentElement).innerText;
    try { await navigator.clipboard.writeText(text); } catch (_) {
      const ta = document.createElement('textarea'); ta.value = text; document.body.appendChild(ta); ta.select(); document.execCommand('copy'); ta.remove();
    }
    btn.textContent = i18n.copied; setTimeout(() => btn.textContent = i18n.copy, 1400);
  });
});

$$('article h2[id], article h3[id]').forEach(h => {
  const a = document.createElement('a'); a.href = '#' + h.id; a.textContent = ' #'; a.style.cssText = 'opacity:.0;font-weight:400;font-size:.8em';
  h.appendChild(a); h.addEventListener('mouseenter', () => a.style.opacity = .5); h.addEventListener('mouseleave', () => a.style.opacity = 0);
});

const links = $$('.toc a');
if (links.length && 'IntersectionObserver' in window) {
  const byId = new Map(links.map(a => [a.getAttribute('href').slice(1), a]));
  const io = new IntersectionObserver(es => es.forEach(en => {
    if (en.isIntersecting) { links.forEach(a => a.classList.remove('active')); byId.get(en.target.id)?.classList.add('active'); }
  }), { rootMargin: '-70px 0px -70% 0px' });
  $$('article h2[id], article h3[id]').forEach(h => io.observe(h));
}
