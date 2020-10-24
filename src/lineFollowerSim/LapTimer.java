package lineFollowerSim;

/*  LapTimer & Stopwatch 

    Ron Grant
    Oct 23, 2020 
    
    See main tab for usage
    
    call tick for every timeStep of time
    
    logLapTime    called when lap detected 
    clear         zeros timer and clears laps 
    
    getTimeStr    return ascii string of current "stopwatch time"
    
    showPanel     draw window with lap times 
                  default color theme dark blue BG, gray text, pale blue frame
                  
    
    TBD method of writing out laptimes 
    
   
*/

import processing.core.*;
import java.util.ArrayList;


public class LapTimer {
  
  public ArrayList <String> lapList; 
 
  PApplet p;          // reference to Processing Applet  
  LFS lfs;            // reference to LFS instance 
    
  public int backgroundColor,frameColor,textColor; 
 
  public boolean showStartTime = false;
  
  public boolean lapTimerModeEnabled;

  int lapStart = 0;
  int timerTick;
  /**
   * Maximum number of laps before robot forced to stop.
   */
  public int lapCountMax = 99;    // max lap count 
  /**
   * Current lap count
   */
  public int lapCount;            

  
  boolean lapTriggered   = false;
  boolean lapTestEnabled = false;
  float lapMinDist;                      // min distance to marker
                                         // when starts to increase lap time logged 
  /**
   * Distance when lap detector starts searching for minimum distance. As soon as 
   * distance starts increasing, lap time is logged. Technically will be one timeStep beyond
   * minimum distance.
   */
  float lapLookForEndDist = 3.0f;                   // inches max distance 
  
    
  
  public LapTimer (PApplet parent, LFS lfs)
  { 
    p = parent;
    this.lfs = lfs;
   
    lapList= new ArrayList <String> ();
    lapList.clear();
          
    backgroundColor = p.color(0,0,20);
    frameColor = p.color(80,80,150);
    textColor = p.color(240,240,240,255);
    
    lapTimerAndCountReset();
       
  }


  public void lapTimerAndCountReset()
  {	
    lapTestEnabled = lapTimerModeEnabled;  
    lapCount = 0;
	resetLapDetector();
  }  
  
  
  
  public void tick() { timerTick++; }  // call for every tick advance on lap timer 
  
  public void clear(){ timerTick=0; lapStart = 0; lapList.clear(); }

  public void logLapTime()
  {
    String lap = ticksToTimeStr(timerTick-lapStart);
    String tim = ticksToTimeStr(lapStart);
   
    int n = lapList.size();
    if (showStartTime)
      lapList.add(String.format("Lap %d %s    Start %s",n+1,lap,tim));  // mm:ss.mse   min:sec.milliseconds
    else
      lapList.add(String.format("Lap %d %s",n+1,lap)); 
   
    lapStart = timerTick;
  }

  
  public String ticksToTimeStr (int t )
  {
    int runtime = (int) Math.floor(t*lfs.getTimeStep()*1000);
    int rsec = runtime / 1000;
    int mins =   rsec/60;
    int secs =   rsec%60;
    int msecs =  runtime %1000;
  
    return String.format("%2d:%02d.%03d",mins,secs,msecs);  
  
  }
  
  public String getTimeStr() { return ticksToTimeStr (timerTick); }
  
  public void drawPanel(String title, int nvis, int x, int y, int w, int h)
  {
     int ss= 0;
     if (showStartTime) w+=90;   // expand if showStartTime
    
     int n  = lapList.size();    // number of  elements 
     
     p.pushStyle();
     p.textSize(18);
     p.textAlign(PApplet.CENTER);
     
     p.fill (backgroundColor);
     p.stroke (frameColor);
     
     p.rect (x,y,w,h,8);
     p.fill (textColor);
     p.text (title,x+w/2,y+22); 
    
     p.textAlign(PApplet.LEFT);
     
     float lineHeight = (h-50)/nvis;
     
     int st = 0;                 
     if  (n>nvis) st = n-nvis;   // calculate starting index
     int count=0;
     for (int i=0; i<n; i++)
       if ((i>=st) && (count++<=nvis))
         p.text (lapList.get(i),x+20,y+55+(count-1)*lineHeight);
  
     p.popStyle();
  }
  
 
  
  public void resetLapDetector()
  {
     lapTriggered = false;   // wait for distance >8 inches then set trigger
	 lapMinDist = 99;        // then will do min distance search.
  }
	   
 	
  /**
  * Enable lap timer with option to run in lap timer mode or regular timer mode.
  * @param lapMode if true run in lap timer mode, false normal timer  
  */
  public void lapTimerEnable(boolean lapMode)
  {	 lapTimerModeEnabled = lapMode;
	 lfs.lapTimer.clear();
  }

  
  public boolean lapTimerUpdate(boolean simRequestStep)
  {
     if (lapTimerModeEnabled) 
       drawPanel ("Lap Timer ",4,60,480,250,160);
    
     if (!simRequestStep) return (false);
  
     PVector stopLoc = lfs.getStartLocationAndHeading();  // start location =  stop location (hardcoded OR last marker clicked) 
  
     // able to access package private robot x,y 
     // user app cannot as access methods check to see if contest is running
     
     float x = lfs.robot.x;   
     float y = lfs.robot.y;
  
     float d = PApplet.dist (x,y,stopLoc.x,stopLoc.y); 
     if (d > 8.0f) lapTriggered = true;
  
     if (lapTestEnabled && lapTriggered  && (d<lapLookForEndDist))
     {
       if (d<lapMinDist) lapMinDist = d;
       else
       {
         logLapTime();
         resetLapDetector(); 
        
         if (lapList.size() >= lapCountMax)
        	 lfs.contestStop();
         
         return true;
       }
     }
     return false; // no lap detected 
  } // end lapTimerUpdate  
 
 
 
} // end LapTimer
