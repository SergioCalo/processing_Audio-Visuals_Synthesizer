

class ControlFrame extends PApplet {
  int w, h;
  PApplet parent;
  ControlP5 cp5;
  AudioOutput out;

  public ControlFrame(PApplet _parent, int _w, int _h, String _name, AudioOutput out) {
    super();   
    parent = _parent;
    w=_w;
    h=_h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w, h);  
  }

  public void setup() {
   surface.setLocation(10, 10);
   cp5 = new ControlP5(this);
   minim = new Minim(this);
   out = minim.getLineOut();
   //loop1=minim.loadFile("C:\\Users\\Sergio\\Desktop\\sintetizador\\myrecording.wav", 2048);

   
   cp5.addSlider("Frec OSC 1 (Hz)").plugTo(parent, "frec1").setRange(20., 1000.).setValue(200).setPosition(30, 70).setSize(200, 20);  
   cp5.addSlider("Frec OSC 2 (Hz)").plugTo(parent, "frec2").setRange(20., 1000.).setValue(400).setPosition(30, 100).setSize(200, 20); 
   cp5.addSlider("Frec OSC 3 (Hz)").plugTo(parent, "frec2").setRange(0., 10000.).setValue(0).setPosition(30, 130).setSize(200, 20);
   cp5.addSlider("Frec ENV (Hz)").plugTo(parent, "frecENV").setRange(0., 10.).setValue(5.).setPosition(350, 250).setSize(200, 20); 
   
   
   cp5.addSlider("Time").plugTo(parent, "beat").setRange(20., 250.).setValue(120).setPosition(30, 200).setSize(100, 15); 
   
   //cp5.addToggle("ON/OFF").plugTo(parent, "on").setValue(false).setPosition(30, 10).setSize(40,40);
   cp5.addToggle("arp OSC 1").plugTo(parent, "arp1").setValue(false).setPosition(350, 70).setSize(30,30);
   cp5.addToggle("arp OSC 2").plugTo(parent, "arp2").setValue(false).setPosition(450, 70).setSize(30,30);
   cp5.addSlider("num notes").plugTo(parent, "notas").setRange(1, 5.).setValue(1).setPosition(350, 120).setSize(200, 15); 
   cp5.addToggle("ENV").plugTo(parent, "ENVon").setValue(false).setPosition(350, 200).setSize(30,30);
   //cp5.addToggle("LPF").plugTo(parent, "filtrobaixo").setValue(false).setPosition(400, 200).setSize(30,30);
   cp5.addKnob("n1").plugTo(parent, "sust").setRange(0,100).setValue(35).setPosition(80, 360).setSize(40,40);
   cp5.addKnob("n2").plugTo(parent, "rel").setRange(0,150).setValue(30).setPosition(130, 360).setSize(40,40);
   cp5.addKnob("a").plugTo(parent, "atk").setRange(0,150).setValue(150).setPosition(180, 360).setSize(40,40);
   cp5.addKnob("b").plugTo(parent, "dec").setRange(0,150).setValue(120).setPosition(230, 360).setSize(40,40);
   cp5.addButton("LPF").setValue(0).setPosition(400, 200).setSize(30,30);
   cp5.addButton("noise").setValue(0).setPosition(450, 200).setSize(30,30);
   cp5.addButton("loop").setValue(0).setPosition(500, 200).setSize(30,30);
   cp5.addButton("loopoff").setValue(0).setPosition(550, 200).setSize(30,30);
   cp5.addButton("on").setValue(0).setPosition(30, 10).setSize(40,40);
   
 
}

void draw() {
   //La ventana de la GUI tendrá el fondo negro
    background(0);
    text("VISUALS", 40, 330);
    stroke(255);
  for(int i = 0; i < out.bufferSize() - 1; i++)
  {
    line( i, 520  - out.left.get(i)*50,  i+1, 520  - out.left.get(i+1)*50 );
  }
  


  }
    public void on(){
          contadoron=contadoron+1;
           if (contadoron % 2 >0) {
      wave.patch( out );
      wave2.patch( out );
      wave3.patch( out );
    }
    if (contadoron % 2 ==0) {
      wave.unpatch( out );
      wave.unpatch( out );
      wave.unpatch( out );
    }
    
    
    
    
    
    if (contadoron % 2 >0) {
      on = 1;
    }
    if (contadoron % 2 ==0) {
      on = 0;
    }
}


  public void LPF(){
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
public void noise(){
  contadornoise=contadornoise+1;
    if (contadornoise %2>0) {
      noise.setAmplitude(0.5);
      // noise.patch(lpf);
      frasenoise="noise: ON";
    }
    if (contadornoise%2==0) {
      //noise.unpatch(lpf);
      noise.setAmplitude(0);
      frasenoise="noise: OFF";
    }
}
public void loop(){
  loopactivate=loopactivate+1;
  println(loopactivate);
}
public void loopoff(){
  loopactivate=loopactivate-1;
  println(loopactivate);
}


}
