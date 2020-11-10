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


private int sensorTotalSpotCount;   // enumerated every call to updateSensors


// variables used for line sensor spot location calculation 
private int sensorN;    
private float halfWidth;
int dpi;
float sinA,cosA; 
float xoff,yoff;
public boolean sensorImageRead = true;        // New Super Fast when true
boolean diagDrawOnCourseImage = false; // normally false - slow down 
                                       // good for checking logic on new sampleSensorPixel
// new values for direct image read 

private float cosH;         // sine heading angle       used for every spot sensor 
private float sinH;         // cosine heading angle     pre-computed just in case high spot count 
private PImage courseImage; // reference to course image
private Robot robot;        // reference to robot
private boolean drawOnCourseImage; // diagnostic normally false
private int nPix;            // number of pixels in bitmap - for range test



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

  halfWidth = (sensorN / 2.0f * ls.getSpotWPix()) / dpi;      // half width of line sensor in inches 
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
  else y = ((0.5f+index)*ls.getSpotHPix()/dpi) - halfWidth;   // straight line 
                   
  result.x = xoff + x * cosA - y * sinA;   // rotate spot sensor sensor  
  result.y = yoff + x * sinA + y * cosA;   // about sensor origin (center of sensor array                               

}



void update(VP vp, PImage courseImage, Robot robot, int courseDPI)  // called after sensor view draw (64 DPI image - now on screen) 


                    // iterates through sensor lists, reading all sensor values and storing within sensor class instances
                    // spot sensors sample a single cluster (rect array) of pixels
                    // line sensors sample a linear cluster array or clusters of pixels 
                   
{
 dpi = courseDPI;   // set local DPI used in calculations
 
 this.robot = robot;
 this.courseImage = courseImage;
 
 //if (courseImage != null)
//	  courseImage.loadPixels(); // done at load time - try here - likely slow down prog.  !!!
 
 
 
 if (!sensorImageRead)
   p.loadPixels(); // prepare to access screen pixels in pixels[] array
 else
   imageReadSensorSetup();   
 
 // update spot sensors 
 
 sensorTotalSpotCount = 0;
 
 
 // note: xoff,yoff explicitly sent to imageReadSensorSpot due to line sensor loop calc of xoff yoff

 for (SpotSensor ss : spotSensorList)
 {
   if (!sensorImageRead) ss.setIntensity(ss.sampleSensorPixel(vp,courseDPI,ss.getXoff(),ss.getYoff())); 
   else
	 ss.setIntensity(imageReadSensorSpot(ss,ss.getXoff(),ss.getYoff()));  // new local to Sensors, fast mode image direct 
   
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
	 if (!sensorImageRead) sensorTable[index] = ls.sampleSensorPixel(vp,courseDPI,spotLoc.x,spotLoc.y);
	 else sensorTable[index] = imageReadSensorSpot((SpotSensor) ls, spotLoc.x, spotLoc.y); // fast image read 
                              
   } 
   sensorTotalSpotCount+=sensorN;  // tally total #of sensor elements (spots)
   
 }
 
 
 
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
   
   float rvScale =  1.0f;  // robot view scale down factor   new 1.4 applied to rect w,h
   
   // if robot view
   if (vportID=='R')
   {
	 rvScale =  1.0f*vp.w/svp.w;  // robot view scale down factor   new 1.4 applied to rect w,h  
     sc = sc * rvScale;
   }  
     
   for (SpotSensor ss : lfs.sensors.spotSensorList)
   {
     float x = ss.getXoff();
     float y = ss.getYoff();
     float w = rvScale * ss.getSpotWPix();
     float h = rvScale * ss.getSpotHPix();
   
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
     float w = ls.getSpotWPix() * rvScale;
     float h = ls.getSpotHPix() * rvScale;
   
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
{                                             // used when mouse location is close to sensor location 
   
  p.pushStyle();                              // display sensor name at bottom of viewport  
  p.fill (20);
  p.rectMode(PApplet.CORNER);
  p.rect (vp.x,vp.y+vp.h-50,vp.w,50);
  p.textSize (20);
  p.fill (240);
  p.textAlign(PApplet.CENTER);
  p.text (name,vp.x+vp.w/2,vp.y+vp.h-20);
  p.popStyle();
}


void imageReadSensorSetup()
{
  
   float rh = PApplet.radians(robot.heading);
   cosH = PApplet.cos(rh);                         // cosine and sine of robot heading angle 
   sinH = PApplet.sin(rh);                         // common to all spot sensors and line sensor spot elements 
  
   if (courseImage != null)
     nPix = courseImage.width * courseImage.height; // number of pixels in bitmap
  // courseDPI = lfs.courseDPI ;
}
 

// NEW Fast Method Nov 3, 2020 

float imageReadSensorSpot(SpotSensor ss,float sensorX,float sensorY)   // return intensity of spot  
{
  
  int spotW =  ss.getSpotWPix();
  int spotH =  ss.getSpotHPix();

  
  if ((courseImage == null) || (nPix == 0)) return 0.0f;
  
    
  PImage c = courseImage;     // reference to course image 
  int cw = c.width;           // width of course bitmap
  
  float cx = robot.x * dpi;   // course map pixel location of robot center, allowing fractional pixels 
  float cy = robot.y * dpi;   // converting inches to pixel units
  
  // calculate location of center of sensor rectangle in world (course) coordinates 
  // rotating sensor location which is relative to robot center (robot coordinates)
  //
  // robotX+ in direction of robot heading, when robot heading 0 this is world -X axis
  // robotY+ is to right of robot, when robot heading 0 this is world -Y axis
    
  float sx = sensorX * cosH - sensorY * sinH;
  float sy = sensorX * sinH + sensorY * cosH;
    
  float xCenter = cx - sx * dpi;    // sensor rectangle sensor in world coordinates (image coordinate system)
  float yCenter = cy - sy * dpi;
  
  // sample rotated rectangle that is spotW by spotH pixels in image 
  // first calculating "lower-left" corner point xStart,yStart
      
  float x1 = spotH/2.0f;
  float y1 = spotW/2.0f;
  
  float xr =  cosH*x1 - sinH*y1;    // rotate corner point location in sensor coordinates by robot heading angle 
  float yr =  sinH*x1 + cosH*y1;    // that is, rotate about spot rectangle's center 
     
  float xStart = xCenter + xr;     // world coordinate location of sensor rectangle "lower-left" corner
  float yStart = yCenter + yr;     // in image pixel units (1/64th inch each) 

  
  // calculate step as progress across rectangle  and also down on spot rectangle
  // scale is 1:1  so in unrotated case dx=0 dy=-1
                         
  float dx = sinH;       // column step  applied 0 to spotW (pixels)
  float dy = -cosH;    
  
  // delta x,y for "left most" pixel of each row of pixels starting at corner point (xStart,yStart)
  
  float dxRow = -cosH;   
  float dyRow = -sinH;
   
  int sum = 0;
  
  // sample rotated rectangle pixel array 
 
  for (int h = 0; h<spotH; h++)
  {
    // calculate left most pixel of current row (h) of rotated spot rectangle 
    
    float x = xStart;
    float y = yStart;
      
    for (int w = 0; w<spotW; w++)
    {
      x+= dx;   // compute x,y as progress one pixel at a time  in the spot width direction 
      y+= dy;   // because spot rectangle is rotated deltaX and deltY component 
      
      // truncate or round  x,y ?
      // pixel coordinates for bitmap (stored in 1D array cw pixels wide for each row of pixels indexed by y
      // with offset (column) x.
      // 0,0 is upper-left corner of image   where x progresses to right for a total of cw pixels then
      // advance next row (0,1);
      
      // should do range test ,perhaps bounding box on spot and not here   !!!
      
      int offset = cw *(int) y + (int) x; 
        
      // color pixels in sample rectangle 
      // lower-left black    increasing red  along width axis
      //                     increasing blue along height axis
      // magenta upper-right   
      
      if  ((offset>-1) && (offset<nPix)) 
      {
         int gr = (c.pixels[offset] >> 8) & 0xFF;
         sum += gr;
         
         if  (drawOnCourseImage)  // diagnostic -- normally disabled 
         { 
            if (gr<10) c.pixels[offset] = p.color(0,255,0); 
            else
            if ((w<5) && (h<5))  c.pixels[offset] = p.color (255,0,0);     // green block
            else  c.pixels[offset] = p.color(255*w/spotW,0,255*h/spotH);   // color increasing
            
         }
         
      }
    }  // end for w
    
    xStart += dxRow;     // advance to Start of next row, along the "height" side of the spot
    yStart += dyRow; 
    
  } // end for h
  
  if (drawOnCourseImage) 
  {
    p.fill(0,255,255);
    for (int y=-3;y<3;y++)
    for (int x=-3;x<3;x++)
      c.pixels[((int) yCenter+y)*cw + x+ (int) xCenter] = p.color (0,255,255);
    
    c.updatePixels();  // normally not enabled -- takes time
  }
 
	
  return 1.0f * sum /255.0f/(spotW*spotH);
  
}	




boolean verboseSensorNames = false;  // added (lib 1.6)
/**
 *  Iterate through defined sensors and assign their variable name to their 
 *  name. This is used to ID sensors when mouse hovering over robot/sensor view.
 *  This method is called in UserInit tab after defining all sensor instances.
 */
public void nameSensorsUsingVariableNames()  // (lib 1.3)
  {
  //PApplet p = this; // p is current instance of PApplet 
  // inside LFS p assigned to PApplet instance ref upon instance created 	
	
  
  if (verboseSensorNames) PApplet.println ("SpotSensors");  
  for(Field f : p.getClass().getDeclaredFields())   
  {
	  
	//diagnostic   
	//PApplet.println(String.format("Ref>>[%s] %s",f.getName(),f.getType().getName()));

     if(f.getType().getName().contains(".SpotSensor"))   // applicationName.SpotSensor
     {
   
       
       String name = f.getName(); 
       try {
    
       //PApplet.println(String.format("trying to assign name %s to class instance",name));   
    	
       // Field.get(Object obj) obj = object from which fields are to be extracted 
       // in this case the Processing Applet instance  p
            
       //PApplet.println(String.format("trying to assign name %s to class instance",name));   
       
       f.setAccessible(true);  // prevents get from throwing exception   
       SpotSensor ss = (SpotSensor) (f.get(p));  // access class instance
       if (ss.getName().length()==0) ss.name = name;
      
       if (verboseSensorNames) PApplet.println (name, ss.getXoff(), ss.getYoff()); 
       } catch (IllegalAccessException e)
       {
    	 PApplet.println("Illegal Access Exception");
    	 //e.printStackTrace();
    	   
       }
     }
   
  } 

  if (verboseSensorNames) PApplet.println ("LineSensors");  
  
  for(Field f : p.getClass().getDeclaredFields())
  {
     if(f.getType().getName().contains(".LineSensor"))  // name is lineFollowerSim.LineSensor
     {
       String name = f.getName();
       try {
    	 //PApplet.println(String.format("trying to assign name %s to class instance",name));  
    	
    	 f.setAccessible(true);   // this prevents next line from throwing exception 
    	                          // was not needed within  Processing app. 
         LineSensor ls = (LineSensor) (f.get(p));  // access class instance
      
        if (ls.getName().length() ==0) ls.name = name;   // set sensor default name using variable name 
        if (verboseSensorNames) PApplet.println (name, ls.getXoff(), ls.getYoff());  
       }
       catch (IllegalAccessException e)
       {
    	 PApplet.println("Illegal Access Exception");
         //e.printStackTrace();
       }
  
     } 
     
     
     
  }

} // end method   







} // end Sensors class
