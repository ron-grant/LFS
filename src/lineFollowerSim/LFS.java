
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
import java.util.ArrayList;   // for course list


/** LFS Class is Line Follower Simulator main class that handles:
 * 
 *  <ul>
 *  <li> tracking the position and heading of a virtual robot based on user specified target speed and turn rate</li>
 *  <li> managing robot acceleration and speed (drive and turn) subject to simulator maximums</li>
 *  <li> generating the view of immediate surroundings of a robot</li>
 *  <li> reading sensor values from user defined spot and line sensors</li> 
 *  <li> presentation of an image of the course with robot image and cookie crumb trail tracking progress of robot</li>
 *  <li> implements interactive marker system allowing storing multiple robot start locations and headings on a course</li>
 *  <li> managing list of contest courses with optional starting location and heading, also timer mode stopwatch or lap time</li>
 *  <li> managing contest states and producing contest run report</li>
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
 *
 * Using the marker system introduced in library release 1.0.3 and later is documented in Marker tab of 
 * LFS_SimpleRobotMarker example, including steps required to modify existing LFS sketch to add this functionality.
 * <p>
 * Note that several methods documented are not called by user code. These are highlighted by 
 * <p>
 * (Called by simulation core code.) 
 *  @author Ron Grant           Line Follower Sim (LFS) Processing Library   published at http://github.com/ron-grant/LFS
 */  

public class LFS  {


View view;             // package private - important 
private PApplet p;     // reference to current applet (processing sketch using this lib)


Robot robot;           // single instance of robot class - accessed only from this 
                       // class  -- user must rely on this class' get/set methods 

Marker marker;         // single instance of marker class - accessed from this class only
/**
 * When set true, report data written to data folder file "contest.cdf" after a run, will
 * include distance traveled since start.
 * If an old contest.cdf exists, it will not have the Dist field in its header. Erasing the 
 * file will cause LFS to generate a new contest.cdf file, containing Dist field, after the
 * next contest run. 
 * 
 */
public boolean reportDistanceTraveled = true;  // when true distance traveled included in run report  1.4.1
/**
 * When set true (default value), on screen display includes distance traveled since start. 
 * New feature in (lib 1.4.1) default is false. See UserInit tab in simulation app.
 */
public boolean showDistanceTraveled = true;            // when true distance traveled included in on screen display 1.4.1

/**
 *  Sensors class single instance - gives access to spot and line sensor lists.
 */
public Sensors sensors;  
/**
 * Contest run report appended to this file. If fields added and header does not match data. Copy file as needed and delete.
 * New column header will be created on next contest run.
 */
public String simContestFilename = "contest.cdf";


//public boolean showSensorsOnSensorView = true;

/**
 * Show (or hide) indication of sensor data has been read by coloring screen bitmap pixels directly.
 * Support dropped for this feature. (lib 1.4.1). Drawing is performed after all sampling now.
 * 
 * @param show Set to false to hide display indicating sensor sampling location
 */

public void setShowSensorsOnSensorView(boolean show)
{ PApplet.println ("setShowSensorsOnSensorView support dropped lib 1.4.1"); }

/** User first name supplied by call to setFirstNameLastNameRobotName
 */
public String nameFirst;
/** User last name supplied by call to setFirstNameLastNameRobotName
 */
public String nameLast ;
/** User robot name supplied by call to setFirstNameLastNameRobotName
 */
public String nameRobot;                 // client supplied names (NAMES command)



//private PGraphics rv; // robot view at 64 DPI


int  headingChangeX = -999; // used to log mouseX on right mouse press and hold and drag in X to change heading
float headingChangeStart;   // used to log robot heading upon right mouse press

//mouse drag robot while in robot view state vars
int startDragX = -999;
int startDragY;

float startDragLocX,startDragLocY;

boolean drawRobotCoordAxes = true;   // show robot coordinate axes   
                                 
int contestResetCount=0;

boolean controllerEnabled = false;     // setcontrollerEnabled(t/f)   getcontrollerEnabled()                                
                     
                               
PImage course;                         // courseImage 64 DPI rendition of course - see header comment
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

//private int rvCount = 1;
//private int cvCount = 1;

private int requestScreenSaveInFrameCount  = -1;

public LapTimer lapTimer;

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

  robot = new Robot(parent,0,0,0);     // pos heading set later 
  sensors = new Sensors(parent);       // single instance of sensors 
  lapTimer = new LapTimer(parent,this); 
  
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
  
  marker = new Marker (parent,this); // pass ref to both parent Applet and this instance of LFS
  
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
 * overlay graphics on SENSOR view. 
 *
 */
public void setupUserDrawSensorViewport() 
{
  view.setupUserDraw('S');
}

/** Setup coordinate transformations and scale factors required for optional user code (userDraw method) to draw
 * overlay graphics on ROBOT view. 
 */

public void setupUserDraw() 
{
  view.setupUserDraw('R');
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
 

/** Define sensor view display region in screen (pixel) coordinates.
 *  This method is optional. Since library version 1.0.0, sensor viewport was predefined 
 *  as (0,0,800,800)
 * @param x        upper left corner x
 * @param y        upper left corner y 
 * @param width    viewport width 
 * @param height   viewport height 
 */

public void defineSensorViewport (int x, int y, int width, int height)  
{
  view.defineSensorViewport (x,y,width,height); 	
}
 

/**
 * Get a reference to Robot viewport including  location and size in screen coordinates. Upper-left x,y and width,height 
 * in pixels. Modification of viewport size and position may be possible, but results not guaranteed.
 *   
 * @return reference to viewport.
 */
public VP getRobotViewport()  { return view.robotVP;  }
/**
 * Get a reference to Course viewport including  location and size in screen coordinates. Upper-left x,y and width,height 
 * in pixels. Modification of viewport size and position may be possible, but results not guaranteed.
 *   
 * @return reference to viewport.
 */
public VP getCourseViewport() { return view.courseVP; }
/**
 * Get a reference to Sensor viewport including  location and size in screen coordinates. Upper-left x,y and width,height 
 * in pixels. Modification of this viewports size and position may be possible, but results not guaranteed.
 *    
 * @return reference to viewport.
 */
public VP getSensorViewport() { return view.sensorVP; }




/** Draw internal bitmap of robot proximity and update sensor data values, called from draw()
 *  at each simulation step, deprecated method.
 * <p>
 * (Called by simulation core code.) 
 * @param r Red color channel 0..255
 * @param g Green color channel 0..255
 * @param b Blue color channel 0..255
 * @param a Alpha opacity 0..255 (0=transparent .. 255 = opaque)
 * 
 */
public void updateSensors(int r, int g, int b, int a)
{
  view.drawSensorView(course,robot,courseDPI);  
  
  if (sensors != null)
  {	  
    if (sensors.sensorImageRead)
      sensors.update(view.sensorVP,course,robot,courseDPI);
    else
      view.sensorUpdate(sensors,course,robot,courseDPI);
    
                                                   // draws into screen frame buffer now - fast
     if (a>0) view.coverSensorView(r,g,b,a);       // rgb,alpha, skip if alpha 0
 
  }
}

/**
 * Draw large sensor view, display of this view is no longer needed, using updateSensorsFast. 
 * @param dimCover 0=no dimming 255 = dim to black
 */
public void drawSensorView(int dimCover)
{
  view.drawSensorView(course,robot,courseDPI);  	
  if (dimCover>0) view.coverSensorView(0,0,0,dimCover);	
	
}

/**
 *  Update sensors for controller, executed by core LFS call before userContollerUpdate called.
 */

public void updateSensorsFast()
{
   if (sensors.sensorImageRead)
	   sensors.update(view.sensorVP,course,robot,courseDPI);
   else PApplet.println ("ERROR sensorImageRead not enabled, updateSensorsFast not performed");    
	
}


/**
 * Clear both spot and line sensor lists. Generally speaking this operation would not be required, but is performed
 * before robot is reset and run. Where sensor definitions are re-instated via call to userInit() which sould contain
 * sensor initialization code. 
 */
public void clearSensors()              { sensors.clear();    }

/**   DEPRECATED METHOD, Draw robot view and course views to screen, LFS now uses drawRobotView and 
 *    drawCourseView methods.
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
	//if (p.mousePressed) rvCount = 1;  
	//if (--rvCount<= 0)
	//{ rvCount = rvDiv;	
      view.drawRobotView(course,courseDPI,robot,contestIsRunning(),0);   // draw robot view into defined viewport
	//}  
  }
  
  if (cvDiv!=0)
  {	
	//if (p.mousePressed) cvCount = 1;   
	//if (--cvCount<=0)
	//{ cvCount = cvDiv;
	  view.drawCourseView(course,robot,courseDPI,cRotate90, contestState == ContestStates.csFinished,
	  contestIsRunning(),0);   // contest Finished draw (F) on course , dim value 
	//}  
  } 
  
}
/**
 * Draw robot view (small), dimming option  0..255 option.
 * @param dim dim value 0=OFF ... 255 dimmed out to black
 */
public void drawRobotView (int dim)
{
  view.drawRobotView(course,courseDPI,robot,contestIsRunning(),dim);	
}

/**
 * Draw view of course, with rotation option and dimming 0..255 option.
 * @param cRotate90
 * @param dim dim value 0=OFF ... 255 dimmed out to black
 */
public void drawCourseView (boolean cRotate90, int dim)
{
   view.drawCourseView(course,robot,courseDPI,cRotate90, contestState == ContestStates.csFinished,
	  contestIsRunning(),dim);   // contest Finished draw (F) on course 	
	
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
 * Choose course to load from sketch datafolder, see defineCourse and chooseCourse methods which are more 
 * handy for selecting from a list of possible courses.
 * @param fname file name of contest course .png or .jpg image file expected to be scaled to 64 DPI 
 * (dots per pixel). File is expected to be in sketch data sub folder.
 */
public void setCourse(String fname)
{
 courseFilename = fname;
 course = null;
 
 course = p.loadImage(fname); 
 course.loadPixels();                   // for image read sensor access
 
 view.invalidateRobotAndSensorViews();  // new (lib 1.6.1) 
                                        // forces re-creation of textured quads used for robot and sensor view
 
   
}

/**
 * Get current course filename
 * @return CourseFilename
 */
public String getCourseFilename() { return courseFilename; }


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
// idea is user not supposed to know actual location hence draw and not make values available

	if (showDistanceTraveled) // if set true, include distance, might require smaller font to fit   new 1.4.1
	{	
		if (robot.sidewaysSpeed != 0)	
			p.text (String.format ("loc(%3.0f,%3.0f) %03.0f deg  vel %1.1f:%1.1f ips dist %1.0f",
		            robot.x,robot.y,robot.heading,robot.speed,robot.sidewaysSpeed,robot.distanceTraveled),x,y);
		else
		p.text (String.format ("loc(%3.0f,%3.0f) %03.0f deg  vel %1.1f ips dist %1.0f",
		            robot.x,robot.y,robot.heading,robot.speed,robot.distanceTraveled),x,y);
		
	
	}
	else // default 
	{	
		if (robot.sidewaysSpeed != 0)	
			p.text (String.format ("loc(%3.0f,%3.0f) %03.0f deg  vel %1.1f:%1.1f ips",
		            robot.x,robot.y,robot.heading,robot.speed,robot.sidewaysSpeed),x,y);
		else
		p.text (String.format ("loc(%3.0f,%3.0f) %03.0f deg  vel %1.1f ips",
		            robot.x,robot.y,robot.heading,robot.speed),x,y);
	
	}

}



void clearStopwatch() // package private - zero stop watch
{
  lapTimer.clear();	
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
  }
  
  if (controllerEnabled) view.crumbAdd(robot);    // controller must be enabled for crumbs to be dropped (lib 1.6)
 
  
  if (stepRequested && controllerEnabled) lapTimer.tick();
} 


/** Current robot runtime formatted in minutes:seconds:milliseconds  (stopwatch tick x timeStep)
 * <p>
 * (Called by simulation core code.) 
 *@return Contest runtime string mn:se:msec
 */
public String getContestTimeString ()
{
  return lapTimer.getTimeStr();  // now using lapTimer
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

/**
 * Available only when contest not running. Used by LFS in restoring robot state
 * when clicking on a marker that was generated during a robot non-contest run. That is,
 * a run started by G)o. User is advised to use setTargetSpeed method, as this method
 * does not work if called while contest run is in progress.
 * @param s Speed (inches/sec)
 */
public void setInstantSpeed(float s)
{  if (!contestIsRunning()) robot.speed = s; 
   else PApplet.println ("ERROR setInstantSpeed non-functional during contest run.   ");
} 

/**
 * Available only when contest not running. Used by LFS in restoring robot state
 * when clicking on a marker that was generated during a robot non-contest run. That is,
 * a run started by G)o. User is advised to use setTargetSidewaysSpeed method, as this method
 * does not work if called while contest run is in progress.
 * @param ss Speed (inches/sec)
 */
	
public void setInstantSidewaysSpeed(float ss)
{ if (!contestIsRunning()) robot.sidewaysSpeed = ss;
 else PApplet.println ("ERROR setInstantSidewaysSpeed non-functional during contest run.   ");
}
/**
 * Available only when contest not running. Used by LFS in restoring robot state
 * when clicking on a marker that was generated during a robot non-contest run. That is,
 * a run started by G)o. User is advised to use setTargetTurnRate, as this method
 * does not work if called while contest run is in progress.
 * @param tr Turn rate (degrees/sec)
 */

public void setInstantTurnRate(float tr)
{ if (!contestIsRunning()) robot.turnRate = tr;
  else  PApplet.println ("ERROR setInstantTurnRate non-functional during contest run.");
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

/**
 * Current robot heading. Not available during contest run (0 returned)
 * @return current robot heading if contest not running.
 */
public float getHeading() { if (contestIsRunning()) return 0; else return robot.heading; }


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
 *  can be rotated about the line sensor center spot location at (xoff,yoff).
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
 * Called by simulation core code and also by keyPress E-EraseCrumbs. 
 */
public void crumbsEraseAll() { view.crumbEraseAll(); }

/**
 *  Crumb threshold distance apart. Default is 0.5 inches, increase to reduce drawing overhead
 *  and potentially increase frame rate late in a run where many crumbs are displayed.
 *  @param d Minimum separation distance (inches).  
 */
public void setCrumbThresholdDist(float d) {view.crumbThresholdDist = d; }

/**
 * Crumb enable/disable. Automatically enabled when contest run started. 
 * @param enable
 */
public void setCrumbsEnabled(boolean enable) { view. crumbsEnabled = enable; }

/**
 * Double buffer crumb list used in warp speed and loop to create persistant 
 * display of cookie crumbs
 * @param e Set true to enable double buffer 
 */
public void setCrumbsDoubleBuffer(boolean e) {view.crumbSetDoubleBuffer(e); }

/**
 *  Draw robot coordinate axes in robot view. Optionally called in userDraw. Serves as a good reminder orientation of robot coordinates
 *  and origin when positioning sensors.
 */
public void drawRobotCoordAxes()  { view.drawRobotCoordAxes(); }

/**
 * Draw robot coordinate axes in robot view. Optionally called in userDraw. Serves as a good reminder orientation of robot coordinates
 * and origin when positioning sensors.
 * @param size  size of axes icon 
 * @param alpha transparency of axes 0=invisible .. 255=opaque
 */
public void drawRobotCoordAxes(float size, int alpha) {view.drawRobotCoordAxes(size,alpha); }

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
 * Called to start contest, controller enabled, crumbs cleared, stopwatch cleared and any rotation bias added to
 * animate optional robot icon is cleared.
 * Reading position and heading prohibited during run as is repositioning robot with setPositionAndHeading.
 * <p>
 * (Called by simulation core code.) 
 */
public void contestStart()
{
  contestState = ContestStates.csRun;
  controllerEnabled = true;
  crumbsEraseAll();
  setCrumbsEnabled(true);
  lapTimer.clear();
  robot.setDistanceTraveled(0.0f);         // clear distance counter new 1.4.1
  view.userRobotIconRotationBias = 0.0f;
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
  return contestState != ContestStates.csIdle;   // was == csRun
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
else { PApplet.println ("Contest Running robot location not available"); return 0.0f; }
}
/**
 * If contest is not running return robot center, coordinate location Y value (inches)
 * @return Y (inches) 
 */
public float getRobotY () {  if (!contestIsRunning()) return robot.y;
else { PApplet.println ("Contest Running robot location not available"); return 0.0f; }
}
/**
 * If contest is not running return robot heading value (degrees).
 * Example Headings (along coordinate axes) given. Note course image places its origin in upper-left
 * corner +X axis running to right on the "page" and +Y axis running down the "page" as you would 
 * view an image on a screen or paper on  a desk. See illustration in User's Guide.
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
 * If contest is not running return robot distance traveled since start. This information is 
 * displayed if showDistanceTraveled is set true and reported in contest.cdf if finishIncludesDistance is
 * set true.
 * @return distance traveled since G)o R)un  (lib 1.4.1)
 */
public float getDistanceTraveled() { if (contestState != ContestStates.csRun) 
  return robot.distanceTraveled;
else { PApplet.println("Contest Running, robot distance traveled not available"); return 0.0f; }}
/**
 * used when issuing Go or Run command to simulator
 */
public void clearDistanceTraveled() { robot.distanceTraveled=0.0f; }



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
 
  
 
  
  String name = nameFirst+" "+nameLast;
  String time = getContestTimeString();   // runtime including reset count (if resets enabled)
   
   
  String header = "Name,Robot,RunTime,FinalPos,CourseFile,Comments";
  if (reportDistanceTraveled)
    header =  "Name,Robot,RunTime,FinalPos,Dist,CourseFile,Comments";
  
  float d = robot.getDistanceTraveled(); 
 
  
  String comments = ""; 
  if (lapTimer.lapTimerModeEnabled) comments = "Lap Mode Contest - Total Time - completed laps follow"; 
 
	
  String s = String.format("%s,%s,%s,%1.0f,%1.0f,%s,%s",name,nameRobot,time,robot.x,robot.y,courseFilename,comments);  
	  
  if (reportDistanceTraveled)
      s = String.format("%s,%s,%s,%1.0f,%1.0f,%1.0f,%s,%s",name,nameRobot,time,robot.x,robot.y,d,courseFilename,comments);
   
  appendStringToFile(header,simContestFilename,s);
   
  if (lapTimer.lapTimerModeEnabled)
  for (String lt : lapTimer.lapList)
  {
	 time = lt; 
	 comments = "";
	 if (reportDistanceTraveled)
	      s = String.format("%s,%s,%s,%1.0f,%1.0f,%1.0f,%s,%s",name,nameRobot,time,robot.x,robot.y,d,courseFilename,comments);
	 else s = String.format("%s,%s,%s,%1.0f,%1.0f,%s,%s",name,nameRobot,time,robot.x,robot.y,courseFilename,comments);
	 
	 appendStringToFile(header,simContestFilename,s); 
  }
  
  requestScreenSaveInFrameCount = 2;  // give time for display of (F) in window before screen cap
  
  contestEnd();
}

/**
 * Called internally after contestFinish, or by user program to end contest, skipping report,
 * returning to contest idle (inactive) state.
 */
public void contestEnd()
{ contestState = ContestStates.csIdle; }

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

/** Convert robot location on course to screen x,y coordinates (0,0) top-left of screen  
 * 
 * @param worldX  robot world coordinate X value 
 * @param worldY  robot world coordinate Y value
 * @return Processing PVector with screen x,y values  
 */
public PVector courseCoordToScreenCoord (float worldX, float worldY) 
	{ return view.courseCoordToScreenCoord (course,worldX,worldY); }  


// interface to Marker 
/**
 * Called from  userInit() method to initialize marker system used to allow recording
 * robot start locations and headings within a course. Saved markers are loaded from 
 * file with the same name as the loaded course image, except with .mrk extension and 
 * subsequently displayed when markerDraw method is called.
 * <p>
 * See also : markerAddRemove and markerHandleMouseClick methods.
 */
public void markerSetup() {if (contestIsRunning()) marker.setup(0,0,0);
                    else marker.setup(robot.x,robot.y,robot.heading);}

/**
 * Draw markers on to course view as magenta circles. Typically this method is called from userDrawPanel 
 * method allowing marker circle display to be turned off (by not calling markerDraw method).
 */
public void markerDraw() {marker.draw(); }

/**
 * LFS application gives notice to marker that saved robot state information is present at this marker location.
 * This is done before markerDraw and after marker draw, this notice is cleared.
 * @param x Course location X value 
 * @param y Course location Y value 
 */
public void markerNotifySavedState(float x, float y) { marker.markerNotifySavedState(x,y); }  

/**
 * Animate Saved State Markers (fluff).
 * @param r Red component of color 0..255
 * @param r Green component of color 0..255 
 * @parem b Blue component of color 0..255
 * @param scale Scale of square
 * @param rotationSpeed  Rotation speed of marker 
 */
public void markerSavedStateColorScaleSpeed (int r, int g, int b, float scale, float rotationSpeed)
{
  marker.savedStateColorScaleSpeed (r,g,b,scale,rotationSpeed);	
}

/**This method call should be added to keypressed() method defined in UserKey 
 * If method has not been implemented then code would be written: 
 * <p>
 * void mouseClicked() {
 * <p>
 *   if (lfs.markerHandleMouseClick()) return;
 *   <p>
 *   // user or other mouse click handlers here
 * <p>    
 * }
 * <p> 
 * @return true if mouse clicked on marker, false if no action taken
 */
public boolean markerHandleMouseClick() { 
	if (!contestIsRunning()) return marker.handleMouseClick();
	else return false;
	} 

/**
 * Add / remove marker at current robot location when contest not running.
 * Typically this method is called from keyPressed(), e.g.
 * @return Returns true if marker placed, false if marker removed.
 * <p>
 * if (key == 'M') lfs.markerAddRemove();  
 */
public boolean markerAddRemove() {
	if (!contestIsRunning())
	{	
		return marker.addRemove(robot.x, robot.y, robot.heading);
	}  // should be called when M pressed
    return false;
}

/**
 * Typically called from userControllerResetAndRun() to locate robot at default location OR
 * marker location if defined and clicked. 
 * 
 * 
 */
public void  moveToStartLocationAndHeading()
{
  marker.gotoStartLocation(this);  // goto default start location OR current clicked on marker location
}

/**
 * Get start location used for contest run. Return as PVector where .x .y are (x,y) location of 
 * start point, .z is heading in degrees
 * @return PVector reference to start location and heading, e.g. PVector myStart = getStartLocationAndHeading();  
 */
public PVector getStartLocationAndHeading() 
{
  return new PVector (marker.startLocX,marker.startLocY,marker.startLocHeading);
}





/**Show sensors in Robot or Sensor viewport. Displays sensor color data as created (optionally) by user code.
 * Default is green if user does not modify sensor color (or colorTable in case of line sensor).
 * 
 * @param vportID  character 'R' robot viewport 'S' sensor viewport (scaled 64 DPI)
 */
public void showSensors(char vportID) { sensors.showSensors(this,vportID); } 

/**Define image to be used as robot image on course (replacing blue pointer). Suggest small file 100x100 pixels.
 * Use PNG format with alpha channel where background around robot is transparent. 
 * 
 * @param filename Icon filename located in data folder 
 * @param alpha Icon transparency 0 to 255   0=totally transparent 255=totally opaque
 */
public void setRobotIcon(String filename, int alpha)  // replace blue pointer on course image
{ view.setUserRobotIcon(filename, alpha);
}

/**Define reference to existing PImage to be used as robot image on course 
 * (replacing blue pointer). Suggest image 400x400 or smaller.
 *  Use setRobotIconScale method to scale down as needed.
 * 
 * @param img Reference to PImage  
 * @param alpha Icon transparency 0 to 255   0=totally transparent 255=totally opaque
 */
public void setRobotIconImage(PImage img, int alpha)  // replace blue pointer on course image
{ view.setUserRobotIconImage(img, alpha);
}


/**
 * Set alpha channel for robot icon image defined by setUserRobotIcon
 * @param alpha Icon transparency 0 to 255   0=totally transparent 255=totally opaque
 */
public void setRobotIconAlpha (int alpha) {view.setUserRobotIconAlpha(alpha); }
public int getRobotIconAlpha ( ) { return view.userRobotIconAlpha; }

/**
 * Set display scale for Robot icon
 * @param scale scale factor 1.0 = original size, 0.5 = 1/2 original size ... 
 */
public void setRobotIconScale (float scale) { view.userRobotIconScale = scale; }
public float getRobotIconScale () { return view.userRobotIconScale; }


/**
 * Set robot course icon rotation bias in radians - can be used to animate icon typically after a run. Default bias = 0 
 * and bias is set to 0 at start of a contest run. Positive values rotate icon clockwise. This rotation has no
 * impact on "actual" robot heading.
 * @param rotationBias  rotation in radians, default 0
 */

public void setRobotIconRotationBias (float rotationBias) {
	if (!contestIsRunning()) view.userRobotIconRotationBias = rotationBias; }
/**
 * Get robot icon rotation bias in radians.
 * @return robot icon turn bias in radians 
 */
public float getRobotIconRotationBias() { return view.userRobotIconRotationBias; }

/**
 * Control if robot or course viewport respond to mouse.
 * Program disables while variable editor in use which overlaps course view.
 * This is a bit of a hack, while using light-weight viewports.
 * @param enable Allow course view and robot view to respond to mouse commands for robot position and heading altering.
 */
public void setMouseActiveInViews(boolean enable) { view.mouseActive = enable; }

/**
 * Return true if robot has driven beyond course extents.
 * @return true if robot outside course bounds 
 */
public boolean robotOutOfBounds() {
	
	
	float xmax = course.width/courseDPI;
	float ymax = course.height/courseDPI;
	
	return ((robot.x <0.0) || (robot.y<0.0) || (robot.x>xmax) || (robot.y>ymax));
	
	
}

/**
 * LFS hides crumbs when help visible using this method. Problem with points bleeding 
 * through solid rectangle. Drawing order or Z-buffer issue don't know.  
 * @param enable When true crumbs are drawn. 
 */
public void setCrumbsVisible (boolean enable) { view.crumbsVisible = enable; } 



/**
 * Get simulator imposed maximum robot speed (inches/sec). 
 * @return max speed inches/sec
 */
public float getSimMaxSpeed()    { return maxSpeed; }
/**
 * Get simulator imposed maximum turn rate (degrees/sec).
 * @return max turn rate (degrees/sec) 
 */
public float getSimMaxTurnRate() {return maxTurnRate; }
/**
 * Get simulator imposed maximum acceleration rate (inches/sec^2).
 * @return maximum acceleration rate (inches/sec^2).
 */
public float getSimMaxAcc( ) { return maxAcc; }
/**
 * Get simulator imposed maximum deceleration rate (inches/sec^2).
 * @return maximum deceleration rate (inches/sec^2).
 */
public float getSimMaxDecel() { return maxDecel; }
/**
 * Get simulator impose maximum turn acceleration (and deceleration) rate (deg/sec^2).
 * 
 *  @return Simulator maximum turn acceleration rate (deg/sec^2).
 */
public float getSimMaxTurnAcc() {return maxTurnAcc; }
/**
 * Get simulator minimum time step (seconds). This is the amount of time that passes per controller
 * update and also simulator integration time for constant acceleration/deceleration rates applied to calculate 
 * speed change and speed integrated to become displacement (distance). This can be faster or slower than
 * real-time. For example at a frame rate of 50 frames per second and a time step of 0.020 (1/50th second),
 * the simulator runs in real time. If the frame rate is 100 frames/second, the simulator would run at 2X realtime.
 *  
 * @return Simulator minimum allowable time step (seconds).
 */
public float getMinTimeStep() { return minTimeStep; }
/**
 * Get simulator maximum time step (seconds). See getMinTimeStep method description.
 * @return Simulator maximum allowable time step (seconds).
 */
public float getMaxTimeStep() { return maxTimeStep; }


class Course {
	int num;
	String fname;
	boolean lapTimer;
	float xpos,ypos,heading;
	
	Course (int n, boolean lap, String name, float x, float y, float h){
	  num = n;
	  lapTimer = lap;
	  fname = name;
	  xpos = x;
	  ypos = y;
	  heading = h;
	}
	
}



ArrayList <Course> courseList = new ArrayList <Course> ();
int currentCourseNum = -1; // -1 allows chooseCourseFirstTime to work 


// used by defineCourse / defineLapCourse methods
private void defC (boolean lap, int num, String name, float x,float y, float h)
{
  for (Course c : courseList) if (c.num==num) return; // already in list, skip adding 
  courseList.add(new Course(num,lap,name,x,y,h));
}


/**
 * Choose a course defined by defineCouse defineLapCourse methods which specify course number and name. Subsequent
 * calls to this method are ignored. Use chooseCourse method to bypass this "one time" feature.

 * @param num Course number
 */
public void chooseCourseOneTime(int num)
{
  if (contestIsRunning())
  { 
	contestStop(); 
	PApplet.println("Warning - Contest Stopped - new course being selected");
    
  }
  
  if (currentCourseNum != -1) return;   // First Time
	  
  for (Course c : courseList) {
	  if (c.num==num)
	  {	  
		 setCourse(c.fname);  // sets and loads image 
		 markerSetup();       // loads markers associated with course filename 
		 lapTimer.lapTimerModeEnabled = c.lapTimer;
		 if (c.xpos !=-999)
		 {  setPositionAndHeading (c.xpos,c.ypos,c.heading);
		    marker.markerSetStartLoc (c.xpos,c.ypos,c.heading);  // Use this same location if no marker clicked before run.
		 }
	     else 
		 {  setPositionAndHeading (12,12,0);
		    marker.markerSetStartLoc (12,12,0);       // Use this same location if no marker clicked before run.
		 }
		 
		 currentCourseNum = num;
		 return; 
	  }		  
  }
	
  PApplet.println ("Error - Course number not defined. Check UserInit program tab.");
}


/**
 * Choose a course defined by defineCouse defineLapCourse methods which specify course number and name. 
 * See also chooseCourseOneTime method.
 * @param num Course number. 
 */
public void chooseCourse(int num) { currentCourseNum = -1; chooseCourseOneTime(num); }


/**
 * Choose next course from list created typically in UserInit tab, by defineCourse method calls.
 */
public void chooseNextCourse()
{
  if (courseList.size()==0) {
	  PApplet.println ("Error - chooseNextCourse failed, no courses have been defined with defineCourse method. Check UserInit.");
	  return;
  }
	
  for (Course c : courseList) 
	  if (c.num > currentCourseNum) {
		  currentCourseNum = -1;
		  chooseCourse(c.num); return; }  // found next in list 
 
 
  chooseCourse(courseList.get(0).num); // wrap around to first course 	
	
}




/**
 * Define a course that uses lap timer, with no initial position specified. When the course is chosen the robot
 * will be placed in the center. Markers can always be defined to allow quick placement.
 * @param num Sequence number. 
 * @param name File name of contest course .png or .jpg image file expected to be scaled to 64 DPI and located in sketch
 * data sub-folder.
 */
public void defineLapCourse(int num, String name) {defC(true,num,name,-999,0,0); }
/**
 * Define a course that does not use lap timer, with no initial position specified. When the course is chosen the robot
 * will be placed in the center. Markers can always be defined to allow quick placement.
 * @param num Sequence number. 
 * @param name File name of contest course .png or .jpg image file expected to be scaled to 64 DPI and located in sketch
 * data sub-folder.
 * 
 */
public void defineCourse (int num, String name)   {defC(false,num,name,-999,0,0); }
/**
 * Define a course that uses lap timer, with initial position and heading specified. When the course is chosen the robot
 * will be placed at the location specified. 
 * @param num Sequence number. 
 * @param name File name of contest course .png or .jpg image file expected to be scaled to 64 DPI and located in sketch
 * data sub-folder.
 * @param x Robot Offset (inches) in course image 
 * @param y Robot Offset (inches) in course image
 * @param heading Robot heading 0..359 (degrees) 
 */
public void defineLapCourse(int num, String name, float x,float y,float heading) {defC(true,num,name,x,y,heading); }
/**
 * Define a course that does not use lap timer, with initial position and heading specified. When the course is chosen the robot
 * will be placed at the location specified. 
 * @param num Sequence number. 
 * @param name File name of contest course .png or .jpg image file expected to be scaled to 64 DPI and located in sketch
 * data sub-folder.
 * @param x Robot Offset (inches) in course image 
 * @param y Robot Offset (inches) in course image
 * @param heading Robot heading 0..359 (degrees) 
 */
public void defineCourse (int num,String name,float x,float y, float heading)
 {defC(false,num,name,x,y,heading);   }


/*  Trying to get this method working here, vs in LFS processing application                Nov 5,2020 
    LFS_M tab where it does work -- and is currently enabled  

   being denied access to field 
   Able to get names and class names of fields 
   not able to set names in the class instance 
   
   Throwing IllegalAccessException
   
   thrown when an application tries to reflectively create an instance (other than an array),
   set or get a field, or invoke a method, but the currently executing method does not have 
   access to the definition of the specified class, field, method or constructor.

*/


public float distToClosestMarker (float x,float y) {return marker.getClosestDist(x,y); }





} // end LFS class 