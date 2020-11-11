package lineFollowerSim;

import processing.core.*;
import java.util.ArrayList;
import java.io.PrintWriter;
import java.io.File;

class Marker {
    PApplet p;   // parent
    
   
   class MarkerItem {
    	  float x;
    	  float y;
    	  float heading;
    	  boolean robotStateInfoPresent;
    	  
    	  MarkerItem(float xpos, float ypos, float heading) {
    	    x=xpos;
    	    y=ypos;
    	    this.heading = heading;
    	    robotStateInfoPresent = false;
    	  }
   } 	  
   
	
	ArrayList <MarkerItem> startLocList = new ArrayList<MarkerItem>();  // list of start locations


	float startLocX;              // initial location set by call to  startLocationGoto
	float startLocY;              // getting close to wrapping this all in a class, with get/set methods... 
	float startLocHeading;       
	                              

	boolean markerSetupHasRun;
	
	int ssR,ssG,ssB; // rgb color   animation for saved state rectangle  
	float ssScale;
	float ssRotSpeed;
	float ssTheta; 
	
	
	LFS lfs; // the instance of lfs
	
  Marker(PApplet parent, LFS lfsInstance )    // package private constructor used by LFS
  { p = parent;
    lfs = lfsInstance;
  }

  
void markerNotifySavedState(float xs, float ys)
{
  for (MarkerItem mi : startLocList)
   if (PApplet.dist(xs,ys,mi.x,mi.y) < 1.0) mi.robotStateInfoPresent = true;
}
  
void savedStateColorScaleSpeed (int r, int g, int b, float scale, float rotationSpeed)
{
  ssR = r;
  ssG = g;
  ssB = b;
  ssScale = scale;
  ssRotSpeed = rotationSpeed;
	
}


void setup(float x, float y, float heading)  // call this method from your userInit method using LFS (lfs.markerSetup() )
{
  markerLoad(); 
  
  if (!markerSetupHasRun)  
  markerSetStartLoc (x,y,heading);  // initial position before clicking on any markers 
                                                                
  markerSetupHasRun = true;
  
}


void markerSetStartLoc (float x, float y, float heading)
{
  startLocX = x;                 // initial location 
  startLocY = y;
  startLocHeading = heading;
}  
 
void startLocationDefine (float x, float y , float headingDeg)  // add new start location
{
  startLocList.add(new MarkerItem (x,y,headingDeg));  
}

void gotoStartLocation(LFS lfs)
{
  lfs.setPositionAndHeading(startLocX,startLocY,startLocHeading);
  
}

boolean addRemove(float x, float y, float heading) // should be called when M pressed 
{
  
  // check to see if there is a marker right at this location already, if so erase
  int i =0 ;
  for (MarkerItem mi : startLocList) 
  {
    if (PApplet.dist(mi.x,mi.y,x,y) < 1)
    {
      startLocList.remove(i);               // remove marker
      markerSave();
      return false;
    }
    i++;
  }  
   
  startLocationDefine (x,y,heading);  // add new start location to list    
  markerSetStartLoc (x,y,heading);
  markerSave();
  return true; 
}

void draw()
{
  p.pushMatrix();
  p.pushStyle();
  
  
  p.resetMatrix();
  p.camera();
  
  p.stroke (255,0,255); // magenta
  p.ellipseMode (PApplet.CENTER);
  p.rectMode(PApplet.CENTER);
  p.noFill();
  p.strokeWeight(2);
  
 
  for (MarkerItem mi : startLocList) 
  {
    PVector pt =  lfs.courseCoordToScreenCoord (mi.x,mi.y);   //  heading  (not needed here)
   
    p.stroke (255,0,255);      // magenta
    p.ellipse(pt.x,pt.y,30,30);
    
  	
	float savedStateTheta; 
    
    if (mi.robotStateInfoPresent) {
      p.stroke (ssR,ssG,ssB);              // light blue
    
      p.pushMatrix();
      p.translate(pt.x,pt.y);
      p.rotate(ssTheta);
      p.scale(ssScale);
      p.rect(0,0,30,30);
      p.popMatrix();
      
      mi.robotStateInfoPresent = false;
    }
    
    
    
    
  }
  
  ssTheta += PApplet.radians(ssRotSpeed);
  
  p.popMatrix();
  p.popStyle(); 
   
}

float getClosestDist(float x, float y)
{
  float dmin = 99999;	
  for (MarkerItem mi : startLocList) 
  {	
	float d2 = PApplet.sq(mi.x-x)+ PApplet.sq (mi.y-y);
	if (d2 < dmin) dmin = d2;
  }
  
  return PApplet.sqrt(dmin);
	
}


private String markerGetFilename() {
  String s = lfs.getCourseFilename();
  while (s.charAt(s.length()-1) != '.') s = s.substring(0,s.length()-1);
  return p.dataPath(s + "mrk");
}  

private void markerLoad()
{
  startLocList.clear();
  File f = new File (markerGetFilename());
  if (f.exists())
  {
    String[] sList = p.loadStrings(markerGetFilename());
    for (String s : sList)
    {
      String[] t = s.split(",");           // split into tokens - no error checking 
      startLocList.add(new MarkerItem (Float.parseFloat(t[0]),Float.parseFloat(t[1]),Float.parseFloat(t[2])));
    }  
    
    PApplet.println (String.format("Marker file found, loaded %d markers.",startLocList.size()));
  }
  else 
    PApplet.println ("No Marker File Present");
}

private void markerSave()
{
  PrintWriter out = p.createWriter(markerGetFilename());
  for (MarkerItem loc : startLocList)
    out.println (String.format("%1.4f,%1.4f,%1.4f",loc.x,loc.y,loc.heading));  // x,y,heading  - increased accuracy, 4 digits (lib 1.5)
  out.close();
}

boolean handleMouseClick()
{
  // called if contest not running
	
  for (MarkerItem loc : startLocList) 
  {
    PVector pt =  lfs.courseCoordToScreenCoord (loc.x,loc.y);
    
    if (PApplet.dist (p.mouseX,p.mouseY,pt.x,pt.y) < 15)   // ellipse radius 
    {
      // below call does not work if contest running  
      lfs.setPositionAndHeading(loc.x,loc.y,loc.heading);    // loc.z = heading in degrees
      markerSetStartLoc (loc.x,loc.y,loc.heading);  // set initial location
      return true;
    }  
    
  }
  return false; 
}

} // end Marker Class