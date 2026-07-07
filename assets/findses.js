/* ===== FINDSES · comportamiento compartido ===== */
(function(){
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---------- nav solid ---------- */
  const nav=document.querySelector('.nav');
  if(nav) addEventListener('scroll',()=>nav.classList.toggle('solid',scrollY>40),{passive:true});

  /* ---------- burger menu ---------- */
  const burger=document.querySelector('.burger');
  const navlinks=document.getElementById('navlinks');
  if(burger && navlinks){
    burger.addEventListener('click',()=>{
      const open=navlinks.classList.toggle('open');
      burger.setAttribute('aria-expanded',open);
      burger.textContent=open?'✕':'☰';
    });
    navlinks.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>{
      navlinks.classList.remove('open');
      burger.setAttribute('aria-expanded',false);
      burger.textContent='☰';
    }));
  }

  /* ---------- reveal ---------- */
  const io=new IntersectionObserver(es=>es.forEach(e=>{if(e.isIntersecting){e.target.classList.add('in');io.unobserve(e.target);}}),{threshold:.2});
  document.querySelectorAll('.reveal').forEach(el=>io.observe(el));

  /* ---------- focus reticle ---------- */
  (function(){
    const canHover=matchMedia('(hover:hover)').matches && !reduce;
    const ret=document.getElementById('reticle'); if(!ret) return;
    if(!canHover){ret.style.display='none';return;}
    const FREE=30; let rx=innerWidth/2,ry=innerHeight/2,tx=rx,ty=ry,snapped=false;
    addEventListener('mousemove',e=>{ret.style.opacity='1';if(!snapped){tx=e.clientX;ty=e.clientY;}},{passive:true});
    addEventListener('mouseleave',()=>ret.style.opacity='0');
    function snapTo(el){const r=el.getBoundingClientRect(),pad=8;snapped=true;ret.classList.add('snap');
      ret.style.width=(r.width+pad*2)+'px';ret.style.height=(r.height+pad*2)+'px';
      ret.style.left=(r.left+r.width/2)+'px';ret.style.top=(r.top+r.height/2)+'px';}
    function release(){if(!snapped)return;rx=parseFloat(ret.style.left)||rx;ry=parseFloat(ret.style.top)||ry;snapped=false;ret.classList.remove('snap');}
    window.FS_bindTargets=function(){
      document.querySelectorAll('.btn,.pcard,.chip,.sortbtn,.agent,.social,.cat,.wstep,.prose a,.cta,.hero a,.nav .links a,.foot a,.search').forEach(t=>{
        if(t._fb)return;t._fb=1;t.addEventListener('mouseenter',()=>snapTo(t));t.addEventListener('mouseleave',release);});
    };
    addEventListener('scroll',release,{passive:true});
    window.FS_bindTargets();
    (function loop(){requestAnimationFrame(loop);if(snapped)return;
      rx+=(tx-rx)*0.22;ry+=(ty-ry)*0.22;ret.style.width=FREE+'px';ret.style.height=FREE+'px';ret.style.left=rx+'px';ret.style.top=ry+'px';})();
  })();

  /* ---------- background particles (light 3D) ---------- */
  window.addEventListener('load',()=>{
    const canvas=document.getElementById('bg');
    if(!canvas || typeof THREE==='undefined' || reduce) return;
    let r; try{r=new THREE.WebGLRenderer({canvas,antialias:true,alpha:true});}catch(e){return;}
    if(!r.getContext())return;
    r.setPixelRatio(Math.min(devicePixelRatio,2)); r.setSize(innerWidth,innerHeight);
    const scene=new THREE.Scene(); scene.fog=new THREE.FogExp2(0x000000,.05);
    const cam=new THREE.PerspectiveCamera(55,innerWidth/innerHeight,.1,100); cam.position.z=6;
    const cv=document.createElement('canvas');cv.width=cv.height=64;const g=cv.getContext('2d');
    const gr=g.createRadialGradient(32,32,0,32,32,32);gr.addColorStop(0,'#fff');gr.addColorStop(.4,'rgba(180,200,255,.6)');gr.addColorStop(1,'rgba(0,0,0,0)');
    g.fillStyle=gr;g.fillRect(0,0,64,64);const tex=new THREE.CanvasTexture(cv);
    const N=innerWidth<760?700:1500;
    const pos=new Float32Array(N*3),col=new Float32Array(N*3),sz=new Float32Array(N);
    const cols=[new THREE.Color(0xFF8533),new THREE.Color(0xCC5500),new THREE.Color(0x2563EB)],t=new THREE.Color();
    for(let i=0;i<N;i++){const r2=2.6+Math.random()*8,th=Math.random()*6.28,ph=Math.acos(2*Math.random()-1);
      pos[i*3]=r2*Math.sin(ph)*Math.cos(th);pos[i*3+1]=r2*Math.sin(ph)*Math.sin(th)*.7;pos[i*3+2]=r2*Math.cos(ph)-2;
      const k=Math.random();t.copy(k<.6?cols[0]:k<.85?cols[1]:cols[2]);
      col[i*3]=t.r;col[i*3+1]=t.g;col[i*3+2]=t.b;sz[i]=Math.random()*.05+.012;}
    const geo=new THREE.BufferGeometry();
    geo.setAttribute('position',new THREE.BufferAttribute(pos,3));
    geo.setAttribute('color',new THREE.BufferAttribute(col,3));
    geo.setAttribute('aSize',new THREE.BufferAttribute(sz,1));
    const mat=new THREE.ShaderMaterial({uniforms:{uTex:{value:tex},uTime:{value:0}},transparent:true,blending:THREE.AdditiveBlending,depthWrite:false,
      vertexShader:`attribute float aSize;attribute vec3 color;varying vec3 vC;uniform float uTime;
        void main(){vC=color;vec3 p=position;p.y+=sin(uTime*.4+p.x)*.08;vec4 mv=modelViewMatrix*vec4(p,1.);
        gl_PointSize=aSize*(320./-mv.z);gl_Position=projectionMatrix*mv;}`,
      fragmentShader:`uniform sampler2D uTex;varying vec3 vC;void main(){vec4 c=texture2D(uTex,gl_PointCoord);gl_FragColor=vec4(vC,c.a*.9);}`});
    const pts=new THREE.Points(geo,mat);scene.add(pts);
    let mx=0,my=0,tmx=0,tmy=0;
    addEventListener('mousemove',e=>{tmx=e.clientX/innerWidth-.5;tmy=e.clientY/innerHeight-.5;},{passive:true});
    addEventListener('resize',()=>{cam.aspect=innerWidth/innerHeight;cam.updateProjectionMatrix();r.setSize(innerWidth,innerHeight);});
    (function anim(){requestAnimationFrame(anim);const tm=performance.now()*.001;mat.uniforms.uTime.value=tm;
      pts.rotation.y=tm*.03;pts.rotation.x=Math.sin(tm*.1)*.08;
      mx+=(tmx-mx)*.04;my+=(tmy-my)*.04;cam.position.x=mx*1.2;cam.position.y=-my*.9;cam.lookAt(0,0,0);
      r.render(scene,cam);})();
  });
})();
