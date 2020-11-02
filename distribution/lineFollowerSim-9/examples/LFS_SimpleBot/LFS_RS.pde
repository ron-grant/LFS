/* LFS_RS  Robot State Control   -- new experimental feature (lib 1.5)

   Ron Grant
   Oct 27, 2020
   
   RobotState class, defined in UserReset tab, provides a facility to capture robot state information while
   a non-contest run is in progress via M marker command (the robot step rate can be throttled with 1..9 keys OR
   frozen with SPACE when the marker records state. This saved state marker  appears as a marker circle
   with and added internal rotating square.
   
   The idea is to allow state capture some amount of time into a course run, as the robot approaches
   a feature that it is failing on, then return to that location and robot state instantly after making 
   changes to the controller code.
   
   If your robot carries little state information, this facility may not be of much use. Placing a robot 
   on the course some distance in advance of a feature and dropping a marker might be good enough.
   
   Without any user code, the facility saves current speed and rate of turn, but internal robot state
   information would need to be provided. Due note the data type restrictions for variables that can be 
   saved or reloaded.
   
   
     1.  Your userControllerUpdate must insure all state variables are copied from controlller to 
         currentRobotState (aliased as cs. in example code) then back to currentRobotState at exit
         of the method. (This is done in TrikeDemo at present).
         
     2. The safer way, keep all robot state variables in currentRobotState with none of them declared outside
        the RobotState class.
        
   Note that LFS, includes some variables in RobotState that help it perform basic state recovery operations,
   including current speed and rate of turn.
  
   One thing to do is try out the facility as-is.
   Depending on your robot controller, it might perform well with no additions to code.
   
   After creating one or more markers with saved state. Click on the marker and the robot will move
   to the marker, but be frozen, press SPACE to unfreeze.
   
   
   If your controller is very state critical, you may have problems. As of (lib 1.5),
   I am aware LFS state is not fully captured, e.g. missing target speed, target turn rate.. 
             
   Important: If you add or remove state variables you might have to erase old save state information to eliminate
   program crash. The state data is saved as a file with same name as course image, but with a ".srs"
   (saved robot state) file extension.
   
   This is a human readable ASCII file in JSON format. Key,value data does not appear in any defined order. 
   
   This first rendition of RobotState is not perfect, but... ideally, a robot controller should be robust
   enough to handle differences in location and not expect perfection in placement in subsequent re-runs
   of a contest course.
   
   You can always try a few iterations of saving a state in different , then testing if your robot will start and 
   repeat desired failure behavior some time later. When that is established verify the same behavior is obtained 
   after closing and restarting the sketch. At that point, go to work on your controller.
   
   Again, if you add new state variables you might need to erase .srs file. 
   In the future, LFS may better recognize changes, and prompt for erasure of old incompatible saved state markers.
     
 */
  
boolean verboseStateRW = false;  // used to see on console, what fields are being read/written
      
ArrayList  <RobotState> robotStateList = new ArrayList <RobotState> ();  // current list of saved robot states
                                                                         // written to data folder robotState.json when
                                                                         // changes made, read from .json when marker clicked
                                                                         // to insure up-to-date. and to avoid need for initial
                                                                         // read.
 
void rsprintln(String s) { if (verboseStateRW) println (s); }            // controlled println


void informMarkersAboutSavedRobotState() // System method used to notify marker system about markers with state information
{
  lfs.markerSavedStateColorScaleSpeed (100,50,255,0.71,90.0/(frameRate+1));  
  
  for (RobotState s : robotStateList)
    lfs.markerNotifySavedState(s.markerX,s.markerY);  // give locations of saved state present 
  
}

String getSavedRobotStateFilename () {  // .srs file in data folder nammed with course name 
  String s = lfs.getCourseFilename();
  while (s.charAt(s.length()-1) != '.') s = s.substring(0,s.length()-1); 
  return dataPath(s+"srs");  // saved robot state  
}

void loadRobotStates()  
{
   // Note currentRobotState is passed as an example class instance to objectListLoad
   // this is probably a hack -- method needs to know what class is used when creating 
   // new robotStateList items. At present, I am still hard coding the creation of new RobotState
   // in this method. Goal is to make the method totally "generic"
   // I am missing something .. knowledge of generics or reflection...  RG Oct 28,2020
  
   String srsFilename = getSavedRobotStateFilename();  // filename and path 
  
   objectListLoad(currentRobotState, robotStateList,srsFilename,verboseStateRW);
   
   rsprintln (String.format("Loaded RobotStates,  Total of %d",robotStateList.size()));
   
   rsprintln ("Loaded List ");
   if (verboseStateRW) objectListPrint(robotStateList);
   rsprintln ("");
   
}


void saveRobotStates()
{
  objectListSave(robotStateList,getSavedRobotStateFilename());
  rsprintln (String.format("Saved RobotStates,  Total of %d",robotStateList.size()));
}

                
void lfsNewMarkerPlaced(boolean placed)  //called when a new marker placed or removed , allowing oppurtunity to save state info
{                                        //because not allowed during contest run, we can save location data to identify 
                                         //location 

  float curX = lfs.getRobotX();
  float curY = lfs.getRobotY();

  RobotState rs = currentRobotState;        // shorthand alias (reference to currentRobotState)
  
  if (placed && lfs.controllerIsEnabled()) 
  {
    rsprintln ("controller running and marker placed, create snapshot of currentRobotState");  // verbose what is going on
        
    RobotState ss = new RobotState();  // ss =  to be saved state 
    
    objectSave(rs,"temp$.srs");  // copy currentState into new ss state via write/read to file 
    objectLoad(ss,"temp$.srs");  // future might implement class copy, not hard to do... 
    
    ss.markerX =  curX;
    ss.markerY =  curY;
        
    ss.robotHeading = lfs.getHeading();
    ss.robotSpeed = lfs.getSpeed();                     // instantaneous speed and turn rate           
    ss.robotSidewaysSpeed = lfs.getSidewaysSpeed();     // these are always available from simulator.
    ss.robotTurnRate = lfs.getTurnRate();
    ss.timerTick = lfs.lapTimer.getTick();              // save current stop watch time 
    
 
    objectSave(ss,"tempMod$.srs");  // save new modified snapshot  
 
    robotStateList.add(ss);
    saveRobotStates(); 
  }
  else if (!placed)
  {
   for (RobotState s : robotStateList)
   {
     if (dist(curX,curY,s.markerX,s.markerY) < 1.0)
       rsprintln ("Need code to remove item from list !!! ");      
   }
    
  }
}
   

                                      
void lfsMarkerClicked()                     //  called when robot jumps to old marker, allowing oppurtunity to 
{                                           //  restore robot state information  (lib 1.4.3)

   float curX = lfs.getRobotX();
   float curY = lfs.getRobotY();

  // determine if this marker has stored state information
  
  loadRobotStates();  // for now load just before looking at list 
                      // otherwise would need to add load when course loaded
  
  for (RobotState rs : robotStateList)
  if (dist(curX,curY,rs.markerX,rs.markerY) < 1.0)
  {
   println ("Saved RobotState found, updating current state. ");  // This always printed on console.
   
   
   rsprintln ("currentRobotState");
   if (verboseStateRW) objectPrint(currentRobotState);
      
   objectSave(rs,"tempClick$.srs");                 // save new modified snapshot
   objectLoad(currentRobotState,"tempClick$.srs");  // load into current state instance of RobotState
  
   rsprintln ("updated currentRobotState");
   if (verboseStateRW) objectPrint(rs);
     
   // restore system state information not found exclusively in RobotState
  
   RobotState cs = currentRobotState;         // short hand access to current state 
   lfs.setInstantTurnRate(cs.robotTurnRate);
   lfs.setInstantSpeed(cs.robotSpeed);
   lfs.setInstantSidewaysSpeed(cs.robotSidewaysSpeed);
   lfs.lapTimer.setTick(cs.timerTick);       // restore stop watch at time of state save  
       
   println ("Executing Resume robot drive - FREEZE - Press SPACE to run");
   
   lfs.setEnableController(true);
   lfs.crumbsEraseAll();
   lfs.clearDistanceTraveled();    // could recover 
   simFreeze = true;  // if not frozen problems with controller on while mouse button pressed 
                      // would need to hold until mouse button released, or execute this method call after mouse button
                      // released AND not allow mouse to drag robot.. 
   
   
   return;
  }
  else 
  { println ("no state info for this marker");
    lfs.setEnableController(false);                     // G)o or R)un to start 
    lfs.clearDistanceTraveled();    // could recover
    lfs.crumbsEraseAll();
    lfs.lapTimer.lapTimerAndCountReset();
    simFreeze = false; 
    lfs.stop();
    userStop();
  }
  
  
  
  
  
 
}    
  
  /*
   Low-Level code for LFS_RS save/restore robot state 
  
   Using Java Reflection save/load class instance or list of instances 
   to from JSON file 
      
   variables of type int,float,boolean,String,int[],float[] are supported
   others ignored 
     
   Ron Grant
   Oct 27, 2020
   
   Lacks exception messages.. 
   
   
   When using objectListSave
   
   Output  json file will contain a single item which is a JSON array that has within it 
       key value pairs items
       
       For example a list with 3 items of a class with 2 fields (x,y) would appear like following 
    
       { "LFS_SimpleBot$RobotState" : [ 
          {"x":value1,"y":value2},
          {"x":value1,"y":value2},
          {"x":value1,"y":value2} 
          ]
       }
  
  
*/  
 
//import java.lang.reflect.*;  // java reflection used to lookup/set class fields  
     
void objectListSave(ArrayList alist, String filename)
{ 
     if (alist.size()==0)
     { println ("Note:  objectListSave empty list ");
       return;
     }
     
  
     // create JSON container 
     JSONObject j = new JSONObject();
     
     // create an array of class instances within JSON image 
     JSONArray ja = new JSONArray();
   
     // store class name for list item as key for JSON Array
   
     j.setJSONArray(alist.get(0).getClass().getName(),ja);   // key String, value JSON Array  (the array)
     // j.setJSONArray("$instances",ja);
   
    
     int i = 0;                    // JSON array index (0..N-1)
     for (Object obj : alist) 
     {
       JSONObject jo = new JSONObject();  
       _loadSavePrintObject('S',obj,jo,null);
        ja.setJSONObject(i++,jo);                // Add the object (all class instance key value pairs) 
     }                                           // to the JSONArray "container"
    
     saveJSONObject(j,filename);    // save mode, finally write the JSON file   
}
  
 
// this method is almost "perfect", but having, for now
// to directly code  RobotState obj = new RobotState(), to create new list item.
// looking for way to do this using reflection.  The class name is available 
// "LFS_SimpleBot$RobotState", but just not there on how to do this... 
// I would like this method to be usable other places with no fussing about.
// I think that is the idea behind generics.    RG Oct 28,2020
  
// exampleListItem argument is a experimental hack.. this will probably go away, may not be using..
// was not needed earlier.. leaving for now
  
void objectListLoad (Object exampleListItem,ArrayList alist, String filename,boolean verbose)
{ 
   JSONObject j;
   
   alist.clear();  // clear list of class instances 
   
   try {
     j = loadJSONObject(filename);
   } catch (Exception e ) {
     println ("no json file ",filename);  
     return; 
   }
   
   // creating an array of class instances within JSON image 
   
   
   String lsc = exampleListItem.getClass().toString();
   String lscNoClass = lsc.replace ("class ","");
   if (verbose) println ("lsc ",lsc);
     
   JSONArray ja = j.getJSONArray(lscNoClass);
 
   if (ja==null) { 
      println (String.format("failed to getJSONArray in objectLoadList  key [%s]",lsc));
      return;
   }
   
  // j.setJSONArray(alist.get(0).getClass().getName(),ja);   // key String, value JSON Array  (the array)
  
   j.setJSONArray(exampleListItem.getClass().getName(),ja); 
   
    
   for (int i=0; i<ja.size(); i++)
   {
      if (verbose) println ("load   reading item ",i," of ",ja.size());
      
                                                                                                             
       // Object obj = new Object (); // is this OK? -- no need Class  
      
      //println ("objectListLoad alist.get(i).getClass().toString() ",alist.get(i).getClass().toString());
      //
      
      /*
      Object obj = null;
      
      try {
       obj = exampleListItem.getClass().newInstance();
      } catch (InstantiationException ie ) {
        println ("cannot instantiante obj in objectListLoad");
      }
      catch (IllegalAccessException ia ) {   }
      */
      
      RobotState obj = new RobotState();    // don't know how to do this generically OR using reflection
                                            // ???
       
       
      
      JSONObject jo = (JSONObject) ja.get(i);
            
      _loadSavePrintObject('L',obj,jo,null);
      
      alist.add(obj);
    }
     
} 
   
    
void objectListPrint(ArrayList alist)
{
  for (Object obj : alist) 
  { objectPrint(obj);
    println ("----------------------------");
  }
}

// Load/Save/Print for single class instance from/to file OR print 
  
void objectLoad(Object ob, String filename) 
{ 
    JSONObject j = loadJSONObject(filename); 
    _loadSavePrintObject('L',ob,j,null);
  
}

void objectSave(Object ob, String filename)
{ 
    JSONObject j = new JSONObject();  
    _loadSavePrintObject('S',ob,j,null);
    saveJSONObject(j,filename);          // save mode, finally write the JSON file   
  
}
  
void objectPrint(Object ob)
{ 
  _loadSavePrintObject('P',ob,null,null);
}

void objectAppendToStringList (Object ob, StringList sL)  // append items to string list 
{
  _loadSavePrintObject('A',ob,null,sL);  // 'A' Append Command, object, no JSON, StringList
}

                                                             
void _loadSavePrintObject( char cmd, Object ob, JSONObject j, StringList sL) // scan a class instance for int,float,boolean,String,int[],float[]
{                                                                            // types and load/save to JSON or print  cmd = {'L','S','P'}
    boolean load =  (cmd == 'L');
    boolean save =  (cmd == 'S');
    boolean print = (cmd == 'P');
    boolean add =   (cmd == 'A');  // add (append) to string list 
       
    if (!load && !save && !print && !add) { 
      println ("ERROR  loadSavePrintObject method  expects cmd = L S P or A cmd not recognized ",cmd); 
      return;
    } 
     
    boolean showAllFields = false; // diagnostic 
          
    if (showAllFields)
    {
      println ("All Class Fields regardless of type ");
      
      // This code serves as an example of using reflection to iterate through fields defined in a class. 
      // For load and save, access to get or put fields is combined with put to / get from access of JSON object
      
      for(Field f : ob.getClass().getDeclaredFields())    // using java reflection iterate over fields in class 
      {
        String name = f.getName(); 
        println (name,"  type:  ", f.getType());
      }
      println ("----------------");
    }  
    
    
    for(Field f : ob.getClass().getDeclaredFields())    // using java reflection iterate over fields in class 
    {
      String name = f.getName();          // field name   e.g. "count" for declaration int count; 
      String t = f.getType().toString();  // field type   e.g. "int"  
      
      // For each recognized type save to JSON, load from JSON or just print field value 
      // The pattern is the same for primitive types
      // A little more complex for arrays.
          
      if(t.equals("float"))
      {
        try {
           
        if (save) {  
          float vf = (float) f.get(ob);   // get the field
          j.setFloat(name,vf);            // save the field to JSON
        }
        if (load) {
          float vf = j.getFloat(name);    // read the field from JSON
          f.setFloat(ob,vf);              // store in class instance 
        }  
        if (print) println (name," = ",(float) f.get(ob));
        if (add) sL.append(String.format ("%s = %1.4f",name,(float) f.get(ob))); 
        
        } catch (IllegalAccessException ia) {}
      }
      if(t.equals("int"))
      {
        try {
          
          if (save) {  
            int vi = (int) f.get(ob);
            j.setInt(name,vi);
          }
          if (load) {
            int vi = j.getInt(name);
            f.setInt(ob,vi);
          }  
          if (print) println (name," = ",(int) f.get(ob));
          if (add) sL.append(String.format ("%s = %d",name,(int) f.get(ob))); 
        
        } catch (IllegalAccessException ia) {}
      } 
      if(t.equals("boolean"))
      {
        try {
          if (save) {  
            boolean vb = (boolean) f.get(ob);
            j.setBoolean(name,vb);
          }
          if (load) {
            boolean vb = j.getBoolean(name);
            f.setBoolean(ob,vb);
          }  
          if (print) println (name," = ",(boolean) f.get(ob));
          String tf = "false";
          if ((boolean) f.get(ob)) tf = "true";
          if (add) sL.append(String.format ("%s = %s",name,tf)); 
        
        } catch (IllegalAccessException ia) {}
      }  
      if(t.equals("class java.lang.String"))
      {
        try {
     
         if (save) {  
            String vs = (String) f.get(ob);
            j.setString(name,vs);
          }
          if (load) {
            String vs = j.getString(name);
            f.set(ob,vs);
          }  
          if (print) println (name," = ",(String) f.get(ob));
          if (add)  sL.append(String.format ("%s = %s",name,(String) f.get(ob))); 
                 
       } catch (IllegalAccessException ia) {}
      }
      if(t.equals("class [I"))  // array of integers 
      {
        try {
          
        if (save)
        {
          // slightly more tricky, get integer aray
          // Create and populate new JSON array object, then finally feed this to the json object j
          // that will be written to a file 
          
          int[] iArray = (int[]) (f.get(ob));
          JSONArray ja = new JSONArray();
          for (int i = 0; i<iArray.length; i++) ja.setInt(i,iArray[i]);   // did not see way to do this without loop?
          j.setJSONArray(name,ja);
        }
        if (load)
        {
          JSONArray ja = j.getJSONArray(name);
          int[] iArray = ja.getIntArray();
          f.set(ob,iArray);   
        }
        if (print) 
        {
            println ("IA",name);
            printArray ((int[]) f.get(ob));
        }
        
        if (add)
        {
          int[] ti = (int[]) f.get(ob);
          for (int i=0; i<ti.length;i++) sL.append(String.format ("%s[%d] = %d",name,i,ti[i])); 
        }
       
        } catch (IllegalAccessException ia) {} 
      }
      if(t.equals("class [F"))  // array of integers 
      {
        try {
          if (save) { 
            float[] fArray = (float[]) (f.get(ob));
            JSONArray ja = new JSONArray();
            for (int i = 0; i<fArray.length; i++) ja.setFloat(i,fArray[i]);
            j.setJSONArray(name,ja);
          } 
          if (load) {
            JSONArray ja = j.getJSONArray(name);
            float[] fa = ja.getFloatArray();
            f.set(ob,fa);    
          }  
                    
          if (print)  {
            println ("FA",name);
            printArray ((float[]) f.get(ob));
          } 
          
          if (add)
          {
           float[] rt = (float[]) f.get(ob);
           for (int i=0; i<rt.length;i++) sL.append(String.format ("%s[%d] = %1.4f",name,i,rt[i])); 
          }
          
          
        } catch (IllegalAccessException ia) {} 
      }
    } // end for Field f in declared fields 
    
    // if (save) caller takes care of saveJSONObject call   
      
} // end loadSavePrint
  
