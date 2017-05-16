int calibState=0;
boolean calibrating=false;
PVector pos, calibratedPos;
PVector topRight, bottomLeft, topRightScreen, bottomLeftScreen;
boolean calibrated=false;
boolean shiftPressed=false;

MouseHandler mh;

void initMouseHandler()
{
  mh=new MouseHandler(this);
}

void initCalibration()
{
  initMouseHandler();
  topRight=new PVector(width, 0);
  bottomLeft=new PVector(0, height);
  topRightScreen=new PVector(width, 0);
  bottomLeftScreen=new PVector(0, height);
  loadCalibration();
  calibratedPos=new PVector(0, 0);
  pos=new PVector(0, 0);
}
void calib()
{
  fill(255);
  textSize(100);

  String msg="";
  if (calibState==0)
  {
    screen.clear();
    if (shiftPressed)
      topRightScreen=new PVector(mouseX, mouseY);
    fill(255, 0, 0);
    ellipse(width, 0, 200, 200);
    msg="top right";
  }
  if (calibState==1)
  {
    screen.clear();
    if (shiftPressed)
      bottomLeftScreen=new PVector(mouseX, mouseY);
    fill(255, 0, 0);
    ellipse(0, height, 200, 200);
    msg="bottom left";
  }
  text(msg, (width-textWidth(msg))/2, (height-100)/2);
}

void loadCalibration()
{
  try {
    String lines[] = loadStrings(dataPath("calibration.txt"));
    String[] parts=lines[0].split(",");
    bottomLeft=new PVector(int(parts[0]), int(trim(parts[1])));
    parts=lines[1].split(",");
    bottomLeftScreen=new PVector(int(parts[0]), int(trim(parts[1])));
    parts=lines[2].split(",");
    topRight=new PVector(int(parts[0]), int(trim(parts[1])));
    parts=lines[3].split(",");
    topRightScreen=new PVector(int(parts[0]), int(trim(parts[1])));
        
    println("bottom left: "+bottomLeft);
    println("top right: "+topRight);
    println("bottom left screen: "+bottomLeftScreen);
    println("top right screen: "+topRightScreen);
    calibrated=true;
  }
  catch(Exception e) {
    println("oooh, dearie me");
  }
}


void writeCalibration()
{
  println("writing calibration");
  print("top right:   ");
  println(topRight);
  print("bottom left: ");
  println(bottomLeft);
  print("top right screen:  ");
  println(topRightScreen);
  print("bottom left screen:  ");
  println(bottomLeftScreen);
  PrintWriter output=createWriter(dataPath("calibration.txt"));
  output.println(bottomLeft.x+", "+bottomLeft.y);
  output.println(bottomLeftScreen.x+", "+bottomLeftScreen.y);
  output.println(topRight.x+", "+topRight.y);
  output.println(topRightScreen.x+", "+topRightScreen.y);
  output.flush();
  output.close();
}

void keyPressed()
{

  if (calibrating)
  {
    if (key==' ')
    {
      if (calibState==0)
      {
        topRight=pos;
        calibState=1;
      } else if (calibState==1)
      {
        bottomLeft=pos;
        calibState=0;
        calibrating=false;
        writeCalibration();
        calibrated=true;
      }
    }
  }
  if (key=='c')
    calibrating=true;
  if (keyCode==SHIFT)
    shiftPressed=true;
}
void keyReleased()
{
  if (keyCode==SHIFT)
    shiftPressed=false;
}




public class MouseHandler {
  PApplet p = null;

  public MouseHandler(PApplet papp) {
    p = papp;
    p.registerMethod("mouseEvent", this);
  }

  public void mouseEvent(MouseEvent e) {
    pos=new PVector(mouseX, mouseY);
    calibratedPos=new PVector(map(pos.x, bottomLeft.x, topRight.x, bottomLeftScreen.x, topRightScreen.x), map(pos.y, bottomLeft.y, topRight.y, bottomLeftScreen.y, topRightScreen.y));
    //println(calibratedPos);
  }
}

