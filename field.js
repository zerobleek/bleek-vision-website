//
//  field.js
//  Bleek Vision Website
//
//  Created by Shabaka Malik Banks on 11/16/26.
//  Copyright © 2026 Bleek Vision LLC. All rights reserved.
//
//  Shared by every studio page: draws the light field into <canvas id="field">.

// Light field: three slow periwinkle/silver beams with a faint prism fringe,
// drawn on a full-screen WebGL canvas. Pauses when the tab is hidden; holds a
// still frame for reduced motion; falls back to a CSS glow without WebGL.
(function () {
  var c = document.getElementById('field');
  if (!c) return;
  var gl = c.getContext('webgl', { antialias: false });
  if (!gl) { c.classList.add('field--flat'); return; }
  var vs = 'attribute vec2 p;void main(){gl_Position=vec4(p,0.,1.);}';
  var fs = [
    'precision mediump float;uniform vec2 r;uniform float t;',
    'float band(vec2 uv,float a,float off,float w,float s){',
    ' vec2 d=vec2(cos(a),sin(a));float x=dot(uv,d)+off+0.08*sin(dot(uv,vec2(-d.y,d.x))*2.2+t*s);',
    ' return exp(-x*x/w);}',
    'void main(){',
    ' vec2 uv=(gl_FragCoord.xy-.5*r)/r.y;',
    ' vec3 col=vec3(.055,.063,.082);',
    ' float T=t*.06;',
    ' for(int i=0;i<3;i++){',
    '  float fi=float(i);',
    '  float a=-.62+fi*.21+.06*sin(T+fi);',
    '  float off=-.35+fi*.42+.12*sin(T*1.3+fi*2.);',
    '  float w=.0035+fi*.0025;float s=.4+fi*.15;',
    '  vec3 b=vec3(band(uv,a,off-.012,w,s),band(uv,a,off,w,s),band(uv,a,off+.014,w,s));',
    '  vec3 tint=mix(vec3(.54,.63,.76),vec3(.78,.80,.84),fi*.5);',
    '  col+=b*tint*(.34-fi*.07);',
    '  col+=band(uv,a,off,w*40.,s)*vec3(.54,.63,.76)*.05;',
    ' }',
    ' float v=smoothstep(1.25,.25,length(uv*vec2(.85,1.)));',
    ' col*=mix(.55,1.,v);',
    ' gl_FragColor=vec4(col,1.);',
    '}'
  ].join('\n');
  function sh(type, src) { var s = gl.createShader(type); gl.shaderSource(s, src); gl.compileShader(s); return s; }
  var pr = gl.createProgram();
  gl.attachShader(pr, sh(gl.VERTEX_SHADER, vs));
  gl.attachShader(pr, sh(gl.FRAGMENT_SHADER, fs));
  gl.linkProgram(pr);
  if (!gl.getProgramParameter(pr, gl.LINK_STATUS)) { c.classList.add('field--flat'); return; }
  gl.useProgram(pr);
  gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW);
  var loc = gl.getAttribLocation(pr, 'p');
  gl.enableVertexAttribArray(loc);
  gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);
  var uR = gl.getUniformLocation(pr, 'r'), uT = gl.getUniformLocation(pr, 't');
  var dpr = Math.min(window.devicePixelRatio || 1, 1.5);
  var still = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var t0 = performance.now(), running = false;
  function draw() {
    gl.uniform2f(uR, c.width, c.height);
    gl.uniform1f(uT, still ? 20 : (performance.now() - t0) / 1000 + 20);
    gl.drawArrays(gl.TRIANGLES, 0, 3);
  }
  function loop() {
    if (document.hidden || still) { running = false; return; }
    draw();
    requestAnimationFrame(loop);
  }
  function size() {
    // Half-resolution is plenty for soft light and keeps phones cool.
    c.width = Math.round(window.innerWidth * dpr * 0.5);
    c.height = Math.round(window.innerHeight * dpr * 0.5);
    gl.viewport(0, 0, c.width, c.height);
    draw();
  }
  function start() { if (!running && !still && !document.hidden) { running = true; requestAnimationFrame(loop); } }
  size();
  window.addEventListener('resize', size);
  document.addEventListener('visibilitychange', start);
  start();
})();
