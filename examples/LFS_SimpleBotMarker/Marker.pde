/*  Marker    Add/Remove starting location markers  which appear as magenta circles on course.
              Requires robot is not running contest (ideally stopped).
    
    Ron Grant
    October 8, 2020
    
    Click on contest course outside any existing marker circles and robot jumps to the location
    Hold Left mouse button to drag location, Hold down right button move mouse horizontally
    to change heading.
    
    Press M to mark location
    
    Click on any marked location and robot jumps to that location and adjusts heading to match the 
    heading when marker created.
    
    Press M after jumping to a marker to erase it. Also moving to close proximity of marker center
    and pressing M will erase it.
   
    
    Markers automatically loaded/saved in data folder in file with same name as course file,
    but with .mrk extension.  
    
    ----------------------------
    SimpleBotMarker has been modified with below instructions to support markers.
    Below are the instructions followed to modify original LFS_SimpleBot, i.e., loaded 
    LFS_SimpleBot, performed below, and saved as LFS_SimpleBotMarker
        
    Likewise, if you have already starting working on your controller and would like to add Marker support
    follow these instructions:
  
       
    Make sure you are running LFS library 1.0.3 or later (the release# appears in the console when you run your sketch)
    
    Create a new Tab, Named Marker and add the code that appears in this file.
    
    In UserKey tab, add below statement to keyPressed method after code to shift letters
    to uppercase.
     
     if (key == 'M') markerAddRemove();
    
    In UserDraw userDrawPanel method insert add following line to start of method 
    
      markerDraw(); 
        
    In UserInit tab, Add the following to end of userInit method
    
     markerSetup(); 
    
    In UserReset userControllerResetAndRun() of LFS_Simplebot, remove or comment out
    following 2 lines:
    
    //if (courseNum == 2)
    //lfs.setPositionAndHeading (52,12,0); 
    
    add the following line
    
    lfs.setPositionAndHeading(startLocX,startLocY,startLocHeading);
    

    Run the sketch. Move the robot somewhere interesting, rotate it to desired heading,
    press M key and magenta circle should appear.
    
   
    
   
*/
 
ArrayList <PVector> startLocList = new ArrayList<PVector>();  // list of start locations

float startLocX;              // inital location set by call to  startLocationGoto
float startLocY;              // getting close to wrapping this all in a class, with get/set methods... 
float startLocHeading; 

void markerSetup()  // call this method from your userInit method
                    // or you could call every time you issue start location key command
                    // and perhaps add some variation in values, e.g. random variation in heading... 
{
  markerLoad(); 
}


void markerSetStartLoc (float x, float y, float heading)
{
  startLocX = x;                 // inital location 
  startLocY = y;
  startLocHeading = heading;
}  
 
void startLocationDefine (float x, float y , float headingDeg)  // add new start location
{
  startLocList.add(new PVector(x,y,headingDeg));  
}

void markerAddRemove() // should be called when M pressed 
{
  float x = lfs.getRobotX();
  float y = lfs.getRobotY();
  float h = lfs.getRobotHeading();
  
  // check to see if there is a marker right at this location already, if so erase
  int i =0 ;
  for (PVector loc : startLocList) 
  {
    if (dist(loc.x,loc.y,x,y) < 1)
    {
      startLocList.remove(i);               // remove marker
      markerSave();
      return;
    }
    i++;
  }  
   
  startLocationDefine (x,y,h);  // add new start location to list    
  markerSetStartLoc (x,y,h);
  markerSave();
  
}

void markerDraw()
{
  resetMatrix();
  camera();
  stroke (255,0,255); // magenta
  ellipseMode (CENTER);
  noFill();
  strokeWeight(2);
  
 
  for (PVector loc : startLocList) 
  {
    PVector p =  lfs.courseCoordToScreenCoord (loc.x,loc.y);   // loc.z is  heading  (not needed here) 
    ellipse(p.x,p.y,30,30);
  }
   
}

String markerGetFilename() {
  String s = lfs.getCourseFilename();
  while (s.charAt(s.length()-1) != '.') s = s.substring(0,s.length()-1);
  return dataPath(s + "mrk");
}  

void markerLoad()
{
  startLocList.clear();
  File f = new File (markerGetFilename());
  if (f.exists())
  {
    String[] sList = loadStrings(markerGetFilename());
    for (String s : sList)
    {
      String[] t = s.split(",");           // split into tokens - no error checking 
      startLocList.add(new PVector (Float.parseFloat(t[0]),Float.parseFloat(t[1]),Float.parseFloat(t[2])));
    }  
    
    println (String.format("Marker file found, loaded %d markers.",startLocList.size()));
  }
  else 
    println ("No Marker File Present");
}

void markerSave()
{
  PrintWriter out = createWriter(markerGetFilename());
  for (PVector loc : startLocList)
    out.println (String.format("%1.1f,%1.1f,%1.0f",loc.x,loc.y,loc.z));  // x,y,heading
  out.close();
}



void mouseClicked()
{
  if (!lfs.contestIsRunning())
  for (PVector loc : startLocList) 
  {
    PVector p =  lfs.courseCoordToScreenCoord (loc.x,loc.y);
    
    if (dist (mouseX,mouseY,p.x,p.y) < 15)   // ellipse radius 
    {
      // below call does not work if contest running  
      lfs.setPositionAndHeading(loc.x,loc.y,loc.z);    // loc.z = heading in degrees
      markerSetStartLoc (loc.x,loc.y,loc.z);  // set initial location 
              
    }  
    
  }
 
}
