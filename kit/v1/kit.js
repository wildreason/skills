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
const T=(x,y,t,o={})=>el('text',{x,y,'text-anchor':o.a||'start','dominant-baseline':o.b||'middle'},`font:${o.w||400} ${o.s||11}px var(--mono);fill:var(${o.c||'--ink'})${o.halo?';paint-order:stroke;stroke:var(--bg);stroke-width:4px;stroke-linejoin:round':''}`,t);

/* Charts draw at the host's real width (1 SVG unit = 1 CSS px, so text is its true size at any
   width) and redraw when that width changes. Labels are measured and wrapped, never clipped. */
const MONO=()=>getComputedStyle(document.documentElement).getPropertyValue('--mono').trim()||'monospace';
let CX;const tw=(t,s,w=400)=>{CX=CX||document.createElement('canvas').getContext('2d');CX.font=`${w} ${s}px ${MONO()}`;return CX.measureText(String(t)).width;};
function wrap(t,max,s,w=400,lines=3){const out=[];let cur='';
  const push=x=>{out.push(x);};
  String(t).split(/\s+/).filter(Boolean).forEach(word=>{
    while(tw(word,s,w)>max&&word.length>1){if(cur){push(cur);cur='';}let k=word.length;while(k>1&&tw(word.slice(0,k),s,w)>max)k--;push(word.slice(0,k));word=word.slice(k);}
    const c=cur?cur+' '+word:word;if(tw(c,s,w)<=max)cur=c;else{if(cur)push(cur);cur=word;}});
  if(cur)push(cur);if(!out.length)out.push('');
  if(out.length>lines){out.length=lines;let l=out[lines-1];while(l&&tw(l+'…',s,w)>max)l=l.slice(0,-1);out[lines-1]=l+'…';}
  return out;}
/* multi-line text centred on y */
const TL=(x,y,lines,o={})=>{const s=o.s||11,lh=Math.round(s*1.25),e=T(x,y-(lines.length-1)*lh/2,lines[0],o);
  if(lines.length>1){e.textContent='';lines.forEach((l,i)=>{const sp=el('tspan',{x,dy:i?lh:0},null,l);e.append(sp);});}
  if(o.full&&/…$/.test(lines[lines.length-1]))e.append(el('title',{},null,o.full));return e;};
const decs=vs=>Math.min(2,Math.max(0,...vs.map(v=>{const m=String(v).split('.')[1];return m?m.length:0;})));
function fit(host,draw){let last=0;const go=()=>{const W=Math.max(260,Math.floor(host.clientWidth));if(Math.abs(W-last)<2)return;last=W;
    host.querySelectorAll(':scope>svg').forEach(s=>s.remove());const s=draw(W);s.setAttribute('width',W);host.append(s);};
  go();new ResizeObserver(go).observe(host);if(document.fonts&&document.fonts.ready)document.fonts.ready.then(()=>{last=0;go();});}
const labelCol=(labels,W,s)=>Math.min(Math.ceil(Math.max(40,...labels.map(l=>tw(l,s,600))))+12,Math.floor(W*0.38));

/* Horizontal bars, one highlighted. data:[{label,value,hi}]. Negative values run left of zero. */
function bars(host,data,{unit='',d}={}){
  fit(host,W=>{d=d??decs(data.map(x=>x.value));const s0=12,L=labelCol(data.map(x=>x.label),W,s0);
    const lab=data.map(x=>wrap(x.label,L-12,s0,x.hi?600:400)),val=data.map(x=>fmt(x.value,d)+unit);
    const R=Math.ceil(Math.max(0,...data.map((x,i)=>x.value>0?tw(val[i],11.5,600):0)))+10;
    const lo=Math.min(0,...data.map(x=>x.value)),hi=Math.max(0,...data.map(x=>x.value)),X=v=>L+(W-L-R)*(v-lo)/((hi-lo)||1);
    const rows=lab.map(l=>Math.max(30,l.length*15+10));let H=10+rows.reduce((a,b)=>a+b,0);const s=svg(W,H);let y=5;
    if(lo<0)s.append(el('line',{x1:X(0),x2:X(0),y1:2,y2:H-2},'stroke:var(--mute);stroke-width:1'));
    data.forEach((x,i)=>{const rh=rows[i],g=G(key(x,i)),a=X(Math.min(0,x.value)),b=X(Math.max(0,x.value));
      g.append(TL(L-12,y+rh/2,lab[i],{full:x.label,a:'end',s:s0,c:x.hi?'--ink':'--mute',w:x.hi?600:400}));
      g.append(el('rect',{x:a,y:y+rh/2-9,width:Math.max(1,b-a),height:18,rx:2},`fill:var(${x.hi?'--cu':'--sand'})`));
      g.append(T(x.value<0?X(0)+6:b+6,y+rh/2,val[i],{s:11.5,w:x.hi?600:400}));s.append(g);y+=rh;});
    return s;});
}

/* Waterfall bridge. data:[{label,value,total?}] — totals drawn from zero, steps float. Unfavourable steps use the accent (costs:true makes increases unfavourable).
   Columns when each step has room for its label; rows (label left, bar right) when it does not. */
function waterfall(host,data,{unit='',d,costs=false}={}){
  fit(host,W=>{d=d??decs(data.map(x=>x.value));const n=data.length;let run=0,lo=0,hi=0;
    const pts=data.map(x=>{if(x.total){run=x.value;return{a:0,b:x.value};}const a=run;run+=x.value;return{a,b:run};});
    pts.forEach(p=>{lo=Math.min(lo,p.a,p.b);hi=Math.max(hi,p.a,p.b);});
    const lab=x=>(x.total?'':x.value>0?'+':'')+fmt(x.value,d)+unit,bad=x=>!x.total&&(costs?x.value>0:x.value<0),col=x=>x.total?'--ink':(bad(x)?'--cu':'--sand');
    const bw=(W-20)/n;
    const cols=bw>=72?data.map(x=>wrap(x.label,bw-6,10.5,400,4)):null;
    if(cols&&cols.every(l=>l.length<=3)){const ls=cols,nl=Math.max(...ls.map(l=>l.length)),T0=24,B=16+nl*13+6,H=Math.max(240,Math.min(360,W*0.42))+nl*13;
      const y=v=>T0+(H-T0-B)*(hi-v)/((hi-lo)||1),s=svg(W,H);
      s.append(el('line',{x1:10,x2:W-10,y1:y(0),y2:y(0)},'stroke:var(--sand);stroke-width:1.5'));
      data.forEach((x,i)=>{const p=pts[i],x0=10+i*bw+bw*.18,w=bw*.64,top=y(Math.max(p.a,p.b)),hgt=Math.max(1,Math.abs(y(p.a)-y(p.b))),g=G(key(x,i));
        g.append(el('rect',{x:x0,y:top,width:w,height:hgt,rx:2},`fill:var(${col(x)})`));
        if(i<n-1){const ny=y(p.b);g.append(el('line',{x1:x0+w,x2:x0+bw,y1:ny,y2:ny},'stroke:var(--mute);stroke-dasharray:2 2'));}
        g.append(T(x0+w/2,top-9,lab(x),{a:'middle',s:11,w:x.total||bad(x)?600:400,c:bad(x)?'--cu':'--ink'}));
        const t=T(x0+w/2,H-B+12,ls[i][0],{a:'middle',s:10.5,c:'--mute',b:'hanging'});if(ls[i].length>1){t.textContent='';ls[i].forEach((l,k)=>t.append(el('tspan',{x:x0+w/2,dy:k?13:0},null,l)));}
        g.append(t);s.append(g);});
      return s;}
    const s0=11.5,L=labelCol(data.map(x=>x.label),W,s0),ls=data.map(x=>wrap(x.label,L-12,s0,x.total?600:400)),R=Math.ceil(Math.max(...data.map(x=>tw(lab(x),11,600))))+10;
    const X=v=>L+(W-L-R)*(v-lo)/((hi-lo)||1),rows=ls.map(l=>Math.max(28,l.length*14+10)),H=10+rows.reduce((a,b)=>a+b,0),s=svg(W,H);let yy=5;
    s.append(el('line',{x1:X(0),x2:X(0),y1:2,y2:H-2},'stroke:var(--sand);stroke-width:1.5'));
    data.forEach((x,i)=>{const p=pts[i],rh=rows[i],a=X(Math.min(p.a,p.b)),b=X(Math.max(p.a,p.b)),g=G(key(x,i));
      g.append(TL(L-12,yy+rh/2,ls[i],{full:x.label,a:'end',s:s0,c:x.total?'--ink':'--mute',w:x.total?600:400}));
      g.append(el('rect',{x:a,y:yy+rh/2-8,width:Math.max(1,b-a),height:16,rx:2},`fill:var(${col(x)})`));
      if(i<n-1){const nx=X(p.b);g.append(el('line',{x1:nx,x2:nx,y1:yy+rh/2+8,y2:yy+rh+rows[i+1]/2-8},'stroke:var(--mute);stroke-dasharray:2 2'));}
      g.append(T(b+6,yy+rh/2,lab(x),{s:11,w:x.total||bad(x)?600:400,c:bad(x)?'--cu':'--ink'}));s.append(g);yy+=rh;});
    return s;});
}

/* Variance vs plan. data:[{label,actual,plan}] — favourable = sand, unfavourable = accent. costs:true means over plan is bad. */
function variance(host,data,{unit='',d,costs=true}={}){
  fit(host,W=>{const vs=data.map(x=>x.actual-x.plan);d=d??decs(vs);const s0=12,L=labelCol(data.map(x=>x.label),W,s0);
    const val=vs.map(v=>(v>0?'+':'')+fmt(v,d)+unit),R=Math.ceil(Math.max(...val.map(v=>tw(v,11,600))))+12;
    const lab=data.map((x,i)=>wrap(x.label,L-12,s0,(costs?vs[i]>0:vs[i]<0)?600:400)),rows=lab.map(l=>Math.max(30,l.length*15+10));
    const H=rows.reduce((a,b)=>a+b,0)+30,half=(W-L-R)/2,mid=L+half,max=Math.max(...vs.map(Math.abs))||1,s=svg(W,H);let yy=4;
    s.append(el('line',{x1:mid,x2:mid,y1:4,y2:H-20},'stroke:var(--mute);stroke-width:1'));
    s.append(T(mid,H-8,'on plan',{a:'middle',s:10,c:'--mute'}));
    data.forEach((x,i)=>{const v=vs[i],bad=costs?v>0:v<0,w=(half-4)*Math.abs(v)/max,rh=rows[i],g=G(key(x,i));
      g.append(TL(L-12,yy+rh/2,lab[i],{full:x.label,a:'end',s:s0,c:bad?'--ink':'--mute',w:bad?600:400}));
      g.append(el('rect',{x:v<0?mid-w:mid,y:yy+rh/2-8,width:Math.max(1,w),height:16,rx:2},`fill:var(${bad?'--cu':'--sand'})`));
      g.append(T(W-4,yy+rh/2,val[i],{a:'end',s:11,w:bad?600:400,c:bad?'--cu':'--ink'}));s.append(g);yy+=rh;});
    return s;});
}

/* Line: actual (solid) + optional plan/forecast (dashed) + optional threshold. Direct end labels, pushed apart so they never overlap. */
function line(host,{labels,series,threshold,unit='',d,annotate}){
  fit(host,W=>{const all=series.flatMap(x=>x.values.filter(v=>v!=null)).concat(threshold?[threshold.value]:[]);d=d??Math.min(1,decs(all));
    const nice=v=>{const p=Math.pow(10,Math.floor(Math.log10(v||1))),m=v/p;return (m<=1?1:m<=2?2:m<=2.5?2.5:m<=5?5:10)*p;};
    /* lines need not start at zero: when every value sits well above it, the axis hugs the data */
    const mn=Math.min(...all),mx=Math.max(...all),st=nice(((mn>0&&mn>mx*0.4)?mx-mn:mx-Math.min(0,mn))/4||1);
    const lo=(mn>0&&mn>mx*0.4)?Math.floor((mn-st*0.5)/st)*st:Math.min(0,Math.floor(mn/st)*st),hi=Math.ceil((mx+st*0.25)/st)*st,n=labels.length;
    const Rw=Math.min(Math.ceil(Math.max(...series.map(x=>tw(x.name,11,600)))),Math.max(Math.floor(W*0.26),110),180),names=series.map(x=>wrap(x.name,Rw,11,x.hi?600:400,4));
    const L=Math.ceil(Math.max(tw(fmt(hi,d),10),tw(fmt(lo,d),10)))+12,R=Rw+14,T0=20,B=34,H=Math.max(240,Math.min(320,Math.round(W*0.45))),s=svg(W,H);
    const X=i=>L+(W-L-R)*i/((n-1)||1),Y=v=>T0+(H-T0-B)*(hi-v)/((hi-lo)||1);
    const ticks=[];for(let v=lo;v<=hi+st/2;v+=st)ticks.push(+v.toFixed(6));d=Math.max(d,decs([st]));
    ticks.forEach(v=>{s.append(el('line',{x1:L,x2:W-R,y1:Y(v),y2:Y(v)},'stroke:var(--line)'));s.append(T(L-6,Y(v),fmt(v,d),{a:'end',s:10,c:'--mute'}));});
    const lw=Math.max(...labels.map(l=>tw(l,10)))+10,step=Math.max(1,Math.ceil(n/Math.max(1,Math.floor((W-L-R)/lw))));
    labels.forEach((l,i)=>{if(i%step===0&&(i===n-1||n-1-i>=step||i===0))s.append(T(X(i),H-B+16,l,{a:'middle',s:10,c:'--mute'}));else if(i===n-1)s.append(T(X(i),H-B+16,l,{a:'middle',s:10,c:'--mute'}));});
    if(threshold){const ty=Y(threshold.value);s.append(el('line',{x1:L,x2:W-R,y1:ty,y2:ty},'stroke:var(--ink);stroke-dasharray:4 3'));
      const k=Math.max(1,Math.ceil(n*0.4)),above=series.reduce((a,x)=>a+x.values.slice(0,k).filter(v=>v!=null&&v>threshold.value).length,0),below=series.reduce((a,x)=>a+x.values.slice(0,k).filter(v=>v!=null&&v<threshold.value).length,0);
      const tl=wrap(threshold.label,(W-L-R)*0.6,10.5,400,3),dy=(tl.length*13)/2+5;
      s.append(TL(L+6,above>below?ty+dy:ty-dy,tl,{s:10.5,c:'--ink',halo:1}));}
    const ends=[];
    series.forEach((x,si)=>{let p='',last=null;x.values.forEach((v,i)=>{if(v==null)return;p+=(p?'L':'M')+X(i)+' '+Y(v);last=i;});
      const col=x.hi?'--cu':x.dashed?'--org':'--mute',g=G(key(x,si));
      g.append(el('path',{d:p,fill:'none'},`stroke:var(${col});stroke-width:${x.hi?2.5:1.8};${x.dashed?'stroke-dasharray:5 4':''}`));
      if(last!=null){g.append(el('circle',{cx:X(last),cy:Y(x.values[last]),r:3.5},`fill:var(${col})`));ends.push({g,y:Y(x.values[last]),h:names[si].length*14,lines:names[si],x,col});}
      s.append(g);});
    ends.sort((a,b)=>a.y-b.y);let floor=T0-6;ends.forEach(e=>{e.c=Math.max(e.y,floor+e.h/2);floor=e.c+e.h/2+3;});
    const over=floor-(H-B+4);if(over>0){let ceil=H-B+4;for(let k=ends.length-1;k>=0;k--){const e=ends[k];e.c=Math.min(e.c,ceil-e.h/2);ceil=e.c-e.h/2-3;}}
    ends.forEach(e=>e.g.append(TL(W-R+8,e.c,e.lines,{full:e.x.name,halo:1,s:11,w:e.x.hi?600:400,c:e.col})));
    if(annotate){const{i,text}=annotate,v=series[0].values[i];s.append(el('line',{x1:X(i),x2:X(i),y1:Y(v)-8,y2:T0},'stroke:var(--cu)'));s.append(T(X(i)+4,T0+2,text,{s:10.5,w:600,c:'--cu',b:'hanging'}));}
    return s;});
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
/* weeks: column labels; today: fractional week index; rows: [{name,st:p|h|f|n,items:[{from,to,label,kind:p|a}|{at,label}]}]
   from/to/at are fractional week indexes (1.5 = the middle of the second column). Bars sit in their own lane and
   wrap their label; milestones sit in a lane under the bars, label beside the diamond; today runs behind the bars. */
function gantt(host,{weeks=[],today,rows=[]}){
  const n=Math.max(1,weeks.length),Q=12,cl=x=>Math.max(0,Math.min(n*Q,Math.round(x*Q)))+1,pc=x=>Math.max(0,Math.min(100,x/n*100));
  const g=document.createElement('div');g.className='gantt';g.style.setProperty('--n',n);
  const tl=today!=null?`<i class="today" style="left:${pc(today)}%"></i>`:'';
  let h=`<div></div><div class="wks">${weeks.map(w=>`<div class="wk">${esc(w)}</div>`).join('')}${today!=null?`<span class="now" style="left:${pc(today)}%">today</span>`:''}</div>`;
  rows.forEach((r,i)=>{const rk=key(r,i),its=r.items||[];let bars='',ms='';
    its.forEach((it,j)=>{const ik=esc(it.id!=null?'#'+it.id:rk+'.'+j);
      if(it.at!=null){const c=cl(it.at),late=it.at/n>0.6;
        ms+=`<div class="msi${late?' late':''}" data-vt-key="${ik}" style="grid-column:${late?'1/'+c:c+'/-1'}"><span class="ms" title="${esc(it.label)}"></span><span>${esc(it.label)}</span></div>`;}
      else{const a=cl(it.from),z=Math.max(a+1,cl(it.to));bars+=`<div class="bar ${esc(it.kind||'')}" data-vt-key="${ik}" title="${esc(it.label)}" style="grid-column:${a}/${z}">${esc(it.label)}</div>`;}});
    h+=`<div class="row" data-vt-key="${esc(rk)}"><span class="dot ${esc(r.st||'n')}"></span><span>${esc(r.name)}</span></div><div class="trk">${tl}${bars?`<div class="lane">${bars}</div>`:''}${ms?`<div class="lane mss">${ms}</div>`:''}</div>`;});
  g.innerHTML=h;host.className=(host.className+' tw').trim();host.append(g);
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
  const C=document.createElement('div');C.className='clusters';C.style.setProperty('--cols',Math.min(4,clusters.length||1));C.style.setProperty('--cols2',Math.min(2,clusters.length||1));
  C.innerHTML=clusters.map((c,ci)=>`<div class="cluster" data-vt-key="${esc(key(c,ci))}"><div class="sticky">${esc(c.name)}</div>${(c.items||[]).map((o,oi)=>`<article class="opt${o.fav?' fav':''}${o.drop?' drop':''}" data-id="${esc(o.id)}" data-vt-key="${esc(o.id!=null?'#'+o.id:key(c,ci)+'.'+oi)}"><h3>${esc(o.title)}</h3><p>${esc(o.body)}</p><div class="votes">${'<i></i>'.repeat(Math.max(0,Math.min(20,o.votes|0)))}<span>${o.votes|0}</span>${o.fav?'<span class="mark">· favourite</span>':o.drop?'<span class="mark">· dropped</span>':''}</div></article>`).join('')}</div>`).join('');
  host.append(S,C);
  const by=id=>C.querySelector(`[data-id="${CSS.escape(String(id))}"]`);
  /* Links run in the gutters: out of a card's side, along the gap between columns, into the target's side.
     A link inside one column runs down its left gutter. Lines sit behind the cards, so they never cross text. */
  function draw(){const r=host.getBoundingClientRect(),gap=parseFloat(getComputedStyle(C).columnGap)||24,lane={};
    S.innerHTML='<defs><marker id="vt-ah" viewBox="0 0 8 8" refX="7" refY="4" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L8 4L0 8z" style="fill:var(--cu)"/></marker></defs>';
    const off=(gx,room,out)=>{const k=Math.round(gx);lane[k]=(lane[k]||0)+1;const i=lane[k]-1;return out?gx-Math.min(room,i*4):gx+(i%2?1:-1)*Math.min(room,Math.ceil(i/2)*5);};
    links.forEach(([f,t])=>{const ea=by(f),eb=by(t);if(!ea||!eb)return;const A=ea.getBoundingClientRect(),B=eb.getBoundingClientRect();
      const ax=v=>v-r.left,ay=v=>v-r.top,y1=ay(A.top+Math.min(A.height/2,28)),y2=ay(B.top+Math.min(B.height/2,28));let d;
      if(B.left>=A.right-1){const gx=off(ax(A.right)+gap/2,gap/2-4);d=`M${ax(A.right)} ${y1}H${gx}V${y2}H${ax(B.left)-1}`;}
      else if(B.right<=A.left+1){const gx=off(ax(A.left)-gap/2,gap/2-4);d=`M${ax(A.left)} ${y1}H${gx}V${y2}H${ax(B.right)+1}`;}
      else{const pad=Math.min(A.left,B.left)-r.left,gx=off(ax(Math.min(A.left,B.left))-Math.min(gap/2,8),Math.max(0,Math.min(gap/2,pad)-12),1);d=`M${ax(A.left)} ${y1}H${gx}V${y2}H${ax(B.left)-1}`;}
      S.insertAdjacentHTML('beforeend',`<path d="${d}" fill="none" style="stroke:var(--cu);stroke-width:1.6;stroke-dasharray:5 4;stroke-linejoin:round" marker-end="url(#vt-ah)"/>`);});}
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
