package lineFollowerSim;

/* Sensors - Line, Arc and Spot Sensors

Option for vertical line sensor orientation, implemented, but not used/tested.
To use, set vertLine=true after creating instance of LineSensor. 

Ron Grant  June 2020

June 30,2020  per Will - "spot" name for rectangular array of pixels sampled by spot sensor
                         line sensor samples an array of spots, assumed to be adjacent in robot Y (left right) direction
                         without overlap or separation.
                         
Jun 30 20  - corrected truncation error in halfWidth calculation for line sensor offset                         
 
Aug 22 20  - implemented setArcRadius(r) method. Call after creating LineSensor instance make line into
             180 degree arc centered at line "center" x,y.
             
             Corrected 1/2 pixel offset error. 
             Line sensor with 9 5x5 spot sensors centered at robot y=0, appears centered on line when robot center 
             is centered on line, e.g. Challenge course y=12.0 heading 0, course line straight ahead, sensor balanced 
             on line. Also, arc sensor looked good e.g. 9 sensor arc "balanced".
             
             
 
Sept 13 20   Implemented setSpanDeltaX (deltaX for entire sensor span in inches) allowing sloped sensor lines
             Now allow combination of all modifiers (vertical line with radius now 1/2 circle)
             
                setArcRadius(r)      // when set to non zero value sensor spots form 1/2 circle with radius r (inches)
                setVertical(enable)  // now simple reverse of X,Y offsets relative to line "center"
                setDeltaX(d)         // deltaX for entire sensor span (use negative value to create negative slope) 
                
                If you have used vertical sensor lines in previous versions be sure to verify  
                sensor cell order. 
                


User defines spot and line sensors in setup()

A spot sensor samples a rectangular array of screen pixels referred to as a "spot".
A line sensor samples a linear array of spots which are ,for now, adjacent with no space between them, or overlap.
   

updateSensors() called from drawWorld() when view rendered to screen of overhead view of robot pointing toward top of screen.
This method calculates an intensity value 0.0 to 1.0 for each spot sensor spot. Also it calculates the intensity value for each spot
in the linear array of spots of a line sensor which it stores in an array which can be accessed by calling read() method for each.

A spot sensor returns a float value.
The line sensor returns a reference to float array.

e.g. for line sensor  

float[] lineData = lineSensor.read();



*/

import processing.core.*;
import java.util.ArrayList;
import java.lang.reflect.*;   // Reflection allows the ability to obtain Class member names and to modify them by name
                              // used by nameSensorsUsingVariableNames() 


//global sensor lists - built as sensors are defined, generally not needed by "user"

/**
 * Single instance of Sensors provides access to both spot and line sensor lists created by LFS for 
 * the purpose of iterating over all defined sensors to acquire sensor intensity data from the robots
 * current location and heading on a line following course image.
 * 
 * @author Ron Grant
 */

public class Sensors {  // no modifier = package protected 

PApplet p;

/**
 *  SpotSensor list, contains all instances of SpotSensor objects created by LFS method createSpotSensor.
 *  <p>
 *  This list is user accessible in allowing iteration through defined line sensors.
 *  <p>
 *  For example: for (SpotSensor ss : lfs.sensors.spotSensorList) println (ss.getXoff(),ss.getYoff(),ss.read());  
 *  
 */
public ArrayList <SpotSensor> spotSensorList = new ArrayList<SpotSensor>();   // list of spot sensors, created automatically as spot sensor instances are created

/**
 *  LineSensor list, contains all instances of LineSensor objects created by LFS method createLineSensor.
 *  <p>
 *  This list is user accessible allowing iteration through defined line sensors. 
 *  <p>
 *  For Example:  for (LineSensor ls : lfs.sensors.lineSensorList) println (ls.getXoff(),ls.getYoff()); 
 */
public ArrayList <LineSensor> lineSensorList = new ArrayList<LineSensor>();   // list of line sensors, created automatically as line sensor instances are created

/**
 * Show pixels that have been sampled by sensors, setting false may improve graphics frame draw rate.
 */
boolean showSampledPixels = true; // package private 

private int sensorTotalSpotCount;   // enumerated every call to updateSensors


// variables used for line sensor spot location calculation 
private int sensorN;    
private float halfWidth;
int DPI;
float sinA,cosA; 
float xoff,yoff;


Sensors (PApplet parent)
{ p = parent; }

/**
 * clear both spot and line sensor lists -- see LFS method clearSensors()
 */
void clear()
{
  if (spotSensorList != null) spotSensorList.clear();
  if (lineSensorList != null) lineSensorList.clear();
  //sensorCurrentIdentifierIndex = 1; 
  //sensorTotalSpotCount = 0;
}

float radians (float deg) { return deg*180.0f/((float) Math.PI);} 

// xorg yorg are screen origins of sensor viewport 


/** Used in conjunction with lineSensorSpotLocationCalc used to determine location of individual spot x,y offsets within a line sensor
 * taking into account rotation and/or half circle mode (non-zero arcRadius). An example use is to display sensor spots with colors(s) that 
 * indicate user set thresholds, i.e. turning line sensor spots RED where a line is perceived or other colors where a stain might be perceived. 
 * 
 * @param ls reference to line sensor
 */

public void lineSensorSpotLocationCalcInit(LineSensor ls)
{
  sensorN = ls.getSensorCellCount();  	

  halfWidth = (sensorN / 2.0f * ls.getSpotWPix()) / DPI;      // half width of line sensor in inches 
	                                                          // used to calculate offset of line sensor
                                                              // equal to 1/2 sensor total width applied in robot -Y direction 
	   
  float a = radians(ls.rotationAngle);
  sinA = (float) Math.sin(a);                                 // 2D rotation pre-calc 
  cosA = (float) Math.cos(a);
  
  xoff = ls.getXoff();
  yoff = ls.getYoff();
	
}

/** This method is called for each line sensor index from 0 to sensor spot count -1, where it calculates 
 * robot relative coordinates of each spot based on sensor location, arcRadius and rotation parameters.
 * Main use is to simplify display of line sensor data after user has added interpretation of raw sensor data. 
 * 
 * 
 * @param ls Reference to line sensor
 * @param index Current index from 0 to sensor cell (spot) count  -1
 * @param result PVector containing x,y offset with respect to robot
 */

public void lineSensorSpotLocationCalc (LineSensor ls, int index, PVector result)
{
  int n = ls.getSensorCellCount();  
  
  float u = (float) index /(n-1);  // parameter varies from 0 to 1.0 over N sensor elements 
  float t = (float) Math.PI*u;     // parameter varies from 0 to PI 

  float r = ls.arcRadius;          // default is 0 (straight line)
  float x = 0;
  float y = 0;

  if (r!=0)  // arc
  {
    y = (float) -(r*Math.cos(t));
    x = (float)  (r*Math.sin(t));
  }  
  else y = ((0.5f+index)*ls.getSpotHPix()/DPI) - halfWidth;   // straight line 
                   
  result.x = xoff + x * cosA - y * sinA;   // rotate spot sensor sensor  
  result.y = yoff + x * sinA + y * cosA;   // about sensor origin (center of sensor array                               

}



void update(VP vp, int courseDPI)  // called after sensor view draw (64 DPI image - now on screen) 


                    // iterates through sensor lists, reading all sensor values and storing within sensor class instances
                    // spot sensors sample a single cluster (rect array) of pixels
                    // line sensors sample a linear cluster array or clusters of pixels 
                   
{
 DPI = courseDPI;   // set local DPI used in calculations
	
 p.loadPixels(); // prepare to access screen pixels in pixels[] array
 
 
 // update spot sensors 
 
 sensorTotalSpotCount = 0;

 for (SpotSensor ss : spotSensorList)
 {
   ss.setIntensity(ss.sampleSensorPixel(vp,courseDPI,ss.getXoff(),ss.getYoff()));  
   //sensorTotalSpotCount++;
 }
 
 // update line sensors 
 
 for (LineSensor ls : lineSensorList)
 {
   float[] sensorTable = ls.readArray();   // get a reference to sensor's sensorTable & update it pixel by pixel

   
   lineSensorSpotLocationCalcInit(ls);     // set up repetitive calculations for spot locations on line sensor 
    
   PVector spotLoc = new PVector(0,0); 
   
   for (int index=0; index<sensorN; index++)
   { // for each line sensor pixel index (e.g. 0..64 if 65 pixel sensor)
    
	 lineSensorSpotLocationCalc (ls,index,spotLoc);  // calculate location of spot, reference returned in spotLoc 
     sensorTable[index] = ls.sampleSensorPixel(vp,courseDPI,spotLoc.x,spotLoc.y);
                              
   } 
   sensorTotalSpotCount+=sensorN;  // tally total #of sensor elements (spots)
   
 }
 
 if (showSampledPixels) 
   p.updatePixels();  // update required since sampled pixels are have been colored green to help with visualization of locations sampled     
} 




void showSensors(LFS lfs, char vportID)  // call with viewport you wish to use for display 'S' sensor or 'R' robot  
{                                        // call defined in LFS
   p.pushMatrix();
   p.pushStyle();
   
   p.resetMatrix();
   p.camera();
   
   VP svp =  lfs.getSensorViewport(); 
    
   VP vp = lfs.getRobotViewport();
  
   VP currentVP;
   
   float tx,ty; // define translation to center of viewport 
    
   if (vportID=='R') { currentVP=vp;  tx = vp.x+vp.w/2;   ty = vp.y+vp.h/2;  }    // viewport center
   else              { currentVP=svp; tx = svp.x+svp.w/2; ty= svp.y+svp.h/2; } 
      
   
  // scale (courseDPI);
   p.strokeWeight(0.5f);
   p.rectMode (PApplet.CENTER);
   p.fill (255,0,0);     // draw over spot sensors 
   p.stroke(255,0,0);
   
   float sc = lfs.courseDPI ;
   // if robot view
   if (vportID=='R')
     sc = sc * vp.w/svp.w;
     
   for (SpotSensor ss : lfs.sensors.spotSensorList)
   {
     float x = ss.getXoff();
     float y = ss.getYoff();
     float w = ss.getSpotWPix();
     float h = ss.getSpotHPix();
   
     float scrX = tx +y*sc;
     float scrY = ty -x*sc;
   
     p.fill(ss.getColor());
     p.rect (scrX,scrY,w,h);   // robot x,y swapped   pos X in robot system = -Y in screen 
     
     float d2 = PApplet.sq(scrX-p.mouseX)+PApplet.sq(scrY-p.mouseY); // squared dist from sensor center to mouse 
     
     if (d2<16) showSensorName(currentVP,String.format("SpotSensor %s = %1.2f ",ss.getName(),ss.read()));  // look up name 
   }  
   
   // reuse code used to calc sensor coords for each spot in line sensor
     
   for (LineSensor ls : lfs.sensors.lineSensorList)
   {
     float xoff = ls.getXoff();
     float yoff = ls.getYoff();
     float w = ls.getSpotWPix();
     float h = ls.getSpotHPix();
   
     float[] sensorTable = ls.readArray();      // get a reference to sensor's sensorTable 
     int [] colorTable   = ls.getColorArray();  // get a reference to sensor's colorTable

     int n = ls.getSensorCellCount();  
   
     lfs.sensors.lineSensorSpotLocationCalcInit(ls);
     p.rectMode (PApplet.CENTER);
     PVector pt = new PVector (0,0);
     
     for (int index=0; index<n; index++)
     { // for each line sensor pixel index (e.g. 0..64 if 65 pixel sensor)
       
       lfs.sensors.lineSensorSpotLocationCalc (ls,index,pt); 
       
      // drawSpot(xoff+xp,yoff+yp,w,h);
       float scrX = tx+(pt.y)*sc;
       float scrY = ty+(-pt.x)*sc; 
        
       p.fill (colorTable[index]); 
       p.noStroke();
       p.rect (scrX,scrY,w,h); 
       
       float d2 = PApplet.sq(scrX-p.mouseX)+PApplet.sq(scrY-p.mouseY); // squared dist from sensor center to mouse 
       if (d2<16) showSensorName(currentVP,
    		   String.format("LineSensor %s[%d] = %1.2f ",ls.getName(),index,sensorTable[index]));  // look up name 
   
   //  sensorTable[index] = ls.sampleSensorPixel(vp,courseDPI,xp+ls.getXoff(),yp+ls.getYoff());
                              
     } 
   }
 
   p.popMatrix();
   p.popStyle();
   
}



void showSensorName(VP vp, String name)       // overlay sensor name on robot or sensor view depending on which is visible
{                                      // used when mouse location is close to sensor location 
   
  p.pushStyle();                         // display sensor name at bottom of viewport  
  p.fill (20);
  p.rectMode(PApplet.CORNER);
  p.rect (vp.x,vp.y+vp.h-50,vp.w,50);
  p.textSize (20);
  p.fill (240);
  p.textAlign(PApplet.CENTER);
  p.text (name,vp.x+vp.w/2,vp.y+vp.h-20);
  p.popStyle();
}




} // end Sensors class
