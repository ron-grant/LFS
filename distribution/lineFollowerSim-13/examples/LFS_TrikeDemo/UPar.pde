 /* UserPar    User Parameter Editor  Support added in LFS library 1.4   
    
    User specifies a list of primitive float and int variables via method calls
    used by parameter editor to create a screen of runtime interactive adjustable values. 
    
    A default value is specified which is assigned to the variable on the first invocation 
    of parEditorUpdate().
       
    This LFS_SimpleBot sketch setup for parameter editing. If you want to modify
    an older LFS sketch to support Parameter Editor, it is easiest to drop your code into
    this sketch, replacing UserCon,UserDraw,UserInit,UserReset tabs with copies of your data.
    
    Of course you will want to make parEditorUpdate to include your own
    float or int variables.
    
    delta is amount variable changes with one mouse wheel click, one press of + or - key or
    by mouse horizitonal motion with left button held down.
    
    min and max define ranges, see format below 
    
        
*/        
 
  
  float speed;
  
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
      
          
      timeWarpMult = p.parI(timeWarpMult,"Time Warp Multiplier","",10,1,100);      // max number of updates per screen draw
      iconOpacity  = p.parF(iconOpacity,"Course Icon Opacity","",1.0,0.0,1.0,0.1);  // 0.0 (invisible) to 1.0 (opaque)
          
      lfs.setRobotIconAlpha((int) (255.0 * iconOpacity)); // override opacity set in UserInit  0..255    
      
      
      //Kp = p.parF(Kp,"Kp"," PD  Proportional Error Constant",3.0, 0.0,20.0, 0.1);
      //Kd = p.parF(Kd,"Kd"," PD  Derivative Error Constant",0.4, 0.0,20.0, 0.1);
        
         
             
       
      //maxSpeed = p.parF(maxSpeed,"maxSpeed","inches/sec ",6.0,0.0,24.0,1.0);
      
      //trike.wheelVelocity = speed;  // force wheel speed to param value 
      //currentRobotState.wheelVelocity = speed; 
  
   
      
    p.endList(); // endList MUST be called after all parF and parI items 
  
  
  
  }
  
  
  
  
