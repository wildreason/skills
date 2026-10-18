/* tunnel kit v1 -- chart helpers and page blocks for tunnel templates.
   Source of truth: wildreason/skills formats/tunnel-a-base. Served at
   https://artifacts.wildreason.ai/kit/v1/kit.js and inlined by tunnel when it serves an
   HTML body. A block is <div data-vt="bars|waterfall|variance|line|spark|notes|gantt|log|board|lineitems">
   holding one <script type="application/json"> with its data; the kit draws it.
   Rules baked in: bars start at zero, direct labels (no legends), one accent.
   Keys: every item a block draws carries data-vt-key, one key per item in its
   block (an item drawn as several nodes carries it on each), made from the
   block's data alone -- "#"+id when the item has an id, else its
   index path in the data ("2", "1.0" for item 0 of row 1). So a comment on a
   drawn bar names the block (in the page source) and the item (by key), and
   the key survives an edit to the item's text. Reordering items without ids
   moves their keys. */
(function(){
const NS='http://www.w3.org/2000/svg';
const pct=(v,d=0)=>{const a=Math.abs(v).toFixed(d)+'%';return v<0?`(${a})`:a;};
const fmt=(v,d=0)=>{const a=Math.abs(v).toLocaleString('en-US',{maximumFractionDigits:d,minimumFractionDigits:d});return v<0?`(${a})`:a;};
function svg(w,h){const s=document.createElementNS(NS,'svg');s.setAttribute('viewBox',`0 0 ${w} ${h}`);s.setAttribute('role','img');return s;}
function el(tag,attrs,style,text){const e=document.createElementNS(NS,tag);for(const k in attrs)e.setAttribute(k,attrs[k]);if(style)e.setAttribute('style',style);if(text!=null)e.textContent=text;return e;}
const key=(x,i)=>x&&x.id!=null?'#'+x.id:String(i);
const G=k=>el('g',{'data-vt-key':k});
const T=(x,y,t,o={})=>el('text',{x,y,'text-anchor':o.a||'start','dominant-baseline':o.b||'middle'},`font:${o.w||400} ${o.s||11}px var(--mono);fill:var(${o.c||'--ink'})`,t);

/* Horizontal bars, one highlighted. data:[{label,value,hi}] */
function bars(host,data,{unit='',d=0}={}){
  const W=600,rowH=30,L=150,R=60,H=data.length*rowH+10,s=svg(W,H),max=Math.max(...data.map(x=>Math.abs(x.value)));
  data.forEach((x,i)=>{const y=5+i*rowH,w=(W-L-R)*Math.abs(x.value)/max,g=G(key(x,i));
    g.append(T(L-10,y+rowH/2,x.label,{a:'end',s:12,c:x.hi?'--ink':'--mute',w:x.hi?600:400}));
    g.append(el('rect',{x:L,y:y+6,width:Math.max(1,w),height:rowH-12,rx:2},`fill:var(${x.hi?'--cu':'--sand'})`));
    g.append(T(L+w+6,y+rowH/2,fmt(x.value,d)+unit,{s:11.5,w:x.hi?600:400}));s.append(g);});
  host.append(s);
}

/* Waterfall bridge. data:[{label,value,total?}] — totals drawn from zero, steps float. Unfavourable steps use the accent (costs:true makes increases unfavourable). */
function waterfall(host,data,{unit='',d=0,costs=false}={}){
  const W=640,H=300,T0=24,B=48,L=10,R=10,n=data.length,bw=(W-L-R)/n;let run=0,lo=0,hi=0;
  const pts=data.map(x=>{if(x.total){const r={a:0,b:x.value};run=x.value;return r;}const a=run;run+=x.value;return{a,b:run};});
  pts.forEach(p=>{lo=Math.min(lo,p.a,p.b);hi=Math.max(hi,p.a,p.b);});
  const y=v=>T0+(H-T0-B)*(hi-v)/(hi-lo||1),s=svg(W,H);
  s.append(el('line',{x1:L,x2:W-R,y1:y(0),y2:y(0)},'stroke:var(--sand);stroke-width:1.5'));
  data.forEach((x,i)=>{const p=pts[i],x0=L+i*bw+bw*.18,w=bw*.64,top=y(Math.max(p.a,p.b)),hgt=Math.max(1,Math.abs(y(p.a)-y(p.b)));
    const bad=!x.total&&(costs?x.value>0:x.value<0),col=x.total?'--ink':(bad?'--cu':'--sand'),g=G(key(x,i));
    g.append(el('rect',{x:x0,y:top,width:w,height:hgt,rx:2},`fill:var(${col})`));
    if(i<n-1){const ny=y(pts[i].b);g.append(el('line',{x1:x0+w,x2:x0+bw,y1:ny,y2:ny},'stroke:var(--mute);stroke-dasharray:2 2'));}
    g.append(T(x0+w/2,top-9,(x.total?'':x.value>0?'+':'')+fmt(x.value,d)+unit,{a:'middle',s:11,w:x.total||bad?600:400,c:bad?'--cu':'--ink'}));
    g.append(T(x0+w/2,H-B+16,x.label,{a:'middle',s:10.5,c:'--mute'}));s.append(g);});
  host.append(s);
}

/* Variance vs plan. data:[{label,actual,plan}] — favourable = sand, unfavourable = accent. costs:true means over plan is bad. */
function variance(host,data,{unit='',d=0,costs=true}={}){
  const W=600,rowH=30,L=150,H=data.length*rowH+30,mid=L+(W-L-70)/2,s=svg(W,H);
  const vs=data.map(x=>x.actual-x.plan),max=Math.max(...vs.map(Math.abs))||1,half=(W-L-70)/2;
  s.append(el('line',{x1:mid,x2:mid,y1:4,y2:H-20},'stroke:var(--mute);stroke-width:1'));
  s.append(T(mid,H-8,'on plan',{a:'middle',s:10,c:'--mute'}));
  data.forEach((x,i)=>{const v=vs[i],bad=costs?v>0:v<0,w=half*Math.abs(v)/max,yy=4+i*rowH,g=G(key(x,i));
    g.append(T(L-10,yy+rowH/2,x.label,{a:'end',s:12,c:bad?'--ink':'--mute',w:bad?600:400}));
    g.append(el('rect',{x:v<0?mid-w:mid,y:yy+7,width:Math.max(1,w),height:rowH-14,rx:2},`fill:var(${bad?'--cu':'--sand'})`));
    g.append(T(W-4,yy+rowH/2,(v>0?'+':'')+fmt(v,d)+unit,{a:'end',s:11,w:bad?600:400,c:bad?'--cu':'--ink'}));s.append(g);});
  host.append(s);
}

/* Line: actual (solid) + optional plan/forecast (dashed) + optional threshold. Direct end labels. */
function line(host,{labels,series,threshold,unit='',d=0,annotate}){
  const W=640,H=280,L=46,R=90,T0=20,B=34,s=svg(W,H);
  const all=series.flatMap(x=>x.values.filter(v=>v!=null)).concat(threshold?[threshold.value]:[]);
  const nice=v=>{const p=Math.pow(10,Math.floor(Math.log10(v||1))),m=v/p;return (m<=1?1:m<=2?2:m<=2.5?2.5:m<=5?5:10)*p;};const lo=Math.min(0,...all),hi=nice(Math.max(...all)*1.05),n=labels.length;
  const X=i=>L+(W-L-R)*i/(n-1),Y=v=>T0+(H-T0-B)*(hi-v)/(hi-lo||1);
  [lo,(lo+hi)/2,hi].forEach(v=>{s.append(el('line',{x1:L,x2:W-R,y1:Y(v),y2:Y(v)},'stroke:var(--line)'));s.append(T(L-6,Y(v),fmt(v,d),{a:'end',s:10,c:'--mute'}));});
  labels.forEach((l,i)=>{if(i%Math.ceil(n/8)===0||i===n-1)s.append(T(X(i),H-B+16,l,{a:'middle',s:10,c:'--mute'}));});
  if(threshold){s.append(el('line',{x1:L,x2:W-R,y1:Y(threshold.value),y2:Y(threshold.value)},'stroke:var(--ink);stroke-dasharray:4 3'));s.append(T(W-R+6,Y(threshold.value),threshold.label,{s:10.5,c:'--ink'}));}
  series.forEach((x,si)=>{let p='',last=null;x.values.forEach((v,i)=>{if(v==null)return;p+=(p?'L':'M')+X(i)+' '+Y(v);last=i;});
    const col=x.hi?'--cu':x.dashed?'--org':'--mute',g=G(key(x,si));
    g.append(el('path',{d:p,fill:'none'},`stroke:var(${col});stroke-width:${x.hi?2.5:1.8};${x.dashed?'stroke-dasharray:5 4':''}`));
    if(last!=null){g.append(el('circle',{cx:X(last),cy:Y(x.values[last]),r:3.5},`fill:var(${col})`));g.append(T(X(last)+8,Y(x.values[last]),x.name,{s:11,w:x.hi?600:400,c:col}));}s.append(g);});
  if(annotate){const{i,text}=annotate,v=series[0].values[i];s.append(el('line',{x1:X(i),x2:X(i),y1:Y(v)-8,y2:T0},'stroke:var(--cu)'));s.append(T(X(i)+4,T0+2,text,{s:10.5,w:600,c:'--cu',b:'hanging'}));}
  host.append(s);
}

/* Sparkline for tables and KPI tiles. */
function spark(host,values,{hi=false}={}){
  const W=90,H=24,s=svg(W,H),lo=Math.min(...values),mx=Math.max(...values),n=values.length;
  const X=i=>2+(W-6)*i/(n-1),Y=v=>3+(H-6)*(mx-v)/((mx-lo)||1);
  s.append(el('path',{d:values.map((v,i)=>(i?'L':'M')+X(i)+' '+Y(v)).join(''),fill:'none'},`stroke:var(${hi?'--cu':'--mute'});stroke-width:1.6`));
  s.append(el('circle',{cx:X(n-1),cy:Y(values[n-1]),r:2.5},`fill:var(${hi?'--cu':'--ink'})`));
  s.style.width='90px';s.style.height='24px';host.append(s);
}

/* ---- page blocks: a div with data-vt="KIND" holding one JSON script with its data ---- */
const esc=v=>String(v==null?'':v).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
function notes(host,{notes=[]}){
  const tags=['all',...new Set(notes.map(n=>n.tag))];let cur='all';
  const F=document.createElement('div');F.className='filters';F.setAttribute('role','group');F.setAttribute('aria-label','Filter by tag');
  const G=document.createElement('div');G.className='tiles';host.append(F,G);
  function draw(){
    F.innerHTML=tags.map(t=>`<button type="button" aria-pressed="${t===cur}" data-t="${esc(t)}">${esc(t)}${t==='all'?'':' · '+notes.filter(n=>n.tag===t).length}</button>`).join('');
    const list=notes.filter(n=>cur==='all'||n.tag===cur).sort((a,b)=>(b.pin?1:0)-(a.pin?1:0));
    G.innerHTML=list.map(n=>`<article class="tile${n.pin?' pin':''}" data-vt-key="${esc(key(n,notes.indexOf(n)))}"><div class="meta"><span class="chip ${n.pin?'a':'o'}">${esc(n.tag)}</span>${n.pin?'<span class="pinmark">pinned</span>':''}</div><h3>${esc(n.title)}</h3><p>${esc(n.body)}</p>${n.quote?`<p class="q">“${esc(n.quote)}”</p>`:''}<div class="meta"><span>${esc(n.who)}</span><span>${esc(n.date)}</span></div></article>`).join('');
  }
  F.addEventListener('click',e=>{const b=e.target.closest('button');if(!b)return;cur=b.dataset.t;draw();});draw();
}
/* weeks: column labels; today: fractional week index; rows: [{name,st:p|h|f|n,items:[{from,to,label,kind:p|a}|{at,label}]}] */
function gantt(host,{weeks=[],today,rows=[]}){
  const g=document.createElement('div');g.className='gantt';g.style.gridTemplateColumns=`150px repeat(${weeks.length},1fr)`;
  let h='<div></div>'+weeks.map(w=>`<div class="wk">${esc(w)}</div>`).join('');
  rows.forEach((r,i)=>{const row=i+2,rk=key(r,i);h+=`<div class="row" data-vt-key="${esc(rk)}" style="grid-row:${row}"><span class="dot ${esc(r.st||'n')}"></span>${esc(r.name)}</div>`;
    (r.items||[]).forEach((it,j)=>{const ik=esc(it.id!=null?'#'+it.id:rk+'.'+j);if(it.at!=null){const c=Math.floor(it.at)+2;h+=`<div class="ms" data-vt-key="${ik}" title="${esc(it.label)}" style="grid-row:${row};grid-column:${c}"></div><div data-vt-key="${ik}" style="grid-row:${row};grid-column:${c};align-self:end;justify-self:center;font:500 10.5px var(--mono);transform:translateY(14px)">${esc(it.label)}</div>`;}
      else h+=`<div class="bar ${esc(it.kind||'')}" data-vt-key="${ik}" style="grid-row:${row};grid-column:${Math.floor(it.from)+2}/${Math.ceil(it.to)+2}">${esc(it.label)}</div>`;});});
  g.innerHTML=h;host.className=(host.className+' tw').trim();host.append(g);
  if(today!=null){const t=document.createElement('div');t.className='today';t.innerHTML='<span>today</span>';g.append(t);
    const place=()=>{const first=g.querySelector('.wk');if(!first)return;const w=first.getBoundingClientRect().width;t.style.left=(first.getBoundingClientRect().left-g.getBoundingClientRect().left+w*today)+'px';};
    requestAnimationFrame(place);new ResizeObserver(place).observe(g);}
}
/* entries: [[time,text,chip,kind n|p|a]] newest first */
function log(host,{entries=[]}){
  const u=document.createElement('ul');u.className='log';
  u.innerHTML=entries.map(([t,x,c,k],i)=>`<li data-vt-key="${i}"><span class="t">${esc(t)}</span><span>${esc(x)}</span><span class="chip ${esc(k||'n')}">${esc(c)}</span></li>`).join('');host.append(u);
}
/* clusters: [{name,items:[{id,title,body,votes,fav,drop}]}]; links: [[fromId,toId]] */
function board(host,{clusters=[],links=[]}){
  host.classList.add('boardwrap');
  const S=document.createElementNS(NS,'svg');S.setAttribute('class','links');S.setAttribute('aria-hidden','true');
  const C=document.createElement('div');C.className='clusters';C.style.gridTemplateColumns=`repeat(${Math.min(4,clusters.length||1)},1fr)`;
  C.innerHTML=clusters.map((c,ci)=>`<div class="cluster" data-vt-key="${esc(key(c,ci))}"><div class="sticky">${esc(c.name)}</div>${(c.items||[]).map((o,oi)=>`<article class="opt${o.fav?' fav':''}${o.drop?' drop':''}" data-id="${esc(o.id)}" data-vt-key="${esc(o.id!=null?'#'+o.id:key(c,ci)+'.'+oi)}"><h3>${esc(o.title)}</h3><p>${esc(o.body)}</p><div class="votes">${'<i></i>'.repeat(Math.max(0,Math.min(20,o.votes|0)))}<span>${o.votes|0}</span>${o.fav?'<span class="mark">· favourite</span>':o.drop?'<span class="mark">· dropped</span>':''}</div></article>`).join('')}</div>`).join('');
  host.append(S,C);
  const by=id=>C.querySelector(`[data-id="${CSS.escape(String(id))}"]`);
  function draw(){const r=host.getBoundingClientRect();S.innerHTML='<defs><marker id="vt-ah" viewBox="0 0 8 8" refX="7" refY="4" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L8 4L0 8z" style="fill:var(--cu)"/></marker></defs>';
    links.forEach(([f,t])=>{const ea=by(f),eb=by(t);if(!ea||!eb)return;const a=ea.getBoundingClientRect(),b=eb.getBoundingClientRect();
      const x1=a.right-r.left,y1=a.top+a.height/2-r.top,x2=b.left-r.left,y2=b.top+b.height/2-r.top,stacked=x2<x1;
      const d=stacked?`M${a.left+a.width/2-r.left} ${a.bottom-r.top} C ${a.left+a.width/2-r.left} ${a.bottom-r.top+30}, ${b.left+b.width/2-r.left} ${b.top-r.top-30}, ${b.left+b.width/2-r.left} ${b.top-r.top}`:`M${x1} ${y1} C ${x1+30} ${y1}, ${x2-30} ${y2}, ${x2} ${y2}`;
      S.insertAdjacentHTML('beforeend',`<path d="${d}" fill="none" style="stroke:var(--cu);stroke-width:1.6;stroke-dasharray:5 4" marker-end="url(#vt-ah)"/>`);});}
  new ResizeObserver(draw).observe(host);draw();
}
/* lines: [{label,plan,actual,trend:[...]}]; costs:true means over plan is unfavourable */
function lineitems(host,{lines=[],costs=true,unit=''}){
  const w=document.createElement('div');w.className='tw';
  w.innerHTML=`<table><thead><tr><th>Line</th><th class="num">Plan</th><th class="num">Actual</th><th class="num">Variance</th><th class="num">%</th><th>Trend</th></tr></thead><tbody>${lines.map(l=>{const v=l.actual-l.plan,p=l.plan?v/l.plan*100:0,bad=costs?v>0:v<0;return`<tr data-vt-key="${esc(key(l,lines.indexOf(l)))}"><td>${esc(l.label)}</td><td class="num">${fmt(l.plan)}${esc(unit)}</td><td class="num">${fmt(l.actual)}${esc(unit)}</td><td class="num ${bad?'a':''}">${fmt(v)}</td><td class="num ${bad?'a':''}">${pct(p,0)}</td><td class="spk-cell" data-i="${lines.indexOf(l)}"></td></tr>`;}).join('')}</tbody></table>`;
  host.append(w);
  w.querySelectorAll('.spk-cell').forEach(td=>{const l=lines[+td.dataset.i];if(l.trend&&l.trend.length>1){const v=l.actual-l.plan;spark(td,l.trend,{hi:costs?v>0:v<0});}});
}
const KINDS={bars:(h,o)=>bars(h,o.data||[],o),waterfall:(h,o)=>waterfall(h,o.data||[],o),variance:(h,o)=>variance(h,o.data||[],o),line:(h,o)=>line(h,o),
  spark:(h,o)=>spark(h,o.values||[],o),notes,gantt,log,board,lineitems};
function render(root){(root||document).querySelectorAll('[data-vt]').forEach(h=>{if(h.dataset.vtDone)return;h.dataset.vtDone='1';
  const k=KINDS[h.dataset.vt],j=h.querySelector('script[type="application/json"]');
  if(!k){h.insertAdjacentHTML('beforeend',`<p class="note">unknown block: ${esc(h.dataset.vt)}</p>`);return;}
  let o={};try{o=j?JSON.parse(j.textContent):{};}catch(e){h.insertAdjacentHTML('beforeend','<p class="note">this block\'s data is not valid JSON</p>');return;}
  try{k(h,o);}catch(e){h.insertAdjacentHTML('beforeend','<p class="note">this block could not be drawn</p>');}});}
window.VT={bars,waterfall,variance,line,spark,fmt,pct,notes,gantt,log,board,lineitems,render};
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',()=>render());else render();
})();
