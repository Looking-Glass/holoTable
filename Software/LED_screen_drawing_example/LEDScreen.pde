import processing.serial.*;
Serial port;

//this has to match the arduino baudrate.  Otherwise, great sadness
int baudrate=1000000;

void initPort()  //this is a function floating in the parent class because I'm too dumb to figure out inheritance and *this*
{
  port=new Serial(this, Serial.list()[Serial.list().length-1], baudrate);
}

class Screen {
  color[][] screen;
  int packetLength=48;
  int rowsPerPacket;
  int LEDWidth, LEDHeight;
  boolean freeToSend=true;

  Screen(int _LEDWidth, int _LEDHeight)
  {
    initPort();
    LEDWidth=_LEDWidth;
    LEDHeight=_LEDHeight;
    screen=new color[LEDWidth][LEDHeight];
    rowsPerPacket=packetLength/LEDWidth;
    println(Serial.list());
    port.bufferUntil(13);
  }

  //clears the LED screen
  void clear()
  {
    for (int x=0; x<LEDWidth; x++)
      for (int y=0; y<LEDHeight; y++)
        screen[x][y]=color(0);
  }


  void update()  //sends new data out to the screen
  {
    if (freeToSend)
      writePacket(0);
  }

  //manually sets a given pixel in the LED screen
  void setPixel(int x, int y, color col)
  {
    if ((x>=0)&&(x<LEDWidth))
      if ((y>=0)&&(y<LEDHeight))
        screen[x][y]=col;
  }
  void setPixel(float x, float y, color col)
  {
    setPixel((int)x, (int)y, col);
  }

  //draws the computer screen into the LED screen
  void showScreen()
  {
    PImage img=get(0, 0, width, height);  //get the screen's graphics buffer as PImage
    showImage(img);
  }

  //draws any PImage into the LED screen
  void showImage(PImage img)
  {
    clear();

    //tries to fill more of the screen, if the image isn't square
    if (img.width>img.height)
      img.resize(LEDWidth, 0);
    else
      img.resize(0, LEDHeight);
    img.loadPixels();
    for (int x=0; x<img.width; x++)
      for (int y=0; y<img.height; y++)
        setPixel(x, y, img.pixels[y*img.width+x]);
  }


  void draw()
  {
    stroke(128);
    strokeWeight(3);
    for (int x=0; x<LEDWidth; x++)
      for (int y=0; y<LEDHeight; y++)
      {
        fill(screen[x][y]);
        rect((width-height)/2+x*height/LEDWidth, y*height/LEDHeight, height/LEDWidth, height/LEDHeight);
      }
  }

  void writePacket(int state)
  {
    freeToSend=false;
    int x, y;
    for (y= (state*rowsPerPacket); (y<(state+1)*rowsPerPacket)&&(y<LEDHeight); y++)
      for (x=0; x<LEDWidth; x++)
      {
        color col=screen[x][y];
        byte val=(byte)(((int)red(col))&0xE0 | (((int)green(col))>>3)&0x1C | (((int)blue(col)) >> 6));
        port.write(val);
      }
    if (state==((LEDWidth*LEDHeight)/packetLength))
    {
      delay(1);
      freeToSend=true;
    }
  }
}


void serialEvent(Serial p) { 
  String str = p.readString(); 
  str=str.trim();
  String[] parts=str.split("-");
  screen.writePacket(int(parts[0]));
} 

