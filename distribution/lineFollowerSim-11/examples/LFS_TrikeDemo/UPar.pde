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
    
    
    
        
*/        
 
  float Kp,Kd;  // demo variables 
  
  void parEditorUpdate()
  {
    ParEditor p = parEditor;    // p is shorthand reference to parameter editor within this method  
 
    p.beginList();    // beginList MUST be called before parameters (series of ParF / ParI calls).   
  
      // user adjustable parameters 
      // var = p.parF(var,"varName","VarDescription",default,min,max,delta)
      // using object types Float and Integer would have made this a bit cleaner, but I like 
      // primitive floats and ints so here it is:
    
      // demo values not trike bot values 
      Kp = p.parF(Kp,"Kp","demo param",10.0,0.0,100.0,0.1);
      Kd = p.parF(Kd,"Kd","demo param 2",10.0,0.0,100.0,0.1);    
      //maxSpeed = p.parF(maxSpeed,"maxSpeed","inches/sec ",6.0,0.0,24.0,1.0);
     
   
      
    p.endList(); // endList MUST be called after all parF and parI items 
  
  }
