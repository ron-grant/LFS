// UserCon - user controller code, read sensors, possibly decode features, update speed and turn rate
// added     setEnableController(false); //  to UMisc  userOutOfBounds
// Also, performing sensor coloring with call from userMiscUpdate to insure sensors colored when controller OFF


// note below values are defined and overridden in UPar tab

float speedClear = 6;      // inches/sec   robot speed when line not visible on either sensor  
float speedTurn  = 3;      // inches/sec   speed when turning 
float turnRate   = 360;    // deg/sec
float sensorGap  = 2;      // inches    


String controllerMessageString = "controller message"; // UPanel has code that displays this string, updated below
   
int updateCount;                                   

void userControllerUpdate ()    // this method called every time step 
{
  // LFS has optional facility for saving robot state in RobotState class 
  RobotState cs = currentRobotState;    // get shorthand reference to current state
  cs.sampleCounter = updateCount++;     // example access to current RobotState with short name.  
  
  // a little automation of dimming when running looped time warp
  if (timeWarp && loopMode && (timeWarpMult>100)) {
    iconOpacity = 0.1;              //  see UPar  sets icon opacity via lfs.RobotIconAlpha
    dimCourseViewIndex = 1;         //  0=OFF to  5=BRIGHT
    dimRobotViewIndex  = 1;    
  }
  
  
  
  
  float sL = sensorL.read();   // read left sensor 
  float sR = sensorR.read();   // read right sensor 
 
  float tr = 0;  // turn rate 
  float sp = 0;  // speed 
 
  if ((sL>0.5) && (sR>0.5))    // both Left AND Right sensor see white 
    sp = speedClear;
    
  if (sL<0.5) {sp=speedTurn; tr = -turnRate; }  // turn left 
  if (sR<0.5) {sp=speedTurn; tr = +turnRate; }  // turn right      
 
  lfs.setTargetTurnRate(tr);
  lfs.setTargetSpeed (sp);
  
  sensorL.setYoff(-sensorGap/2);   // set sensor positions (inches) on the fly, negative Y to left of robot center 
  sensorR.setYoff(sensorGap/2);   
  

}


void userControllerColorSensors() // update coloring of sensors called from userControllerUpdate
                                  // Would really like this to be called by LFS to allow sensor coloring 
                                  // when robot is being dragged around without controller enabled 
                                  // for now, achieving this with inclusion in userMiscUpdate
{
  // if sensor coloring depends on your controller state, then this code would need to be moved into your 
  // controller and this method left empty
  
  if (sensorL.read() > 0.5) sensorL.setColor (color(0,0,100));   // update spot sensors based on how they are interpreted
  else sensorL.setColor(color(255,0,0));                         // left sensor show as binary color 
  
  int inten = (int) (sensorR.read()*255.0);                      // scale 0 to 1.0  to  0 to 255
  sensorR.setColor(color(inten,inten,inten));                    // set RGB color to intensity
  
  sensorR.setColor (color(inten));
  
}
