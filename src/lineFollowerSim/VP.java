package lineFollowerSim;

/**
 Rectangular viewport for Course and Robot views.  

*/

public class VP  {  // ViewPort  x,y upper-left,  width height         // simple viewport  - package private 
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
	
  public boolean pointInside(int x1, int y1) { return (x1>x) && (x1<x+w) && (y1>y) && (y1<y+h); }	  
	  
  }
  
 