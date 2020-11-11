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

/**
 * LapTimer provides stopwatch and lap timer support for LFS.
 * @author Ron Grant
 *
 */
public class LapTimer {
  /**
   * ArrayList of lap times in String format "Lap X  mn:se.msc" X=lap,
   *  mn = minutes, se = seconds, msc = milliseconds 0 to 999.
   */
  public ArrayList <String> lapList; 
 
  PApplet p;          // reference to Processing Applet  
  LFS lfs;            // reference to LFS instance 
  /**
   * lap timer pane background color, default dark blue  
   */
  public int backgroundColor;
  /**
   * lap timer window border color, default light blue
   */
  public int frameColor;
  /**
   * lap timer text color, default off-white rgb (240,240,240).
   */
  public int textColor; 
 
  /**
   * Set true to include lap start time in lapTimer panel display. Increases
   * window width by about 90 pixels.
   */
  public boolean showStartTime = false;
  
  public boolean lapTimerModeEnabled;

  int lapStart = 0;
  int timerTick;
  /**
   * Maximum number of laps before robot forced to stop.
   */
  public int lapCountMax = 99;    // max lap count 
 
  int lapCount;            

  /**
   * Get number of laps completed.
   * @return number of laps completed
   */
  public int getLapCount() { return lapCount; }
  
  
  boolean lapTriggered   = false;
  boolean lapTestEnabled = false;
  float lapMinDist;                      // min distance to marker
                                         // when starts to increase lap time logged 
  /**
   * Distance when lap detector starts searching for minimum distance. As soon as 
   * distance starts increasing, lap time is logged. Technically will be one timeStep beyond
   * minimum distance.
   */
  public float lapLookForEndDist = 3.0f;                   // inches max distance 
  
    
  /**
   * Constructor for single instance of LapTimer
   * @param parent Parent Applet reference, "this"
   * @param lfs Reference to single instance of LFS class, i.e., lfs
   */
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

 /**
  * Reset stop watch timer, and clear lapList
  */
  public void lapTimerAndCountReset()
  {	
    lapTestEnabled = lapTimerModeEnabled;  
    lapCount = 0;
    clear();    // reset timer
	resetLapDetector();
  }  
  
  
  /**
   * Call for every tick advance on lap timer
   */
  void tick() { timerTick++; }  // call for every tick advance on lap timer 
  
  
  /**
   * Get current timer tick, not available if contest is running.
   * @return timerTick in time steps taken
   */
  public int getTick() { if (lfs.contestIsRunning()) return 0; else return timerTick; }
  
  /**
   * Get current timer tick, not available if contest is running.
   * @param current timer tick, time in time steps taken 
   */
  public void setTick(int tick) { if (!lfs.contestIsRunning()) timerTick = tick; }
  
  
  
  void clear(){ timerTick=0; lapStart = 0; lapList.clear(); }

  
  /**
   * Add current lap time to list, update lapStart time to now current (timerTick)
   */
  void logLapTime()
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

  /**
   * Given number of timer ticks, convert to formatted time mn:se.millis   e.g. 1:02.345
   * @param t number of ticks to be multiplied by timeStep to arrive at elapsed time.
   * @return String formatted mn:se.millisec 
   */
  public String ticksToTimeStr (int t )
  {
    int runtime = (int) Math.floor(t*lfs.getTimeStep()*1000);
    int rsec = runtime / 1000;
    int mins =   rsec/60;
    int secs =   rsec%60;
    int msecs =  runtime %1000;
  
    return String.format("%2d:%02d.%03d",mins,secs,msecs);  
  
  }
  
  
  /**
   * Return time string for current time logged on stopwatch (total time elapsed)
   * @return time string formatted  mn:se.millis 
   */
  public String getTimeStr() { return ticksToTimeStr (timerTick); }
  /**
   * Draw panel containing lap times or lap times and start of lap
   * @param title  Title string to be placed top center of panel
   * @param nvis   Number of visible lines (depends on h) up to user to calibrate 
   * @param x      X offset of panel from screen upper-left corner (pixels)
   * @param y      Y offset of panel
   * @param w      panel width 
   * @param h      panel height 
   */
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
  
 
  
  void resetLapDetector()
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

  /**
   * Call every time step
   * @param simRequestStep set true if simulation is taking timestep, timer will increment one tick.
   * @return Returns true if lap detected and logged
   */
  public boolean lapTimerUpdate(boolean simRequestStep)
  {
     //if (lapTimerModeEnabled)  -- draw called explicitly now (lib 1.6)
     //  drawPanel ("Lap Timer ",4,60,480,250,160);
    
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
         lapCount++;
        
         if (lapList.size() >= lapCountMax)
         { 	 
        	// (lib 1.6.1) let app handle final lap count 
        	//if (lfs.contestIsRunning()) lfs.contestStop();
        	//else lfs.stop();
         }	
         
         return true;
       }
     }
     return false; // no lap detected 
  } // end lapTimerUpdate  
 
 
 
} // end LapTimer
