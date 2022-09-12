let t=0,pg,pg2,recording=!1,runners=null,creativeMode=!1,palette=[["#CBFF00","#0000FF"],["#CBFF00","#006200"],["#CBFF00","#FF0000"],["#CBFF00","#5d5d5d"],["#CBFF00","#772ABC"],["#772ABC","#FF0000"],["#772ABC","#5d5d5d"],["#FF0000","#006200"],["#0000FF","#006200"],["#00FF00","#006200"],["#00FF00","#000000"],["#FF0000","#000000"],["#CBFF00","#000000"],["#FFFFFF","#000000"],["#590000","#FF0000"],["#006200","#CBFF00","#FF0000"],["#006200","#CBFF00","#0000FF"],["#FF0000","#5d5d5d","#772ABC"],["#FF0000","#CBFF00","#0000FF"],["#5d5d5d","#FF0000","#772ABC"],["#5d5d5d","#0000FF","#CBFF00"],["#5d5d5d","#00FF00","#006200"],["#FF0000","#00FF00","#0000FF","#000000"],["#006200","#CBFF00","#FF0000","#772ABC"],["#006200","#CBFF00","#FF0000","#5d5d5d"],["#006200","#CBFF00","#772ABC","#5d5d5d"],["#0000FF","#FF0000","#00FF00","#000000"],["#0000FF","#006200","#CBFF00","#5d5d5d"],["#0000FF","#FF0000","#006200","#CBFF00","#5d5d5d","#772ABC"],["#0000FF","#FF0000","#006200","#CBFF00","#5d5d5d","#772ABC"]],palette1,palette2,palettePicker,seed,colorPicker,colorPicker2,numSystems,numSystems2,columnsRandom,sizeQuad,colorQuads,randShapes,sizeCx,sizeCy,finalImage,finalImage2,tempPixels,tempPixels2,r1,r2,tex,canvas,seeds=[[269,728,134]],seedCount=0,seedIndex=0,running=!0;function setup(){start(seeds[0][0])}function draw(){if(!0==running){t>1&&t%300==0&&(seedCount<2?seedCount++:seedCount=0,start(seeds[seedIndex][int(seedCount)])),background(0,0,0),pgShow(),finalImage.loadPixels();for(let c=0;c<finalImage.width;c++)for(let d=0;d<finalImage.height;d++){let a=(c+d*finalImage.width)*4;finalImage.pixels[a]=tempPixels[a],finalImage.pixels[a+1]=tempPixels[a+1],finalImage.pixels[a+2]=tempPixels[a+2],finalImage.pixels[a+3]=tempPixels[a+3]}finalImage.updatePixels(),finalImage2.loadPixels();for(let e=0;e<finalImage2.width;e++)for(let f=0;f<finalImage2.height;f++){let b=(e+f*finalImage2.width)*4;finalImage2.pixels[b]=tempPixels2[b],finalImage2.pixels[b+1]=tempPixels2[b+1],finalImage2.pixels[b+2]=tempPixels2[b+2],finalImage2.pixels[b+3]=tempPixels2[b+3]}finalImage2.updatePixels(),imageMode(CENTER),image(finalImage,windowWidth/2,windowHeight/2,windowWidth/windowHeight>1.98?windowWidth:1.98*windowHeight,windowWidth/windowHeight>1.98?.5*windowWidth:windowHeight),image(finalImage2,windowWidth/2,windowHeight/2,windowWidth/windowHeight>1.98?windowWidth:1.98*windowHeight,windowWidth/windowHeight>1.98?.5*windowWidth:windowHeight)}}function windowResized(){resizeCanvas(windowWidth,windowHeight)}function pgShow(){if(t++,pg.background(0),1==t)for(let a=0;a<numSystems;a++)runners.push(new ParticleSystem(floor(random(2,7)),random(3,5),palette1[a],a,pg,pg.width,pg.height,1));if(1==t)for(let b=0;b<numSystems2;b++)runners.push(new ParticleSystem(floor(random(4,7)),random(1.5,2),palette2[b],b,pg,pg.width,pg.height,2));for(let c=0;c<runners.length;c++){let d=runners[c];d.force(),d.nu(),d.update()}sizeCx=runners[0].stepSize/2*columnsRandom,sizeCy=pg.height/2}function start(c){canvas=createCanvas(windowWidth,windowHeight),frameRate(30),t=0,frameCount=0,noCursor(),noiseSeed(4),strokeWeight(1.01),seed=floor(random(random(12222,1222111))),!0==creativeMode?randomSeed(seed):randomSeed(c),r1=10,r2=10,runners=[],numSystems=floor(random(2,4));let d=int(2560/r1/2*2+1),e=int(1290/r1/2*2+1);(pg=createGraphics(d,e)).pixelDensity(1),numSystems2=floor(random(2,5)),canvas.imageSmoothingEnabled=!1,p5.disableFriendlyErrors=!0,noSmooth(),randShapes=random(10);let f=int(2560/r1/2*2+1),g=int(1290/r1/2*2+1),h=int(2560/r2/2*2+1),i=int(1290/r2/2*2+1);finalImage=createImage(f,g),finalImage2=createImage(h,i),tempPixels=[],tempPixels2=[],pixelDensity(1),palette1=[],palette2=[],palettePicker=floor(map(random(1),0,1,0,palette.length));for(let a=0;a<numSystems;a++){colorPicker=floor(map(random(1),0,1,0,palette[palettePicker].length));let j=color(palette[palettePicker][colorPicker]);palette1[a]=j}for(let b=0;b<numSystems2;b++){colorPicker=floor(map(random(1),0,1,0,palette[palettePicker].length));let k=color(palette[palettePicker][colorPicker]);palette2[b]=k}columnsRandom=floor(random(1,5)),console.log("g\xe4mma: live"),console.log("number of systems: "+numSystems+"/"+numSystems2),console.log("current seed: "+seed)}let ParticleSystem=function(a,b,c,d,e,f,g,h){this.particles=[],this.loc=createVector(0,-4),this.vel=createVector(0,0),this.acc=createVector(0,0),this.lifespan=160,this.columns=a,this.initialVel=b,this.cor=c,this.stepToMiss=2,this.index=d,this.intervalCells=random(0,5),this.finalPg=e,this.w=f,this.h=g,this.stepSize=this.w/this.columns,this.layer=h};ParticleSystem.prototype.update=function(){this.lifespan-=2;let c=this.particles.length;for(let a=c-1;a>=0;a--){let b=this.particles[a];b.update(),b.display(),b.isDead()&&this.particles.splice(a,1)}},ParticleSystem.prototype.isDead=function(){return this.lifespan<=0},ParticleSystem.prototype.force=function(){this.cent=createVector(0,this.h),this.p=p5.Vector.sub(this.cent,this.loc),this.p.normalize(),this.p.mult(this.initialVel),1==t&&this.applyForce(this.p)},ParticleSystem.prototype.applyForce=function(a){this.acc.add(a)},ParticleSystem.prototype.nu=function(){this.vel.add(this.acc),this.loc.add(this.vel),this.acc.mult(0),this.vel.limit(2),this.vel.mult(.99),t%this.stepToMiss==0&&this.loc.y<this.h&&this.particles.push(new Particle(20,this.loc.y,this.columns,this.cor,this.index,this.intervalCells,this.finalPg,this.w,this.h,this.layer))};let Particle=function(j,b,c,a,d,e,f,g,h,i){this.loc=createVector(0,b),this.vel=createVector(0,0),this.acc=createVector(0,0),this.columns=c,this.cor=a,this.killingTime=2,this.lifespan=380,this.index=d,this.intervalCells=e,this.finalPg=f,this.w=g,this.h=h,this.step=this.w/this.columns,this.size=this.step/2-1,this.layer=i,this.rrr=int(red(color(a))),this.ggg=int(green(color(a))),this.bbb=int(blue(color(a))),this.randGlitchX=floor(random(2,4)),this.randGlitchY=floor(random(1,2))};function keyTyped(){"p"===key?running=!running:"s"===key&&saveCanvas("g\xe4mma_"+nf(seed,10,0)+".png")}Particle.prototype.update=function(){this.sx=0,this.sy=0,this.acc=createVector(this.sx,this.sy),this.vel.add(this.acc),this.loc.add(this.vel),this.vel.limit(.2),this.acc.mult(0),this.vel.mult(.95),this.lifespan-=this.killingTime},Particle.prototype.isDead=function(){return this.lifespan<=0},Particle.prototype.applyForce=function(a){this.acc.add(a)},Particle.prototype.display=function(){for(let b=0;b<this.columns;b++){let h=b*int(this.step)+1;0==b?(this.begin=-1,this.end=2*this.size):b==this.columns-1?(this.begin=0,this.end=2*this.size+3):(this.begin=0,this.end=2*this.size),(3==this.columns||5==this.columns)&&b==this.columns-1&&(this.begin=0,this.end=2*this.size+5),6==this.columns&&(h=b*int(this.step)+3,b==this.columns-1?(this.begin=0,this.end=2*this.size+4):0==b?(this.begin=-3,this.end=2*this.size):(this.begin=0,this.end=2*this.size));for(let g=this.begin;g<this.end;g++){let e=int(h)+int(g),f=int(this.loc.y);120==t&&(this.randGlitchX=floor(random(1,4)),this.randGlitchY=floor(random(1,4)));let a=int((e+f*this.w)*4),c=(e+1+f+3*this.w)*4;this.w;let d=(e+this.randGlitchX+10+f+this.randGlitchY*this.w)*4;this.lifespan>0?(e<finalImage.width/2-sizeCx/2-2||e>finalImage.width/2+sizeCx/2+1||f<finalImage.height/2-sizeCy/2||f>finalImage.height/2+sizeCy/2)&&1==this.layer?(tempPixels[a]=this.rrr,tempPixels[a+1]=this.ggg,tempPixels[a+2]=this.bbb,tempPixels[a+3]=255):e>finalImage2.width/2-sizeCx/2-2&&e<finalImage2.width/2+sizeCx/2+1&&f>finalImage2.height/2-sizeCy/2&&f<finalImage2.height/2+sizeCy/2&&2==this.layer&&(tempPixels2[a]=this.rrr,tempPixels2[a+1]=this.ggg,tempPixels2[a+2]=this.bbb,tempPixels2[a+3]=255,tempPixels2[c]=this.rrr,tempPixels2[c+1]=this.ggg,tempPixels2[c+2]=this.bbb,tempPixels2[c+3]=255,tempPixels2[d]=this.rrr,tempPixels2[d+1]=this.ggg,tempPixels2[d+2]=this.bbb,tempPixels2[d+3]=255):(tempPixels[a]=0,tempPixels[a+1]=0,tempPixels[a+2]=0,tempPixels[a+3]=0,tempPixels2[a]=0,tempPixels2[a+1]=0,tempPixels2[a+2]=0,tempPixels2[a+3]=0,tempPixels2[c]=0,tempPixels2[c+1]=0,tempPixels2[c+2]=0,tempPixels2[c+3]=0,tempPixels2[d]=0,tempPixels2[d+1]=0,tempPixels2[d+2]=0,tempPixels2[d+3]=0)}}}