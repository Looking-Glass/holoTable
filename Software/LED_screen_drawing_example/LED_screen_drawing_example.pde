Screen screen;

void setup()
{
  size(500, 500);  //definitely initialize the sketch size *before* the airbar calibration.  Otherwise, great sadness
  screen=new Screen(16, 16);
  initCalibration();  //loads the airbar calibration from a file(if available) and sets up the mouse handler
} 

void draw()
{
  background(0);
  if (calibrating)
    calib();
    fill(0,255,0);
  ellipse(calibratedPos.x, calibratedPos.y,100,100);
  screen.showScreen();
  screen.update();
}

