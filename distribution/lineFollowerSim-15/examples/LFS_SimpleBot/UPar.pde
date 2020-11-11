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
 
  float v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,vf;  // demo variables 
  int sampleInt;  // New Oct 22, 2020 !!! 
  
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
    
      Kp = p.parF(Kp,"Kp","PD controller Proportional constant",10.0,0.0,100.0,0.1);
      Kd = p.parF(Kd,"Kd","PD controller Derivative constant",10.0,0.0,100.0,0.1);    
      maxSpeed = p.parF(maxSpeed,"maxSpeed","inches/sec ",6.0,0.0,24.0,1.0);
      //sampleInt= p.parI(sampleInt,"sampleInt","sample integer",0,-10,10);  // new Int var demo
      
    
     
      v1 = p.parF(v1,"v1","Test 1",10.0,0.0,100.0,0.1); 
      
      /*
      v2 = p.parF(v2,"v2","Test 2",10.0,0.0,100.0,0.1);    
      v3 = p.parF(v3,"v3","Test 3",10.0,0.0,100.0,0.1);    
      v4 = p.parF(v4,"v4","Test 4",10.0,0.0,100.0,0.1); 
      v5 = p.parF(v5,"v5","Test 5",10.0,0.0,100.0,0.1);    
      v6 = p.parF(v6,"v6","Test 6",10.0,0.0,100.0,0.1);  
      v7 = p.parF(v7,"v7","Test 7",10.0,0.0,100.0,0.1);    
      v8 = p.parF(v8,"v8","Test 8",10.0,0.0,100.0,0.1);    
      v9 = p.parF(v9,"v9","Test 9",10.0,0.0,100.0,0.1);    
      v10 = p.parF(v10,"v10","Test 10",10.0,0.0,100.0,0.1); 
      v11 = p.parF(v11,"v11","Test 11",10.0,0.0,100.0,0.1);    
      v12 = p.parF(v12,"v12","Test 12",10.0,0.0,100.0,0.1);  
      vf  = p.parF(vf,"vf","FinalVar",10.0,0.0,100.0,0.1); 
      */
      
    p.endList(); // endList MUST be called after all parF and parI items 
  
  }
