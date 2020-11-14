  /* UserPar    User Parameter Editor  Support added in LFS library 1.4   
    
    User specifies a list of primitive float and int variables via method calls
    used by parameter editor to create a screen of runtime interactive adjustable values. 
    
    A default value is specified which is assigned to the variable on the first invocation 
    of parEditorUpdate().
       
    This LFS_SimpleBot sketch setup for parameter editing. If you want to modify
    an older LFS sketch to support Parameter Editor, it is easiest to drop your code into
    this sketch, replacing UserCon,UserDraw,UserInit,UserReset tabs with copies of your data.
    
    Note: There have been some enhancements to UserInit (lib 1.4.2) Take a look at it. Now includes
          course list, icon select/generation 
            
*/        
 
   int sampleInt; // example integer variable
   float iconOpacity = 1.0;  // new demo, helpful to make robot near invisible when looping fast  (lib 1.6)
 
  // note some varaibles defined above, others like Kp,Kd defined elsewhere as global variables
  
  void parEditorUpdate()
  {
    ParEditor p = parEditor;    // p is shorthand reference to parameter editor within this method  
 
    p.beginList();    // beginList MUST be called before parameters (series of ParF / ParI calls).   
  
      timeWarpMult = p.parI(timeWarpMult,"Time Warp Multiplier","",50,1,500);       // max number of updates per screen draw
      iconOpacity  = p.parF(iconOpacity,"Course Icon Opacity","",1.0,0.0,1.0,0.1);  // 0.0 (invisible) to 1.0 (opaque)
     
      lfs.setRobotIconAlpha((int) (255.0 * iconOpacity)); // override opacity set in UserInit  0..255 
  
  
      // user adjustable parameters 
      // var = p.parF(var,"varName","VarDescription",default,min,max,delta)
      // using object types Float and Integer would have made this a bit cleaner, but I like 
      // primitive floats and ints so here it is:
    
      Kp = p.parF(Kp,"Kp","PD controller Proportional constant",10.0,0.0,100.0,0.1);
      Kd = p.parF(Kd,"Kd","PD controller Derivative constant",10.0,0.0,100.0,0.1);    
      maxSpeed = p.parF(maxSpeed,"maxSpeed","inches/sec ",6.0,0.0,24.0,1.0);
      sampleInt= p.parI(sampleInt,"sampleInt","sample integer",0,-10,10);  // new Int var demo
     
   
    p.endList(); // endList MUST be called after all parF and parI items 
  
  }
