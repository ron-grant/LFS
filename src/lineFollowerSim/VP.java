package lineFollowerSim;

class VP  {  // ViewPort  x,y upper-left,  width height         // simple viewport  - package private 
	  int x; int y; int w; int h; 
	  VP(int _x, int _y, int _w, int _h) {x=_x; y=_y; w=_w; h=_h;}
	
  public boolean pointInside(int x1, int y1) { return (x1>x) && (x1<x+w) && (y1>y) && (y1<y+h); }	  
	  
  }
  
 