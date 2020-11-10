package lineFollowerSim;

import processing.core.*;

/** Create a spot sensor, no public constructor is defined for this class, LFS method createSpotSensor is used instead. 
 * 
 * @author Ron Grant 
 *
 */

public class SpotSensor { 
  // note LFS class, using reflection refers to this class by name ".SpotSensor"
   
	
                                // viewing robot from above
  protected float xoff;         // sensor offset from robot center in inches (positive X=distance along robot direction of straight travel, positive Y=distance to right)
  protected float yoff;
  protected int spotWPix;
  protected int spotHPix;      // spot size in pixel
  
  public String name;       // sensor can be manually set OR using java reflection determined from variable name 
  
  private float intensity;    // normalized intensity 0.0 (black) to 1.0 (white)
  private int color; 
  private PApplet p;          // ref to processing applet
  private Sensors sensors;
  
   
 // no modifier = package private SpotSensor
 public SpotSensor (PApplet parent, Sensors sensors, float xoff, float yoff, int spotWPix, int spotHPix)  // constructor 
 {
   p = parent; 
   this.sensors = sensors;
	 
   this.xoff = xoff;
   this.yoff = yoff;
   this.spotWPix = spotWPix;
   this.spotHPix = spotHPix;
   
   // force wPix and hPix to be odd # for symmetrical pixel array sampling about sensor location
   
   if ((spotWPix & 1) == 0) spotWPix++;
   if ((spotHPix & 1) == 0) spotHPix++; 
   
   color =  p.color (0,255,0);  // default green - until user modifies 
     
   sensors.spotSensorList.add(this);   // add this new instance to list, processed by sensorUpdate()
   
   name = "";
 }
 
 /**Return spot sensor value averaged over pixels sampled by sensor 0.0 to 1.0. For example if 1/4 sensor pixels on 
  * black line and 3/4 pixels on white background value would be 0.25. 
  * 
  * @return current spot sensor intensity analog range from 0.0 to 1.0 
  * 
  */
 public float read() { return intensity; } // return current sensor value, normalized 0.0 (black) to 1.0 (white), used by controller 
 
 /**
  * Set spot rgb color after analysis for sensor overlay display, e.g. setColor(color(255,0,0));   // red
  * <p>
  *@param color Specifies integer, suggest using color(r,g,b) or color(r,g,b,alpha)  where alpha= transparency
  * 
  */
 public void setColor (int color) { this.color = color; }
 
 /**
  * Retrieve color value set, used by showSensors method.
  * @return color integer 
  */
 public int getColor () {return color; } 
 
 
 void setIntensity (float inten) { intensity = inten; }  // package private 

 /**
  *@return spot X offset (inches) from robot center 
  */
 public float getXoff() {return xoff; }

 /**
  *@return Spot Y offset (inches) from robot center.
  */
 public float getYoff() {return yoff; }
 /** Get spot width in pixels 
 *@return Spot width (pixels) 
 */
 public int   getSpotWPix() { return spotWPix; }
 /** Get spot height in pixels 
  *@return Spot height (pixels) 
  */
public int   getSpotHPix() { return spotHPix; }
 /**
  * Set spot sensor center at new xoff position in robot coordinates.
  * @param xoff X Distance (inches) from robot center. (Distance forward of center) 
  */
public void setXoff(float xoff) {this.xoff=xoff;}
 /**
  * Set spot sensor center at new yoff position in robot coordinates.
  * @param yoff Y Distance (inches) from robot center. (Distance to right) 
  */
public void setYoff(float yoff) {this.yoff=yoff;}

 /** Set sensor name. Note user application may set a default name derived from physical variable name
 * using a facility called reflection. This name may also be overridden here.
 * @param name Sensor name 
 */
public void setName (String name) { this.name = name; }
 /** Get sensor name. Note user application may set a default name derived from physical variable name
 * using a facility called reflection.
 * @return Name string. 
 */
public String getName () { return name; }
 


// no modifier package protected

float sampleSensorPixel (VP vp, int courseDPI, float xoff, float yoff)  // old pre-1.6  read the screen method 
{
 
  // note xoff,yoff are provided as parameters to allow use by LineSensor which creates an
  // array of spotSensors
	
	

 // for each sample location sample a rectangular region from -wPix/2 to wPix/2 in screen X (robot Y) 
 // and from -hPix/2 to hPix/2 in screen Y (robot X), expecting that wPix and hPix are odd values  
 
 
 int w2 = spotWPix/2;    // calc half width height in pixels for cluster rectangular sampling indicies of wPix by hPix region centered at current 
 int h2 = spotHPix/2;    // sensor location which will include line sensor index (horizontal displacement of index th sensor in the line sensor.)

 // (Made some changes - did not update Will's comment here) 
 // Image is a linear array of pixels, ie one dimension array  wjk 6-14-20
 //   index of a pixel WAS row index * image width + column index - no longer used rdg 8-22-20
 //   row index is row index of center of sensor element [width * sensorY]
 //    + pixel offset from center of sensor element [yr]
 //   column index is column index of center of sensor [width / 2]
 //    + sensor element offset [2 + x * 5]
 //    + pixel offset from center of sensor element [xr]


 int sensorY = (int) (xoff * courseDPI);  // calculate pixel offset of sensor "pixel cluster"     note robot X points up on screen in decending Y pixel coordinates 
 int sensorX = (int) (yoff * courseDPI);  // from robot center these are pixel values                  robot Y axis points to right on screen 
 
 
 // sample all pixels in sensor pixel (rectangular cluster of screen pixels) - reading Green channel 0..255 0=black 255=bright white  
 
 int count = 0;
 float sum = 0.0f;
 
 for (int yr=-h2; yr<h2+1;yr++)
 for (int xr=-w2; xr<w2+1; xr++)
 {
  int scanLine = vp.y + vp.h/2 - sensorY - yr;         // scanline number (the screen Y coordinate value)
  int pixelCol = vp.x + vp.w/2  + sensorX + xr;        // screen X coordinate calc 
    
  // screen width * scanline 
  int i = p.width*scanLine + pixelCol;              // index into 1D pixel array    
  
  if ((i>0) && (i< p.width*p.height))
  {
  sum +=  (p.pixels[i] >> 8) & 0xFF;                // sample Green channel 0..255 
  
  /*  good diagnostic, but problems possibly with P3D and some pixels showing up
   *  even without updatePixels... ??? not sure
   *  problem reported by ChrisN  getting values like 0.85 on pure white 
   *  
  if (sensors.showSampledPixels)                      // eliminated over-draw at time of sample  (1.4.1)
  {
    if ((Math.abs(yr)==h2) || (Math.abs(xr)==w2) )    // make sensor cell bounds visible
      p.pixels[i] = p.color (40);                     // dark gray boundary pixels
    else
      p.pixels[i] = p.color (100,255,100);            // mark pixel as read - pale green 
                                                      // requires updatePixels() call when finished
  } 
  */
  
  }
  
  count++;                                          // tally the number of pixels sampled   
 }
   
 return (float) (sum/count/255.0); // return normalized value 0.0 (black) to 1.0 (white)
   
}


    
}

