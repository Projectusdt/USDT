const config=window.SITE_CONFIG;
const setText=(selector,value)=>{const element=document.querySelector(selector);if(element&&value)element.textContent=value};
const setTextIn=(parent,selector,value)=>{const element=parent.querySelector(selector);if(element&&value)element.textContent=value};

if(config){
  const {project,hero,mission,team,support,documents,roadmap}=config;
  document.title=`${project.name} | Official Website`;
  document.querySelectorAll('img[src="USDT.PNG"]').forEach(image=>image.src=project.logo);
  document.querySelectorAll('.brand b').forEach(element=>element.textContent=project.name);
  setText('.heroText .tag',hero.label);
  const title=document.querySelector('.heroText h1');
  if(title){title.textContent=hero.title;title.append(document.createElement('br'));const emphasis=document.createElement('em');emphasis.textContent=hero.highlightedTitle;title.append(emphasis)}
  setText('.heroText>p',hero.description);
  const quickValues=document.querySelectorAll('.quick b');
  [project.name,project.symbol,project.decimals].forEach((value,index)=>{if(quickValues[index])quickValues[index].textContent=value});
  setText('.aboutCopy>p',mission.about);
  setText('.featureGrid article:nth-child(3) p',mission.revenue);
  setText('.featureGrid article:nth-child(4) p',mission.socialSupport);
  const specValues=document.querySelectorAll('.specs b');
  [project.name,project.symbol,project.decimals,project.totalSupply,project.standard,project.network].forEach((value,index)=>{if(specValues[index])specValues[index].textContent=value});
  document.querySelectorAll('.contractBox code').forEach(element=>element.textContent=project.contract);
  const teamCards=document.querySelectorAll('.team article');
  team.forEach((member,index)=>{const card=teamCards[index];if(!card)return;setTextIn(card,'.avatar',member.initials);setTextIn(card,'span',member.role);setTextIn(card,'h3',member.name);setTextIn(card,'p',member.details)});
  const documentValues=document.querySelectorAll('.documents b');
  [documents.whitepaper,documents.audit,documents.explorer,documents.revenuePolicy].forEach((value,index)=>{if(documentValues[index])documentValues[index].textContent=value});
  const social=[support.twitter,support.facebook,support.telegram].filter(value=>value&&!value.startsWith('Pending')).join(' · ')||'Pending official confirmation';
  const contactValues=document.querySelectorAll('.contacts b');
  [support.email,support.phone,social].forEach((value,index)=>{if(contactValues[index])contactValues[index].textContent=value});
  const roadmapCards=document.querySelectorAll('.timeline article');
  roadmap.forEach((item,index)=>{const card=roadmapCards[index];if(!card)return;setTextIn(card,'span',item.number);setTextIn(card,'small',item.phase);setTextIn(card,'h3',item.title);setTextIn(card,'p',item.text)});
  setText('.footer small',`© ${project.copyrightYear} ${project.name} · Symbol: ${project.symbol} · Decimals: ${project.decimals}`);
  const copyButton=document.getElementById('copyBtn');
  const copiedMessage=document.getElementById('copied');
  copyButton?.addEventListener('click',async()=>{try{await navigator.clipboard.writeText(project.contract)}catch{const input=document.createElement('textarea');input.value=project.contract;document.body.appendChild(input);input.select();document.execCommand('copy');input.remove()}copiedMessage.style.display='block';setTimeout(()=>copiedMessage.style.display='none',1800)});
}

document.querySelector('.menu')?.addEventListener('click',()=>document.querySelector('.navlinks')?.classList.toggle('show'));
