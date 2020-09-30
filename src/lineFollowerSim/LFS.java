
/*  Line Following Simulation LFS
*   No package header comment support in javadocs... 
*
*courseImage 64 DPI rendition of course 6x12 tiles + 1/2 tile borders for total 7x13 foot course area  
*tiles are 12x12 inches (12x64 x 12x64 pixels = 768x768 pixels)
*total image size of 7x13 foot area is (5376 x 9984 pixels)
*
*
*Note on warning compiling this projet  getting 
*warning: [path] bad path element "c:\sketches\libraries\toxiclibs\library\tools.jar": no such file or directory
    [javac] 1 warning
*
*classpath settings in the MANIFEST files inside jar files is source of message.
*So essentially, Jars can have files inside them that point to other classes and jars located elsewhere and when
*those other things they point to don't exist, you see warnings like this
* 
*These warnings are coming out of Jar files that are on the compilation classpath.
*The problem jar file(s) -  remove the "Class-Path" settings in their manifest files and recreate them. 
*
*
*
*/

package lineFollowerSim;


import processing.core.*;
import java.io.BufferedWriter;
import java.io.PrintWriter;
import java.io.FileWriter;
import java.io.File;
import java.io.IOException;


/** LFS Class is Line Follower Simulator main class that handles:
 * 
 *  <ul>
 *  <li> tracking the position and heading of a virtual robot based on user specified target speed and turn rate</li>
 *  <li> generating the view of the robots immediate surroundings</li>
 *  <li> reading sensor values from user defined spot and line sensors</li> 
 *  <li> presentation of an image of the course with cookie crumb trail tracking progress of robot</li>
 *  </ul>
 *  <p>
 *  Using LFS features, user controller code reads sensor data, updates internal state, and finally sets robot target speed and turn rate. 
 *  The "internal state" being the fun bit. This is where things get interesting in the case of a complex line following course such as
 *  the Dallas Personal Robotics Group (dprg.org) Challenge Course where there are a number of different course features.
 * <p>
 *  During contest run, robot location and heading queries (e.g. getRobotHeading() ) are unavailable. User may
 *  implement their own odometry, but the simulation is not 
 *  guaranteed to be free from deliberate introduction of some error. For example there may be some errors
 *  introduced in speed control and turn rate control
 *  beyond errors introduced due to finite time step and limited numerical precision.
 *  <p>
 * Note that several methods documented are not called by user code. These are highlighted by 
 * <p>
 * (Called by simulation core code.) 
 *  @author Ron Grant
 */  

public class LFS  {

//private String Version = "Sep 14 2020";	

View view;
private PApplet p;     // reference to current applet (processing sketch using this lib)


Robot robot;           // single instance of robot class - accessed only from this 
                       // class  -- user must rely on this class' get/set methods 

/**
 *  Sensors class single instance - gives access to spot and line sensor lists.
 */
public Sensors sensors;  
/**
 * Contest run report appended to this file. If fields added and header does not match data. Copy file as needed and delete.
 * New column header will be created on next contest run.
 */
public String simContestFilename = "contest.cdf";

/**
 * When false, may speed up frame rate on some systems.
 * An alternative is to draw sensor info over robot view.
 */
public boolean showSensorsOnSensorView = true;

public void setShowSensorsOnSensorView(boolean show)
{ sensors.showSampledPixels = show; }

/** User first name supplied by call to setFirstNameLastNameRobotName
 */
public String nameFirst;
/** User last name supplied by call to setFirstNameLastNameRobotName
 */
public String nameLast ;
/** User robot name supplied by call to setFirstNameLastNameRobotName
 */
public String nameRobot;                 // client supplied names (NAMES command)



private PGraphics rv; // robot view at 64 DPI


int  headingChangeX = -999; // used to log mouseX on right mouse press and hold and drag in X to change heading
float headingChangeStart;   // used to log robot heading upon right mouse press

//mouse drag robot while in robot view state vars
int startDragX = -999;
int startDragY;

float startDragLocX,startDragLocY;

boolean drawRobotCoordAxes = true;   // show robot coordinate axes   
                                 
int stopwatchTick;                 // run time in delta time counts   !!! public for now 
int contestResetCount=0;

boolean controllerEnabled = false;     // setcontrollerEnabled(t/f)   getcontrollerEnabled()                                
                     
                               
private PImage course;           // courseImage 64 DPI rendition of course - see header comment
private String courseFilename;

/** 
 * course resolution in dots/inch, Standard (default) value is 64. 
 */
public int courseDPI = 64;       // default  can override 


// simulation imposed min/max

private float maxAcc      = 64.0f;    // inches/sec^2
private float maxDecel    = 64.0f;
private float maxTurnAcc  = 720.0f;    // deg/sec^2
private float maxSpeed    = 36.0f;
private float maxTurnRate = 720.0f;

private float minTimeStep = 0.01f;     // 100Hz
private float maxTimeStep = 0.1f;      // 10Hz     suggest 20Hz  (0.05) minimum 

private float userMaxSpeed;            // user had informed us of max speeds. 
private float userMaxTurnRate;         // saturate at simulation max values, and warn

private float timeStep;                // simulation time step subject to user limits

private int rvCount = 1;
private int cvCount = 1;

private int requestScreenSaveInFrameCount  = -1;

enum ContestStates {csIdle,csStop,csRun,csResetRequest,csFinished};
ContestStates contestState = ContestStates.csIdle;



 /** 
 *   
 * @param parent     reference to processing applet (PApplet) creating instance of LFS. "this" specified by caller
 * One instance of LFS should be created in your program. For example in the Processing setup
 * method include the line:
 * <p>
 * lfs = new LFS(this);
 * 
 */
public LFS (PApplet parent)
{ p=parent;

  System.out.println("##library.name## ##library.prettyVersion## by ##author##");

  robot = new Robot(parent,0,0,0);  // pos heading set later 
  sensors = new Sensors(parent);    // single instance of sensors 
   
  view = new View (parent);
  view.defineRobotViewport(40,40,400,400);
  view.defineCourseViewport(480,40,1200,800);
  
  // FOR now ORIGIN AT 0,0 -- will need to modify SpotSensor.sampleSensorPixel      should rename to sampleSensorSpot?
  
  view.defineSensorViewport(0,0,800,800);       // placed under robot view -- possibly blanked out or dimmed out  -- this view is 
                                                // required for sensors.  !!! variable size 
  
  nameFirst = "";
  nameLast = "";
  nameRobot = "";
  
  timeStep = 0.01667f;
  
}

/**
 * Enable or Disable user robot controller 
 * @param enable Set true to enable user controller, false to disable. 
 */
public void setEnableController(boolean enable)
{
    if (!enable) {                            
    	if (contestState == ContestStates.csRun) contestState = ContestStates.csStop;     // disable controller - make sure contest not running
    	else contestState = ContestStates.csIdle;
    }
	controllerEnabled = enable;
}

/** 
 * Get contest state as char Idle-I Stop-S Run-R Finish-F
 * @return contest state as character 
 * 
 */
public char getContestState()
{
	//{csIdle,csStop,csRun,csResetRequest,csFinished};
	//ResetRequest intended as state allowing robot to be moved by judge and restarted
	
	char c = ' ';
	switch (contestState) {
	case csIdle     :  c = 'I'; break;
	case csStop     :  c = 'S'; break;
	case csRun      :  c = 'R'; break;      
	case csFinished :  c = 'F'; break;
	case csResetRequest : c = 'X'; break;   // Reset Request may not be supported 
	}
	
	return c;
}

/** 
 * Get contest state name string   Idle Stop Run Finish Reset (if implemented)
 * @return contest state name string  
 * 
 */
public String getContestStateName()
{
	//{csIdle,csStop,csRun,csResetRequest,csFinished};
	//ResetRequest intended as state allowing robot to be moved by judge and restarted
	
	String s = "undefined";
	switch (contestState) {
	case csIdle     :  s = "Idle"; break;
	case csStop     :  s = "Stop"; break;
	case csRun      :  s = "Run"; break;      
	case csFinished :  s = "Finish"; break;
	case csResetRequest : s = "Reset"; break;   // Reset Request may not be supported 
	}
	
	return s;
}


/**
 * Determine if user controller is enabled. If not, userControllerUpdate() should not be called.
 * This is currently the responsibility of the sketch main tab code to implement this rule.
 * @return true if controller is enabled
 */
public boolean controllerIsEnabled() { return controllerEnabled; }

/** Setup coordinate transformations and scale factors required for optional user code (userDraw method) to draw
 * overlay graphics on robot view.
 * 
 */
public void setupUserDraw() 
{
  view.setupUserDraw();
}

/**
 * Alter the default course scale of 64 dots per inch (DPI). Designing courses with larger DPI values will result in larger couse bitmaps 
 * which may cause problems if GPU hardware/memory is not able to handle very large texture maps (bitmaps). 
 * Smaller values may result in difficulty resolving features, but also would increase performance, i.e., simulation frame rate.
 * @param dpi Dots per inch of course image, should match course image design scale, e.g. export resolution off application creating / editing course.
 */
public void setCourseDPI(int dpi)
{
	view.setCourseDPI(dpi);
	courseDPI = dpi;
}

/** Define robot view display region in screen coordinates. This viewport is  
 *  scaled version of 64 DPI frame buffer rendered for robot sensor pixel sampling. 
 *  <p> 
 *  TBD - might be requirement that aspect ratio is maintained. Might consider only width
 *  parameter with auto calculation of height if this is the case. - RDG Sept 19, 2020.
 * <p>
 * (Called by simulation core code) 
 * 
 * @param x          upper left corner x
 * @param y          upper left corner y
 * @param width      viewport width 
 * @param height     viewport height 
 */

public void defineRobotViewport (int x, int y, int width, int height)  
{
	view.defineRobotViewport (x,y,width,height);  
}	
	

/** Define course view display region in screen (pixel) coordinates.
 * 
 * @param x        upper left corner x
 * @param y        upper left corner y 
 * @param width    viewport width 
 * @param height   viewport height 
 */

public void defineCourseViewport (int x, int y, int width, int height)  
{
  view.defineCourseViewport (x,y,width,height); 	
}
 


/** Draw internal bitmap of robot proximity and update sensor data values. Called from draw() at each simulation step.
 * <p>
 * (Called by simulation core code.) 
 * @param r Red color channel 0..255
 * @param g Green color channel 0..255
 * @param b Blue color channel 0..255
 * @param a Alpha opacity 0..255 (0=transparent .. 255 = opaque)
 * 
 */
// public void updateSensors (PApplet.color c)
public void updateSensors(int r, int g, int b, int a)
{
  view.drawSensorView(course,robot,courseDPI);  // for now VP  at 0,0  Sept 22  !!!
  view.sensorUpdate(sensors,courseDPI);
                                                       // draws into screen frame buffer now - fast
  view.coverSensorView(r,g,b,a);                    // rgb,alpha
 
  
  
  
}


/**
 * Clear both spot and line sensor lists. Generally speaking this operation would not be required, but is performed
 * before robot is reset and run. Where sensor definitions are re-instated via call to userInit() which sould contain
 * sensor initialization code. 
 */
public void clearSensors()              { sensors.clear();    }

/**
 *    Draw robot view and course views to screen. 
 *    Divider variable 0=disable view, 1= draw every frame, 2 = every other frame (every two draw() calls),
 *    3 every third frame (draw() call)... This allows throttling view updates which may be helpful
 *    if graphics performance is limited. The robot view is always rendered to an internal 
 *    bitmap at fixed 64 DPI resolution to be available for spot and line sensor sample acquisition for each
 *    simulation time step.
 *    
 *    If either "div" value is greater than one this will be temporarily overridden whenever
 *    either mouse button is pressed to facilitate better animation of robot drag or rotation, especially
 *    if either value is set to large number e.g. (2,30) where course view is being updated very infrequently.
 *<p>
 * (Called by simulation core code.)  
 * @param rvDiv  Robot view divider    0=disable 1=every draw() 2=every two draw() calls, 3=...
 * @param cvDiv  Course view divider   0=disable 1=every draw() 2=every two draw() calls, 3=...
 * @param cRotate90 Rotate course 90 if true 
 */

public void drawRobotAndCourseViews(int rvDiv, int cvDiv, boolean cRotate90) // divisors
{
  if (rvDiv!=0)
  {	
	if (p.mousePressed) rvCount = 1;  
	if (--rvCount<= 0)
	{ rvCount = rvDiv;	
      view.drawRobotView(course,courseDPI,robot,contestIsRunning());   // draw robot view into defined viewport
	}  
  }
  
  if (cvDiv!=0)
  {	
	if (p.mousePressed) cvCount = 1;   
	if (--cvCount<=0)
	{ cvCount = cvDiv;
	  view.drawCourseView(course,robot,courseDPI,cRotate90, contestState == ContestStates.csFinished,
	  contestIsRunning());   // contest Finished draw (F) on course 
	}  
  } 
  
}



/**
 * Specify robot acceleration rate in inches/sec^2 units. Used when new target speed is greater than current speed.
 * That is, per simulation timestep (dt) speed = speed + acc * dt, where speed is in inches/sec units.
 * @param acc	acceleration rate 
 */
public void setAccRate(float acc)    // acceleration rate (inches/sec^2)
{
	if (acc>maxAcc)
	{ acc = maxAcc;
	  PApplet.println (String.format("Warning, setAccRate maxAcc exceeded, using max value %1.1f",acc)); 
	}
	robot.acclRate = acc;

}

/**
 * Specify robot deceleration rate in inches/sec^2 units. Used when new target speed is less than current speed.
 * That is, per simulation timestep (dt) speed = speed - dcel * dt, where speed is in inches/sec units.
 * @param dcel	deceleration rate 
 */
public void setDecelRate(float dcel)  // deceleration rate (inches/sec^2)
{
	if (dcel>maxDecel)
	{ dcel = maxDecel; 
	  PApplet.println (String.format("Warning, setDcelRate maxDcel exceeded, using max value %1.1f",dcel));
	}  
	robot.declRate = dcel;
}
/**
 * Specify robot turn rate acceleration and deceleration rates in degrees/sec^2 units used when new target
 * turn rate is less or greater than current turn rate. For example,
 * new turnRate greater than current turRate, per simulation time step (dt),  turnRate = turRate + turnAcc*dt
 * Likewise if new turnRate is less than current,  turnRate = turnRate-turnAcc*dt. In each case overshoot or 
 * undershoot of targetTurnRate is corrected such that turnRate equals targetTurnRate.    
 *
 * @param turnAcc turn acceleration/deceleration rate in degrees/sec^2
 * 
 *  Note: unlike drive speed, turn acceleration and deceleration is symmetrical (equal values).
 */
public void setTurnAcc(float turnAcc)   // below setMaxSpeed and setMaxTurnRate are for informational purposes only
{
	if (turnAcc>maxTurnAcc)
	{ turnAcc = maxTurnAcc; 
	  PApplet.println (String.format("Warning, setTurnAccRate maxTurnAcc exceeded, using max value %1.1f",turnAcc));
	}  
	robot.turnAcc = turnAcc;   
}



/**
 *  Inform LFS of your maximum robot drive speed (inches/sec). If simulation limits are exceeded, a warning 
 *  message is generated and the value is limited to simulator maximum.
 *  
 *  Note driving and turning must take into consideration maxim turn rate and maximum drive speed where robot
 *  turning model assumes, differential drive robot with turn about center line applying uniform increase of speed
 *  of one wheel and decrease in speed of other wheel to effect turn.
 *  
 *   
 * @param m  maximum speed
 */

public void setMaxSpeed(float m)     // inform lfs of your max speed *
{
	if (m>maxSpeed)
	{
	   m = maxSpeed;
	   PApplet.println (String.format("Warning, setMaxSpeed maxSpeed exceeded, using max value %1.1f",m));
	}
	userMaxSpeed = m;
}

/** Get maximum robot speed as defined by simulator or a lesser speed as set by call to setMaxSpeed.
 * 
 * @return maximum speed (inches/sec) 
 * 
 */
public float getMaxSpeed() {return userMaxSpeed; }


/** Set maximum robot turn rate (degrees/sec) limited by LFS maximum value. If the maximum is exceeded,
 * a warning message is generated and the stored value is set to the simulator maximum.
 * 
 * @param mt maximum turn rate 
 * 
 */
public void setMaxTurnRate(float mt) 
{
if (mt > maxTurnRate)
{
  mt = maxTurnRate;
  PApplet.println (String.format("Warning, setMaxTurnRate  maxTurnRate exceeded, using max value %1.1f",mt));
}
userMaxTurnRate = mt;
}

/**
 * Get maximum turn rate as specified by user, and possibly limited by simulation.
 * @return (degrees/sec)
 */
public float getMaxTurnRate() { return userMaxTurnRate; }


/** Change speed with no reported error checking, speed is restricted to maxSpeed.
 * Generally setTargetSpeed() method is thought to be more useful for user robot controller. 
 * 
 * @param delta is change (inches/sec)
 */
public void changeTargetSpeed(float delta) { robot.changeTargetSpeed(delta,maxSpeed); }


/** Change target sideways speed with no reported error checking, speed is restricted to maxSpeed.
 * Generally setTargetSidewaysSpeed() method is thought to be more useful for user robot controller. 
 * 
 * @param delta is change (inches/sec)
 */
public void changeTargetSidewaysSpeed(float delta) { robot.changeTargetSidewaysSpeed(delta,maxSpeed); }




/** Change turn rate (deg/sec) with no reported error checking, turn rate is restricted to
 * maxTurnRate. Generally setTargetTurnRate() method is thought to be more useful for user robot controller.
 * 
 * @param delta is change in (degrees/sec)
 */

public void changeTargetTurnRate(float delta) { robot.changeTargetTurnRate(delta,maxTurnRate); }

/** Robot is slowed to stop using pre-set decelRate for speed and turnAcc rate for 
 * turn rate.
 *
 */
public void stop() { robot.slowToStop(); }





/** Get reference to currently loaded course image. Generally not something that is needed. 
 * 
 * @return Reference to image (PImage)
 */
public PImage getCourse() { return course; }

/** Set identity for contest data logging. These fields can be directly read/modified in LFS class.
 * 
 * @param firstName  Contestant first name
 * @param lastName   Contestant last name
 * @param robotName  Competing robot name
 */
public void setFirstNameLastNameRobotName(String firstName, String lastName,String robotName)
{
nameFirst = firstName;
nameLast  = lastName;
nameRobot = robotName;
} 



/**
 * 
 * @param fname file name of contest course .png or .jpg image file expected to be scaled to 64 DPI 
 * (dots per pixel). File is expected to be in sketch data sub folder.
 */
public void setCourse(String fname)
{
 courseFilename = fname;
 course = p.loadImage(fname); 
}

/**
 *  Draw text of robot location and heading into bitmap. Idea is user does not have direct
 *  access to this information. In the real world such data would not be easily obtainable without absolute
 *  position and orientation detection. Under certain circumstances this information might be made available
 *<p>
 * (Called by simulation core code.)  
 *   @param x Screen X position for location of robot location and heading bitmap.
 *   @param y Screen Y position for location of robot location and heading bitmap. 
 */
public void drawRobotLocHeadingVel(float x, float y)  
{
// does report "actual" robot x,y and heading, draws onto screen
// idea is user not supposed to know actual location hence draw and not make vars available

if (robot.sidewaysSpeed != 0)	
	p.text (String.format ("loc(%3.0f,%3.0f) %03.0f deg  vel %1.1f:%1.1f ips",
            robot.x,robot.y,robot.heading,robot.speed,robot.sidewaysSpeed),x,y);
else
p.text (String.format ("loc(%3.0f,%3.0f) %03.0f deg  vel %1.1f ips",
            robot.x,robot.y,robot.heading,robot.speed),x,y);
}


void clearStopwatch() // package private - zero stop watch
{
stopwatchTick = 0; 
contestResetCount=0;
}

/** Called from draw() method, if stepRequseted simulator will calculate new position and heading of robot
 *  based on current speed and turn rate.
 * <p>
 * (Called by simulation core code.) 
 * @param stepRequested If true drive update will be called. If false, no driveUpdate and no crumbs will be added.
 */
public void driveUpdate(boolean stepRequested)
{
  if ((stepRequested) || !controllerEnabled)      // needed to insure when controller OFF drive update still works
  {                                               // for manual test driving robot
    robot.driveUpdate(timeStep);
    view.crumbAdd(robot);
  }  
  
  if (stepRequested && controllerEnabled) stopwatchTick++;
} 


/** Current robot runtime formatted in minutes:seconds:milliseconds  (stopwatch tick x timeStep)
 * <p>
 * (Called by simulation core code.) 
 *@return Contest runtime string mn:se:msec
 */
public String getContestTimeString ()
{

int runtime = (int) Math.floor(stopwatchTick*timeStep*1000);
int rsec = runtime / 1000;

int mins =   rsec/60;

int secs =   rsec%60;

int msecs =  runtime %1000;

//String rs = "";
//if (simSupportContestReset) rs = String.format ("Resets %d",contestResetCount);

return String.format("%2d:%02d:%03d",mins,secs,msecs);  // originally appended reset count

}


/**
 * Set simulation time step, range 0.1 (10 steps per sec) to 0.01 (100 steps per sec) seconds. If the value of the 
 * argument exceeds the legal range, it will be restricted to the given bound.
 *  *  
 * @param dt time step in seconds, default value is 0.01667 (approximately 1/60th second) which corresponds to 
 * typical processing frame rate, resulting in robot that runs "the correct speed" when not throttling step rate
 * as is available in the simulation.
 * 
 */

public void setTimeStep(float dt)
{
if (dt<minTimeStep)
{
  dt = minTimeStep;
  PApplet.println (String.format("setTimeStep less than simulation allows, set to %1.4f sec ",dt)); 
}  
if (dt>maxTimeStep)
{
  dt = maxTimeStep;
  PApplet.println (String.format("setTimeStep more than simulation allows, set to %1.4f sec ",dt)); 
}

timeStep = dt;
}

/** Simulation time step in seconds, should not be changed during simulation, recommend change in userInit method.
 * @return timeStep in seconds e.g. 0.01667 is default ~1/60th second 
 */
public float getTimeStep()
{ return timeStep; }



/**  Set target drive speed where the simulation will ramp up or ramp down using defined acceleration rate or deceleration
 * rate to attain the target speed over succeeding simulation steps. 
 * 
 * @param s Target speed (inches/sec)
 */

public void setTargetSpeed(float s)
{
if (Math.abs(s)>maxSpeed)
{
   PApplet.println ("Warning: Target speed limited to maxSpeed");
   if (s>0) s = maxSpeed;
   else     s = -maxSpeed;
}

robot.setTargetSpeed(s);
}

/** Set target sideways drive speed (inches/sec) where the simulation will ramp up or ramp down
 * using defined acceleration rate or deceleration rate to attain the target sideways speed over 
 * succeeding simulation steps. 
 * 
 * @param tss Target speed (inches/sec)
 */

public void setTargetSidewaysSpeed(float tss)
{
  robot.setTargetSidewaysSpeed(tss); 
}


/** Set target turn rate where the simulation will ramp up or ramp down using defined turn 
 *  acceleration / deceleration rate to attain the target turn rate over succeeding
 *  simulation steps. 
 * 
 * @param r Target turn rate (degrees/sec)
 *  
 */

public void setTargetTurnRate(float r)
{
if (Math.abs(r)>maxTurnRate)
{
   PApplet.println ("Warning: Target turn rate limited to maxTurnRate");
   if (r>0) r = maxTurnRate;
   else     r = -maxTurnRate;
}
 
robot.setTargetTurnRate(r);
}



/** Current robot speed, when less than targetSpeed robot is will be accelerating when greater than target
 * speed, robot is decelerating 
 *  
 * @return speed (inches/sec)
 */
public float getSpeed()    { return robot.getSpeed();    }  


/** Current robot sideways speed, when less than targetSidewaysSpeed robot is accelerating
 *  when greater than target sideways speed, robot is decelerating.
 *  
 * @return sideways speed (inches/sec)
 */
public float getSidewaysSpeed()    { return robot.getSidewaysSpeed();    }  



/** Current robot turn rate, when less than targetTurnRate robot is accelerating its turn rate when greater than 
 * target turn rate, robot is decelerating its turn rate. 
 *  
 * @return turn rate (degrees/sec)
 */

public float getTurnRate() { return robot.getTurnRate(); }   // current turn rate (could be accelerating/decelerating)

/** This method is used to instantiate a new SpotSensor object.  Defines the object instance and places it in a list
 *  referenced by LFS during the process of updating sensor data (via reading the screen pixels - after the robot 
 *  view of the course has been rendered to a bitmap.
 * 
 * @param xoff   X offset (inches) from center of robot in robot coordinates. +X axis extends forward.  
 * @param yoff   Y offset (inches) from center of robot in robot coordinates. +Y axis extends to right.
 * @param w      width in pixels of spot sensor sampled area of "screen".
 * @param h      height in pixels of spot sensor sampled area of "screen".
 * @return       Returns new instance of SpotSensor
 */
public SpotSensor createSpotSensor (float xoff, float yoff, int w, int h )
{ return new SpotSensor(p,sensors,xoff,yoff,w,h); }

/** This method to instantiate a new LineSensor object.  Defines the object instance and places it in a list
 *  referenced by LFS during the process of updating sensor data (via reading the screen pixels - after the robot 
 *  view of the course has been rendered to a bitmap.
 *  <p>
 *  It should be noted the line sensor can be modified into a 1/2 circle sensor array and/or the sensor array 
 *  can be rotated about the line sensor center spot.
 *
 * @param xoff              X offset (inches) from center of robot in robot coordinates. +X axis extends forward.
 * @param yoff              Y offset (inches) from center of robot in robot coordinates. +Y axis extends to right. 
 * @param w                 width in pixels of spot sensor sampled area of the screen.
 * @param h                 height in pixels of spot sensor sampled area of the screen.
 * @param numberOfSensors   number of spots in line (will be incremented if even value specified)
 * @return 	New instance of LineSensor
 */
public LineSensor createLineSensor (float xoff, float yoff, int w, int h, int numberOfSensors )
{ return new LineSensor(p,sensors,xoff,yoff,w,h,numberOfSensors); } 

/**
 * Erase crumbs in course view - performed at start of robot run.
 * <p>
 * (Called by simulation core code.) 
 */
public void crumbsEraseAll() { view.crumbEraseAll(); }

/**
 *  Draw robot coordinate axes in robot view. Optionally called in userDraw. Serves as a good reminder orientation of robot coordinates
 *  and origin location.
 */
public void drawRobotCoordAxes()  { view.drawRobotCoordAxes(); }


void createFile(File f){
  File parentDir = f.getParentFile();
  try{
    parentDir.mkdirs(); 
    f.createNewFile();
  }catch(Exception e){
    e.printStackTrace();
  }
}


void appendStringToFile(String header, String filename, String text)
{  // append string
	boolean newFile = false;
	File f = new File(p.dataPath(filename));
	if(!f.exists()){
	  createFile(f);
	  newFile=true;
	}
	try {
	  PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
	  if (newFile) out.println(header);
	  out.println(text);
	  out.close();
	}catch (IOException e){
	    e.printStackTrace();
	}
}


/**
 * Called to start contest, controller enabled, crumbs cleared, stopwatch cleared.
 * Reading position and heading prohibited during run as is repositioning robot with setPositionAndHeading.
 * <p>
 * (Called by simulation core code.) 
 */
public void contestStart()
{
  contestState = ContestStates.csRun;
  controllerEnabled = true;
  crumbsEraseAll();
  clearStopwatch();
}

/** Check to see if contest is running. If so, stopwatch is running, and some restrictions will apply including
 * restriction on moving robot (setPositionAndHeading) and possibly reading robots loction including
 * (getRobotX,getRobotY,getRobotHeading) which are displayed, but not available during robot run in at least
 * one given contest scenario.
 * <p>
 * Some consideration may be given to providing location information or local location information which may be reliable for short run.
 * Drive error may be introduced into simulation making local odometry difficult without obtaining calibration references from the couse.
 * 
 * @return true if running 
 */
public boolean contestIsRunning()
{
  return contestState == ContestStates.csRun;
}



/**
 * Stop contest - robot slowed to stop, controller disabled, stop watch stopped. At this point
 * contestFinish() should be called after any further actions taken. It is possible comment dialog will
 * be generated in the future helping to automate process from stop (triggered by SPACE BAR) to contestFinish().
 * <p>
 * (Called by simulation core code.) 
 */
public void contestStop()
{
  robot.slowToStop();
  controllerEnabled = false; 
  contestState = ContestStates.csStop; 
	
}


/**
 * Set robot position and heading if contest run not in progress. 
 * @param x  robot x location (inches)
 * @param y  robot y location (inches)
 * @param heading robot heading in degrees
 */

public void setPositionAndHeading (float x, float y, float heading)
{
	if (!contestIsRunning())
	{	
      robot.x = x;
      robot.y = y;
      robot.heading = heading;
	} 
	else PApplet.println ("Warning - Contest running, setPositionAndHeading request ignored.");
}


/**
 * If contest is not running return robot center, coordinate location X value (inches)
 * @return X (inches) 
 */
public float getRobotX () {  if (!contestIsRunning()) return robot.x;
else { PApplet.println ("Contest Running robot location not available"); return 0; }
}
/**
 * If contest is not running return robot center, coordinate location Y value (inches)
 * @return Y (inches) 
 */
public float getRobotY () {  if (!contestIsRunning()) return robot.y;
else { PApplet.println ("Contest Running robot location not available"); return 0; }
}
/**
 * If contest is not running return robot heading value (degrees).
 * Example Headings given image with origin in upper-left corner +X axis running to right on
 * "page" and +Y axis running down the "page" as you would view an image on a screen or paper on 
 * a desk. See illustration in User's Guide.
 * <p>  0  = heading along image X axis in -X direction 
 * <p>  90 = heading along image Y axis in -Y direction
 * <p> 180 = heading along image X axis in +X direction
 * <p> 270 = heading along image Y axis in +Y direction
 * <p>
 * @return Heading (degrees) 
 */
public float getRobotHeading () {  if (!contestIsRunning()) return robot.heading;
else { PApplet.println ("Contest Running robot heading not available"); return 0; } }




/**
 * Call after contest stopped (Key F - Finish) 
 * Logs run to .cdf file and initiates image save
 * <p>
 * (Called by simulation core code.) 
 */

public void contestFinish()
{
  if (contestState ==  ContestStates.csRun) contestStop();   // stop contest if still running (space bar not pressed to stop) 
  if (contestState != ContestStates.csStop) 
  { PApplet.println("Warning - cannot Finish contest that was not started with R-Run Command");
    return;
  }
	
  contestState = ContestStates.csFinished;
 
  
  String comments = ""; // need to have csStop before cdFinished  with chance to enter comments !!!
  
  String name = nameFirst+" "+nameLast;
  String time = getContestTimeString();   // runtime including reset count (if resets enabled)
   
 
  String header = "Name,Robot,RunTime,FinalPos,CourseFile,Comments";       
     
  String s = String.format("%s,%s,%s,%1.0f,%1.0f,%s,%s",name,nameRobot,time,robot.x,robot.y,courseFilename,comments);
  appendStringToFile(header,simContestFilename,s);
    
      
  requestScreenSaveInFrameCount = 2;  // give time for display of (F) in window before screen cap
  
  
}


/** Called at end of sketch draw() method, checks to see if screen save has been requested by simulator and saves image if so.
 * <p>
 * (Called by simulation core code.) 
 */

public void contestScreenSaveIfRequested()  // need count down on this 1 frame
{
  if (requestScreenSaveInFrameCount==-1) return;
  if (requestScreenSaveInFrameCount-- >0) return;
  
  String ts = String.format("%02d-%02d-%02d",PApplet.hour(),PApplet.minute(),PApplet.second());
  String fn = nameFirst+nameLast+nameRobot+"-"+ts+" .png"; 
  p.saveFrame(fn);
  PApplet.println ("Saved screen capture to ",fn); 
  requestScreenSaveInFrameCount = -1;

}



} // end LFS class 