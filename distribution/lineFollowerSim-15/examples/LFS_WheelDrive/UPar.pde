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
 
  float iconOpacity = 1.0;  // new demo, helpful to make robot near invisible when looping fast  (lib 1.6)
  
  void parEditorUpdate()
  {
    ParEditor p = parEditor;    // p is shorthand reference to parameter editor within this method  
 
    p.beginList();    // beginList MUST be called before parameters (series of ParF / ParI calls).   
  
      //  User adjustable parameters 
      //
      //  var = p.parF(var,"varName","VarDescription",default,min,max,delta)
      //  var = p.parI(var,"varName","VarDescription",default,min,max)           implicit delta = 1
      //
      // You can put what you wish in 2 strings. Variable name in first string is suggestion only.
      // For now having to use   variable = f(variable).  Java does not support call by reference for primitive types.
      
     
      timeWarpMult = p.parI(timeWarpMult,"Time Warp Multiplier","",50,1,100);      // max number of updates per screen draw
      iconOpacity  = p.parF(iconOpacity,"Course Icon Opacity","",1.0,0.0,1.0,0.1);  // 0.0 (invisible) to 1.0 (opaque)
     
      lfs.setRobotIconAlpha((int) (255.0 * iconOpacity)); // override opacity set in UserInit  0..255 

      // user adjustable parameters 
      // var = p.parF(var,"varName","VarDescription",default,min,max,delta)
      // using object types Float and Integer would have made this a bit cleaner, but I like 
      // primitive floats and ints so here it is:
    
      speedClear = p.parF(speedClear,"speedClear","inches/sec ",6.0, 0.0,30.0, 0.5);   
      speedTurn = p.parF(speedTurn,"speedTurn","inches/sec ",7.0, 0.0,30.0, 0.5);     
      sensorSep = p.parF(sensorSep,"sensorSep","inches (controller ON to see)",1.5,0.5,5.0,0.2);  
      
            
      //sampleInt= p.parI(sampleInt,"sampleInt","sample integer",0,-10,10);  // new Int var demo
     
      
    p.endList(); // endList MUST be called after all parF and parI items 
  
  }
