package lineFollowerSim;

import processing.core.*;
import java.util.ArrayList;
import java.io.PrintWriter;
import java.io.File;


class Marker {
    PApplet p;   // parent
	
	ArrayList <PVector> startLocList = new ArrayList<PVector>();  // list of start locations

	float startLocX;              // inital location set by call to  startLocationGoto
	float startLocY;              // getting close to wrapping this all in a class, with get/set methods... 
	float startLocHeading; 

	boolean markerSetupHasRun; 
	
	LFS lfs; // the instance of lfs
	
  Marker(PApplet parent, LFS lfsInstance )    // package private constructor used by LFS
  { p = parent;
    lfs = lfsInstance;
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
  startLocList.add(new PVector(x,y,headingDeg));  
}

void gotoStartLocation(LFS lfs)
{
  lfs.setPositionAndHeading(startLocX,startLocY,startLocHeading);
  
}

void addRemove(float x, float y, float heading) // should be called when M pressed 
{
  
  // check to see if there is a marker right at this location already, if so erase
  int i =0 ;
  for (PVector loc : startLocList) 
  {
    if (PApplet.dist(loc.x,loc.y,x,y) < 1)
    {
      startLocList.remove(i);               // remove marker
      markerSave();
      return;
    }
    i++;
  }  
   
  startLocationDefine (x,y,heading);  // add new start location to list    
  markerSetStartLoc (x,y,heading);
  markerSave();
  
}

void draw()
{
  p.pushMatrix();
  p.pushStyle();
  
  
  p.resetMatrix();
  p.camera();
  
  p.stroke (255,0,255); // magenta
  p.ellipseMode (PApplet.CENTER);
  p.noFill();
  p.strokeWeight(2);
  
 
  for (PVector loc : startLocList) 
  {
    PVector pt =  lfs.courseCoordToScreenCoord (loc.x,loc.y);   // loc.z is  heading  (not needed here) 
    p.ellipse(pt.x,pt.y,30,30);
  }
  
  p.popMatrix();
  p.popStyle(); 
   
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
      startLocList.add(new PVector (Float.parseFloat(t[0]),Float.parseFloat(t[1]),Float.parseFloat(t[2])));
    }  
    
    PApplet.println (String.format("Marker file found, loaded %d markers.",startLocList.size()));
  }
  else 
    PApplet.println ("No Marker File Present");
}

private void markerSave()
{
  PrintWriter out = p.createWriter(markerGetFilename());
  for (PVector loc : startLocList)
    out.println (String.format("%1.1f,%1.1f,%1.0f",loc.x,loc.y,loc.z));  // x,y,heading
  out.close();
}

boolean handleMouseClick()
{
  // called if contest not running
	
  for (PVector loc : startLocList) 
  {
    PVector pt =  lfs.courseCoordToScreenCoord (loc.x,loc.y);
    
    if (PApplet.dist (p.mouseX,p.mouseY,pt.x,pt.y) < 15)   // ellipse radius 
    {
      // below call does not work if contest running  
      lfs.setPositionAndHeading(loc.x,loc.y,loc.z);    // loc.z = heading in degrees
      markerSetStartLoc (loc.x,loc.y,loc.z);  // set initial location
      return true;
    }  
    
  }
  return false; 
}

} // end Marker Class