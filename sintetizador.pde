

//LIBRERIAS

import themidibus.*;

import controlP5.*;

import ddf.minim.*;
import ddf.minim.ugens.*;
import processing.opengl.*;
import ddf.minim.effects.*;
import ddf.minim.analysis.*;
//import processing.sound.*;




//DECLARACIÓNS
String fraseOSC1   ="OSC 1: SINE ";
String fraseOSC2   ="OSC 2: SINE ";
String fraseOSC3   ="OSC 3: SINE ";
String fraseLPF ="LPF: OFF";
String fraseENV   ="ENV: OFF ";
String frasenoise="NOISE: OFF";
float frec1, frec2, frec3, frecENV, frecDelay;
int i1, i2, beat, filtrobaixo, filtromedio, cortes;
int on, ENVon, filtrobaixoBool, botonloop, loopactivate;
int arp1, arp2;
float amp1, amp2, ampENV, amp3;
int notas, veces;
float frec10;
int contadoron, contadorENV, contadornoise;
float atk, dec, rel, sust;
//Visuales2:
float theta, phi, x, y, z, r, n1, n2, n3, a, b, rotX, rotY, rotZ, visuals2;

ControlFrame cf;
//Secuenciador secuenciador;

Wavetable   table;

Minim       minim;
AudioOutput out;


Oscil       wave;
Oscil       wave2;
Oscil       wave3;
Oscil       ENV;
Oscil       noise;
Oscil       delay;
 Oscil myLFO;

ADSR  adsr;
Delay myDelay;

AudioPlayer pad1, pad2, pad3, pad4, pad5, pad6, pad7, pad8, loop1;
FilePlayer filePlayer;
//AudioSample sample1;

ChebFilter cbf;
float cutoffFreq = 4410;
float ripplePercent = 2;

//VISUALS

FFT fft;


float specLow = 0.03; // 3%
float specMid = 0.125;  // 12.5%
float specHi = 0.20;   // 20%

float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;


float oldScoreLow = scoreLow;
float oldScoreMid = scoreMid;
float oldScoreHi = scoreHi;


float scoreDecreaseRate = 25;

int nbCubes;
Cube[] cubes;

int nbMurs = 5000;
Mur[] murs;





LowPassFS   lpf;
IIRFilter filt;
Oscil cutOsc;
Constant cutoff;

AudioRecorder recorder;

MidiBus midi;




//SETTINGS
//TAMAÑO PANTALLA OSCILADOR
void settings() {
  size(1366, 765, P3D);
}






//SETUP
void setup()
{

  
  //secuenciador = new Secuenciador(this, 395, 200, "Secuenciador");
  midi = new MidiBus(this, 0, 1);

  lpf = new LowPassFS(100, 44100);
  //cbf = new ChebFilter(cutoffFreq, ChebFilter.LP, ripplePercent, 2, out.sampleRate());
  filt = new BandPass(400, 100, 44100);
  myDelay = new Delay( 0.4, 0.5, true, true );
  minim = new Minim(this);
  out = minim.getLineOut();
  recorder = minim.createRecorder(out, "myrecording.wav");
  
  cf = new ControlFrame(this, 700, 600, "ControlFrame", out);
  


  adsr = new ADSR( 0.5, atk, dec, sust, rel );


  fft = new FFT(out.bufferSize(), out.sampleRate());

  table = Waves.randomNHarms(16);

  amp1=0.5;
  amp2=0.5;
  ampENV=0.5;
  amp3=0.5;

  frecDelay=300;

  i1=1;
  i2=1;
  frec10=frec1/2;
  cortes=1;
  frec3=0;

  //atk=0.01;
  //dec=0.05;
  //rel=0.5;
  //sust=0.5;

  filtrobaixo=0;
  filtromedio=0;
  contadoron=0;
  contadorENV=0;
  contadornoise=0;
  loopactivate=0;

  visuals2=0;
  //OSCILADOR 1:
  wave = new Oscil( frec1, amp1, Waves.SINE );


  //OSCILADOR 2: 
  wave2 = new Oscil( frec2, amp2, Waves.SINE );

  
   //OSCILADOR 3: 
  wave3 = new Oscil( frec3, amp3, Waves.SINE );


  //ENVOLVENTE:
  ENV = new Oscil( frecENV, ampENV, Waves.SINE );
  ENV.patch( out );

  //NOISE:
  noise = new Oscil( 10, ampENV, table );
  noise.patch(out);
  noise.setAmplitude(0);

  //DELAY:

  delay = new Oscil(frecDelay, amp3, Waves.SINE );
  
  Waveform square = Waves.square( 0.9 );
  myLFO = new Oscil( 1, 0.3, square );



  //FILTRO:
  cutOsc = new Oscil(1, 800, Waves.SINE);
  cutOsc.offset.setLastValue( 1000 );
  cutOsc.patch(filt.cutoff);

  //SAMPLES PADS:
  pad1= minim.loadFile("808.mp3");
  pad2=minim.loadFile("kick.mp3");
  pad3=minim.loadFile("snare.mp3");
  pad4=minim.loadFile("percusion.mp3");
  pad5=minim.loadFile("clap.mp3");
  //pad6=minim.loadFile("");
  //pad7=minim.loadFile("");
  //pad8=minim.loadFile("");
//sample1=minim.loadSample("mp3.mp3");
//loop1=minim.loadFile("myrecording.wav", 2048);
loop1=minim.loadFile("myrecording.wav",1024);



  nbCubes = (int)(fft.specSize()*specHi);
  cubes = new Cube[nbCubes];
  murs = new Mur[nbMurs];

  for (int i = 0; i < nbCubes; i++) {
    cubes[i] = new Cube();
  }

  murs = new Mur[nbMurs];

  for (int i = 0; i < nbCubes; i++) {
    cubes[i] = new Cube();
  }

  for (int i = 0; i < nbMurs; i+=4) {
    murs[i] = new Mur(0, height/2, 10, height);
  }

  for (int i = 1; i < nbMurs; i+=4) {
    murs[i] = new Mur(width, height/2, 10, height);
  }

  //Murs bas
  for (int i = 2; i < nbMurs; i+=4) {
    murs[i] = new Mur(width/2, height, width, 10);
  }

  //Murs haut
  for (int i = 3; i < nbMurs; i+=4) {
    murs[i] = new Mur(width/2, 0, width, 10);
  }

}



//DRAW

void draw()
{
  background(0);
  //stroke(255);
  //strokeWeight(1);






  //ADORNOS


  fft.forward(out.mix);

  oldScoreLow = scoreLow;
  oldScoreMid = scoreMid;
  oldScoreHi = scoreHi;

  scoreLow = 0;
  scoreMid = 0;
  scoreHi = 0;

  for (int i = 0; i < fft.specSize()*specLow; i++)
  {
    scoreLow += fft.getBand(i);
  }

  for (int i = (int)(fft.specSize()*specLow); i < fft.specSize()*specMid; i++)
  {
    scoreMid += fft.getBand(i);
  }

  for (int i = (int)(fft.specSize()*specMid); i < fft.specSize()*specHi; i++)
  {
    scoreHi += fft.getBand(i);
  }

  if (oldScoreLow > scoreLow) {
    scoreLow = oldScoreLow - scoreDecreaseRate;
  }

  if (oldScoreMid > scoreMid) {
    scoreMid = oldScoreMid - scoreDecreaseRate;
  }

  if (oldScoreHi > scoreHi) {
    scoreHi = oldScoreHi - scoreDecreaseRate;
  }

  float scoreGlobal = 0.33*scoreLow + 0.4*scoreMid + 0.5*scoreHi;


  background(scoreLow/100, scoreMid/100, scoreHi/100);


  for (int i = 0; i < nbCubes; i++)
  {
    float bandValue = fft.getBand(i);
    cubes[i].display(scoreLow, scoreMid, scoreHi, bandValue, scoreGlobal);
  }

  float previousBandValue = fft.getBand(0);
  float dist = -25;
  float heightMult = 2;
  for (int i = 1; i < fft.specSize(); i++)
  {

    float bandValue = fft.getBand(i)*(1 + (i/50));

    stroke(100+scoreLow, 100+scoreMid, 100+scoreHi, 255-i);
    strokeWeight(1 + (scoreGlobal/100));

    /*
    line(0, previousBandValue, dist*(i-1), 0, bandValue, dist*i);
     line((previousBandValue), height, dist*(i-1), (bandValue), height, dist*i);
     line(0, height-(previousBandValue), dist*(i-1), (bandValue), height, dist*i);
     
     
     
     line(0, (previousBandValue*heightMult), dist*(i-1), 0, (bandValue*heightMult), dist*i);
     line((previousBandValue*heightMult), 0, dist*(i-1), (bandValue*heightMult), 0, dist*i);
     line(0, (previousBandValue*heightMult), dist*(i-1), (bandValue*heightMult), 0, dist*i);
     
     line(width, height-(previousBandValue*heightMult), dist*(i-1), width, height-(bandValue*heightMult), dist*i);
     line(width-(previousBandValue*heightMult), height, dist*(i-1), width-(bandValue*heightMult), height, dist*i);
     line(width, height-(previousBandValue*heightMult), dist*(i-1), width-(bandValue*heightMult), height, dist*i);
     
     line(width, (previousBandValue*heightMult), dist*(i-1), width, (bandValue*heightMult), dist*i);
     line(width-(previousBandValue*heightMult), 0, dist*(i-1), width-(bandValue*heightMult), 0, dist*i);
     line(width, (previousBandValue*heightMult), dist*(i-1), width-(bandValue*heightMult), 0, dist*i);*/

    previousBandValue = bandValue;
  }


  for (int i = 0; i < nbMurs; i++)
  {

    float intensity = fft.getBand(i%((int)(fft.specSize()*specHi+int(out.left.get(2)))));
    murs[i].display(scoreLow, scoreMid, scoreHi, intensity, scoreGlobal);
  }

  /*stroke( 128, 0, 0 );
   strokeWeight(4);
   for ( int i = 0; i < width-1; ++i )
   {
   point( i, height/2 - (height*0.49) * wave.getWaveform().value( (float)i / width ) );
   }*/







  /*  for (int i = 0; i < out.bufferSize() - 1; i=i+10)
   {
   stroke(frec1/6, 0, 255-frec2/6);
   noFill();
   ellipse(random(width), random(height), out.left.get(i)*60, out.left.get(i)*60);
   }*/




  //BOTÓN DE ENCENDIDO

  if (on == 0) {
    wave.setAmplitude( 0 );
    wave2.setAmplitude( 0 );
    wave3.setAmplitude( 0 );
  }
  if (on == 1) {
    wave.setAmplitude( amp1 );
    wave2.setAmplitude( amp2 );
    wave3.setAmplitude( amp3 );
  }

  if (ENVon == 0) {
    ENV.setAmplitude( 0 );
    fraseENV = "ENV: OFF";
  }

  if (ENVon == 1) {
    ENV.setAmplitude( ampENV );
    fraseENV = "ENV: ON";
  }
  
    if (loopactivate==1){
      if (!loop1.isPlaying()){
    loop1.play();
    println(loopactivate);
    loopactivate=loopactivate-1;
  }
    }
  if (loopactivate==1){
  if (loop1.isPlaying()){
    loop1.pause();
    loopactivate=loopactivate-1;
  }
  
    }
  



  //ARPEGIADORES
 
  /*if (arp1 ==0) {
    amp1=0.5;
  }
  if (arp2 ==0) {
    amp2=0.5;
  }*/




  if (arp1 ==1) {

    if (frameCount % int(beat/8) ==0) {
      i1=-i1;
      wave.setFrequency(frec10);
      veces=veces+1;
      if (veces<notas) {
        frec10=frec10*1.5;
      }

      if (veces == notas) {
        veces=0;
        frec10=frec1;
      }



      /*
      if (i1<0) {
       amp1=0;
       }
       
       if (i1>0) {
       amp1=0.5;
       }*/
    }
  }



  if (arp2 ==1) {

    if (frameCount % int(beat/8) ==0) {
      i2=-i2;
    }
    if (i2<0) {
      amp2=0;
    }

    if (i2>0) {
      amp2=0.5;
    }
  }



  if (arp1==0) {
    wave.setFrequency(frec1);
  }
  wave2.setFrequency(frec2);
  wave3.setFrequency(frec3);
  ENV.setFrequency(frecENV);
  
 
  
 

  if (visuals2%2==0) {
    pushMatrix();
    background(0, 100);
    rotY=frec1;
    translate(width/2, height/2, -5000);
    //rotX=mouseX/30;
    //rotY=mouseY/30;
    rotZ=0;
    noFill();
    stroke(255, 100);
    beginShape();

    for (theta=0; theta<=2*PI; theta+=0.05) {
      for (phi=0; phi<=PI; phi+=0.05) {
        float rad = r( theta, sust/10.0, rel/10.0, frecENV, atk, dec, phi);
        //POSIBLES PARAMETROS:
        //theta, sust/10.0, rel/10.0, frecENV, atk, dec, phi
        //
        x=rad*cos(theta)*50*sin(phi);
        y=rad*sin(theta)*50*sin(phi);
        z=rad*cos(phi)*50;
        vertex(x, y, z);

        //rotateX(rotX);
        rotateY(rotY*frameCount/10000000.0);
        //rotateZ(0);
      }
    }

    endShape();
    popMatrix();


    fill(255);

    
  }
  text("Sergio's Synthesizer", width-250, height-60);
    text(fraseOSC1, 40, 40);
    text(fraseOSC2, 40, 70);
    text(fraseOSC3, 40, 100);
    text(beat, 40, 220);
    text(fraseLPF, 40, 130);
    text(fraseENV, 40, 160);
    text(frasenoise, 40, 190);
    









  if ( recorder.isRecording() )
  {
    text("Recording...", 5, 15);
  } else
  {
    text("No recording", 5, 15);
  }
  //cbf.setFreq(cutoffFreq);
}




//POSIBILIDADE DE CONTROLAR PARAMETROS CO RATÓN:


/*void mouseMoved()
 {
 
 float amp = map( mouseY, 0, height, 1, 0 );
 wave.setAmplitude( amp );
 
 float freq = map( mouseX, 0, width, 110, 880 );
 wave.setFrequency( freq );
 
 }*/



//CAMBIOS NA FORMA DA ONDA

void keyPressed()
{ 


  switch( key )
  {
  case '1': 
    wave.setWaveform( Waves.SINE );
    fraseOSC1="OSC 1: SINE ";

    break;

  case '2':
    wave.setWaveform( Waves.TRIANGLE );
    fraseOSC1="OSC 1: TRIANGLE ";
    break;

  case '3':
    wave.setWaveform( Waves.SAW );
    fraseOSC1="OSC 1: SAW ";
    break;

  case '4':
    wave.setWaveform( Waves.SQUARE );
    fraseOSC1="OSC 1: SQUARE ";
    break;

  case '5':
    wave.setWaveform( Waves.QUARTERPULSE );
    fraseOSC1="OSC 1: PULSE ";
    break;


  case 'q': 
    wave2.setWaveform( Waves.SINE );
    fraseOSC2="OSC 2: SINE ";
    break;

  case 'w':
    wave2.setWaveform( Waves.TRIANGLE );
    fraseOSC2="OSC 2: TRIANGLE ";
    break;

  case 'e':
    wave2.setWaveform( Waves.SAW );
    fraseOSC2="OSC 2: SAW ";
    break;

  case 'r':
    wave2.setWaveform( Waves.SQUARE );
    fraseOSC2="OSC 2: SQUARE ";
    break;

  case 't':
    wave2.setWaveform( Waves.QUARTERPULSE );
    fraseOSC2="OSC 2: PULSE ";
    break;

  case 'z':
    // scale the table so that the largest value is -1/1.
    table.normalize();
    break;

  case 'x':
    // smooth out the table, similar to applying a low pass filter
    table.smooth( 64 );
    break;

  case 'c':
    // change all negative values to positive values
    table.rectify();
    break;

  case 'v':
    // noise

    table.addNoise( 0.1f );
    break;

  case 'b':
    table.scale( 1.1f );
    break;

  case 'n':
    table.scale( 0.9f );
    break;

  case 'd':
      
    myLFO.offset.setLastValue( 0.3 );
    myLFO.patch( delay.amplitude );
    delay.patch(myDelay).patch(out);

    break;
    
  case 'f':
  delay.unpatch(myDelay);
  myLFO.unpatch(out);
  
  break;

  case 'p':
    visuals2=visuals2+1;
    break;



  default: 
    break;
  }
}

void noteOn(int channel, int pitch, int velocity) {
  if (pitch == 40) {
    contadoron=contadoron+1;
       
  }

  if (pitch == 41) {
    contadorENV=contadorENV+1;
    if (contadorENV % 2 >0) {
      ENVon = 1;
      fraseENV = "ENV: ON";
    }
    if (contadorENV % 2 ==0) {
      ENVon = 0;
      fraseENV = "ENV: OFF";
    }
  }

  if (pitch == 57) {
    contadornoise=contadornoise+1;
    if (contadornoise %2>0) {
      noise.patch(out);
      frasenoise="NOISE: ON";
      // noise.patch(lpf);
    }
    if (contadornoise%2==0) {
      //noise.unpatch(lpf);
      noise.unpatch(out);
      frasenoise="NOISE: OFF";
    }
  }

  if (pitch == 37) {
    //wave.patch(cbf);
    //wave2.patch(cbf);
  }
  if (pitch == 42) { 
    filtrobaixo =filtrobaixo+1;
    if (filtrobaixo % 2 > 0) {
      wave.patch(lpf);
      wave2.patch(lpf);
      fraseLPF="LPF: ON";
    }
    if (filtrobaixo % 2 == 0) {
      wave.unpatch(lpf);
      wave2.unpatch(lpf);
      fraseLPF="LPF: OFF";
    }
  }

  if (pitch == 38) {
    filtromedio = filtromedio +1;
    if (filtromedio % 2 > 0) {
      wave.patch(filt);
    }
    if (filtromedio % 2 == 0) {
      wave.unpatch(filt);
    }
  }

  //PADS:
  if (pitch ==60 ) {
   pad1.play();
    pad1.rewind();
  }

  if (pitch == 62) {
    pad2.play();
    pad2.rewind();
  }

  if (pitch == 64 ) {
    pad3.play();
    pad3.rewind();
  }


  if (pitch == 65) {
    pad4.play();
    pad4.rewind();
  }


  if (pitch ==67 ) {
    pad5.play();
    pad5.rewind();
  }
    if (pitch ==72 ) {
    loop1.loop();
  }

    
    
println(pitch);
}

void noteOff(int channel, int pitch, int velocity) {
}

void controllerChange(int channel, int number, int value) {
  println(number);
  if (number == 1) {
    frec1= value*6;
  }

  if (number == 2) {
    frec2= value*6;
  }
  if (number == 3) {
    frecENV= value/13.0;
  }
    if (number == 4) {
    frec3= value*6;
  }
  
    if (number == 5) {
    amp1=value/255.0;
    amp2=value/255.0;
  }

  //atack
  if (number ==5) {
    cutoffFreq=value*10;
    atk=value;
  }

  //decay
  if (number ==6) {
    dec=value;
  }
  //release
  if (number ==7) {
    rel=value;
  }
  //sustain
  if (number ==8) {
    sust=value;
  }
}



//GRABACIÓN DO OUTPUT:
void keyReleased()
{
  if ( key == 'a' ) 
  {
    if ( recorder.isRecording() ) 
    {
      recorder.endRecord();
    } else 
    {
      recorder.beginRecord();
    }
  }
  if ( key == 's' )
  {

    recorder.save();
    println("Save.");
  }
}






class Cube {
  float startingZ = -10000;
  float maxZ = 1000;

  float x, y, z;
  float rotX, rotY, rotZ;
  float sumRotX, sumRotY, sumRotZ;

  Cube() {

    x = random(0, width);
    y = random(0, height);
    z = random(startingZ, maxZ);

    rotX = random(0, 1);
    rotY = random(0, 1);
    rotZ = random(0, 1);
  }
  void display(float scoreLow, float scoreMid, float scoreHi, float intensity, float scoreGlobal) {
    color displayColor = color(scoreLow*0.8+int(out.left.get(200)), scoreMid*0.5+int(out.left.get(50)), scoreHi*0.5, intensity*5);
    fill(displayColor, 50);

    color strokeColor = color(255, 150-(20*intensity));
    stroke(strokeColor);
    strokeWeight(1 + (scoreGlobal/300));

    pushMatrix();

    translate(x, y, z);

    sumRotX += intensity*(rotX/1000);
    sumRotY += intensity*(rotY/1000);
    sumRotZ += intensity*(rotZ/1000);

    rotateX(sumRotX);
    rotateY(sumRotY);
    rotateZ(sumRotZ);

    box(100+(intensity/2));

    popMatrix();

    z+= (1+(intensity/10)+(pow((scoreGlobal/200), 2)));

    if (z >= maxZ) {
      x = random(0, width);
      y = random(0, height);
      z = startingZ;
    }
  }
}

class Mur {
  float startingZ = -10000;
  float maxZ = 50;

  float x, y, z;
  float sizeX, sizeY;

  Mur(float x, float y, float sizeX, float sizeY) {
    this.x = x;
    this.y = y;
    this.z = random(startingZ, maxZ);  

    this.sizeX = sizeX;
    this.sizeY = sizeY;
  }
  void display(float scoreLow, float scoreMid, float scoreHi, float intensity, float scoreGlobal) {
    color displayColor = color(scoreLow*0.67, scoreMid*0.67, scoreHi*0.67, scoreGlobal);

    fill(displayColor, ((scoreGlobal-5)/1000)*(255+(z/25)));
    noStroke();

    pushMatrix();

    translate(x, y, z);

    if (intensity > 100) intensity = 100;
    scale(sizeX*(intensity/100), sizeY*(intensity/100), 20);

    box(1);
    popMatrix();

    displayColor = color(scoreLow*0.5, scoreMid*0.5, scoreHi*0.5, scoreGlobal);
    fill(displayColor, (scoreGlobal/5000)*(255+(z/25)));
    pushMatrix();

    translate(x, y, z);

    scale(sizeX, sizeY, 10);

    box(1);
    popMatrix();

    z+= (pow((scoreGlobal/150), 2));
    if (z >= maxZ) {
      z = startingZ;
    }
  }
}



float r(float theta, float n1, float n2, float n3, float a, float b, float phi) {

  return pow(pow(abs(cos(theta)/a), n1)+pow(abs(sin(theta)/b), n2), -1/n3);
}


  
