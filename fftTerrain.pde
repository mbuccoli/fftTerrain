

import ddf.minim.*;
import ddf.minim.analysis.*;
import javax.swing.*; 

Minim minim;

// GLOBAL VARIABLES
// variables for song/mic etcetera
boolean song_mic=true;
boolean allScreen=true;
float maxVal=300;
float minVal=-100;

FFT fft;
AudioPlayer song;
AudioInput mic;
int fR=45;
// Frame length
int frameLength = 1024;
int specSize=frameLength/4;
int specDown=2;
float[] spectrum=new float[specSize/specDown];

int Hc, Sc;
float count=0;
double freqH=2*Math.PI/120;
double freqS=2*Math.PI/60;

// variables for canvas 
int canvasWidth=0;
int canvasHeight=0;


// other variabels for plotting
  
int refresh=1; // multiple of  
int featWin = refresh*5;

  
  
int cols, rows;
int scl = 20;
int w = 500;//2000;
int h = 1600;

float flying = 0;

float[][] terrain;
  

void setup()
{
  if(allScreen){
    canvasWidth = 1920;
    canvasHeight = 1080;}
  else{
    canvasWidth = 1024;//1200;
    canvasHeight = 768;//740; 
  }
  
  size(1920, 1080, P3D);
  background(0);
  smooth();
  frameRate(fR);
  minim = new Minim(this);

  if(song_mic){   
    song = minim.loadFile("sample.mp3",frameLength);
    song.play();
    fft = new FFT(song.bufferSize(), song.sampleRate());
  
    
    }
  else{
    // Mic input    
    mic = minim.getLineIn(Minim.MONO, frameLength);
    fft = new FFT(mic.bufferSize(), mic.sampleRate());
    //beat= new BeatDetect(mic.bufferSize(), mic.sampleRate());
    
    }

   fft.window(FFT.HAMMING);
    
    cols = specSize/specDown;//w / scl;
    rows=80;
    w=scl*cols;
    h=scl*rows;
    //rows = h/ scl;
    terrain = new float[cols][rows];
    Hc=0;
    Sc=0;    
}

void getTerrain(){
  
  for (int y = 0; y < rows-1; y++) {    
    //for (int x = 1; x < cols; x++) {
    for (int x = 0; x<cols; x++) {  
      terrain[x][rows-1-y] = terrain[x][rows-y-2];     
    }
  }
  
  for (int x = 0; x < cols; x++) {
    terrain[x][0]=spectrum[x];    
  }
  
  
}


void getSpectrum(){
  
  
  for(int i = 0; i < specSize; i++)
  {
    float val=fft.getBand(i);
    int j=i%specDown;
    int k=(int)Math.floor(1.0*i/specDown);    
    if (j==0){spectrum[k]=0;}
    spectrum[k] += map((float)Math.log10(val+1), 0, 5, minVal, maxVal);
  }
  
}
void plotTerrain(){
  Hc=int(Math.round(50*Math.cos(count*freqH)));
  Sc=int(Math.round(55+15*Math.cos(count*freqS)));
  colorMode(HSB, 100);
  stroke(Hc,Sc,255);
  
  noFill();

  translate(width/2, height/2+50);
  rotateX(PI/3);
  translate(-w/2, -h/2);
  for (int y = 0; y < rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      vertex(x*scl, y*scl, terrain[x][y]);
      vertex(x*scl, (y+1)*scl, terrain[x][y+1]);
      //rect(x*scl, y*scl, scl, scl);
    }
    endShape();
  }
}


void draw() {  
  if(song_mic){
    fft.forward(song.mix);       
  }
  else{
      fft.forward(mic.mix);
  }
  background(0);
  
  getSpectrum();
  getTerrain();
  plotTerrain();
  count=count+1.0/fR;
}





 