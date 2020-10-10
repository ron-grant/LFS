/*
   Modifications required to LFS_SimpleBotMarker to create LFS_SimpleMarkerSensor
   If you are just getting started with LFS. Ignore this information and use this Demo as your boilerplate
   and you will be good to go with  Markers and Sensors you can change on-screen display of and query with mouse
   hover.
   
   Ron Grant
   October 9, 2020
   
   
   New feature of library 1.0.3  and this code :
   Displays sensor data on robot view, or Sensor view if course hidden with Tab key press.
   Moving mouse over sensors will show sensor name and value at the bottom of the window.   
   
   
   If you have your own program which you feel would be too tricky to lift your code out of 
   and drop in this program (replacing controller.. ) then here are the steps I used to advance from
   LFS_SimpleBotMarker demo to this demo: 
      
  
  
   This demo program requires lineFollowerSim library 1.0.3 or later. When your sketch runs, you will see library
   version printed on console.
      
   Only comments are in this tab. When everything working, you might want to delete this tab.
   
   Modifications:
    
   Loaded LFS_SimpleBotMarker and performed saveAs LFS_SimpleMarkerSensorPlus  (dropped the "Bot")
   
   Note this sketch will be saved to example folder by default, but I would recommend moving out of examples folder to 
   your sketches folder. The example folder will be overwritten when downloading new edition of the LineFollowerSim
   library. 
   
   
   In main tab draw method, add the following line as the first line of the method.
   You can also delete old comment saying screen not erased
      
   background(0,0,20);  // erases window 
  
   
  Also in draw method, add if(courseTop) just before lfs.drawRobotAndCouseViews method call.
   
   if (courseTop)   // selective enable/disable controlled by Tab key
     lfs.drawRobotAndCourseViews((1,1,rotate90);  // draw robot and course, using frame divider
 
  
  In UserCon tab, userControllerUpdate method after  
  line   float e = calcSignedCentroidSingleDarkSpan(sensor) ;
  add the following  ~20 lines of code :
    
  // Added example code of accessing line sensor color table and modifying it for display
  int[] colorTable = sensor1.getColorArray();  // get reference to sensor color table
  int n = sensor1.getSensorCellCount();
  for (int i=0; i<n; i++) 
  {
    color c =  color (0,0,50); // dark blue
    if ((i > n/2-e-3) && (i < n/2-e+3)) c = color (255,0,0); // red 
    colorTable[i] = c;
  }
  
  // update sensor colors on spot sensors even though not used
  
  if (sensorL.read() > 0.5) sensorL.setColor (color(0,0,100));
  else sensorL.setColor(color(255,0,0));
 
  if (sensorM.read() > 0.5) sensorM.setColor (color(0,0,100));
  else sensorM.setColor(color(255,0,0));
 
  if (sensorR.read() > 0.5) sensorR.setColor (color(0,0,100));
  else sensorR.setColor(color(255,0,0));
  
  
   
  To UserDrawPanel  userDrawPanel method add this line as first line
  
   lfs.showSensors((courseTop)?'R':'S');    // new Oct 7, 2020
  
  Just below that line add  if(courseTop) before lfs.markerDraw() so it appears as:
   
   if (courseTop) lfs.markerDraw();  // only display markers when course visible 
   
   
   In userInit, after sensor definitions add this line to 
  name the sensors for ID when mouse hover over robot/sensor view.
  
  nameSensorsUsingVariableNames();                  // use java reflection to look up sensor names and assign them to sensor name
   
  Finally Copy The below import statment and the 
  the method that follows to your main sketch tab, after draw at end of file
  In this case would be LFS_SimpleMarkerSensorPlus
   
   
 import java.lang.reflect.*;  // java reflection used to lookup sensor names 
 
 public void nameSensorsUsingVariableNames()  // use java reflection   
 {
  PApplet p = this; // p is current instance of PApplet
  
  println ("SpotSensors");
  for(Field f : p.getClass().getDeclaredFields())   
  {
     if(f.getType() == SpotSensor.class)
     {
       String name = f.getName(); 
       try {
    
       SpotSensor ss = (SpotSensor) (f.get(p));  // access class instance
       if (ss.getName() == null) ss.setName(name);
       println (name, ss.getXoff(), ss.getYoff()); 
       } catch (IllegalAccessException e)
       {}
     }
   
  } 

  println ("LineSensors");
  for(Field f : p.getClass().getDeclaredFields())
  {
     if(f.getType() == LineSensor.class)
     {
       String name = f.getName();
       try {
         LineSensor ls = (LineSensor) (f.get(p));  // access class instance
        
         if (ls.getName() == null) 
          ls.setName(name);             // set sensor default name using variable name 
         println (name, ls.getXoff(), ls.getYoff()); 
       }
       catch (IllegalAccessException e)
       {
       }
  
     } 
  }
} // end method  nameSensorsUsingVariableNames   
   
   
   
    
   
   
   Saved sketch and run!
   
   
*/
