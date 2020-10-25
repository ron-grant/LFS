package lineFollowerSim;

/**
 Rectangular viewport for Course and Robot views defined in screen absolute coordinates where the origin (0,0)
 is located at upper-left corner of screen. The positive X axis is directed to the right, and positive Y axis,
 down. In processing, the screen size can be determined by reading width and height which are defined at start of 
 program execution by size method call in setup method.
*/

public class VP  {  // ViewPort  x,y upper-left,  width height         // simple viewport 
	  public int x;
	  public int y;
	  public int w;
	  public int h;
	
	  
	  /**
	   * 
	   * @param x upper-left X pixel location offset from screen origin (0,0) at top-left of screen
	   * @param y upper-left Y pixel location 
	   * @param w width in pixels
	   * @param h height in pixels
	   */
	  public VP(int x, int y, int w, int h) {this.x=x; this.y=y; this.w=w; this.h=h;}

  /**Determine if point (x1,y1) is inside viewport rectangle 
   * 	  
   * @param x1  horizontal offset from left side of screen
   * @param y1  vertical offset from top of screen
   * @return true if point inside viewport
   */
  public boolean pointInside(int x1, int y1) { return (x1>x) && (x1<x+w) && (y1>y) && (y1<y+h); }
  /**
   * Get a copy of current viewport parameters
   * @return safe copy of viewport data, does not allow modification of x,y,w,h values  
   */
  public VP get() { return new VP(x,y,w,h);}  // generate a copy of viewport data
    
  
  }
  
 