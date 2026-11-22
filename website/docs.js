// menu toggle on small screens and the sidebar page filter
document.getElementById('menu')?.addEventListener('click', () => document.getElementById('side').classList.toggle('open'));
document.getElementById('filter')?.addEventListener('input', e => {
  const q = e.target.value.trim().toLowerCase();
  document.querySelectorAll('#side li').forEach(li => { li.style.display = !q || li.textContent.toLowerCase().includes(q) ? '' : 'none'; });
  document.querySelectorAll('#side h4').forEach(h => { let n = h.nextElementSibling, any = false; n.querySelectorAll('li').forEach(li => { if (li.style.display !== 'none') any = true; }); h.style.display = any ? '' : 'none'; n.style.display = any ? '' : 'none'; });
});
