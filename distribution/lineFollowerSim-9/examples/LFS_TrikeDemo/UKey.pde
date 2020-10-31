/* UKey -  User Key Decode 
   
   If you find yourself wanting to add a command key, this is the place to do it.
   
   All key codes shifted to upper-case before being passed to userKeypress method. 
   
   These keys are unavailable, used by LFS:
   
   EFCGHMSPR 0123456789 +- <>,.    Alpha-numeric keys
   ACLSDI                          These control keys
   
   
   As a double check, try your proposed key out before adding code.
   You should see  "Key not decoded by LFS or userKeypress.."  message in console.
     
   User help can be defined by adding a text file "userhelp.txt" to sketch 
   data subfolder. This help appears as second page of H)elp (second press of H) 
   
*/

// The following strings can be populated with user command descriptions that will appear
// In the bottom two lines of LFS Command Summary Window.
// userKeyCommands2, if defined will replace last line of command summary which is currently
// "* If markers defined, G)o or R)un start at last clicked marker."

String userKeyCommands1 = "";  // e.g  "Ctrl-F)risky Mode   Z)ero"  
String userKeyCommands2 = "";  // suggest generally leave this string empty. 

 
 // Will Custom Key Decode, called from LFS_Key tab keyPressed method 
 // with comment out of normal UP,DOWN,LEFT,RIGHT behavior 
                                 
 void decodeKeysTrike  (char k, int code)    // wjk 6-14-20
 {
   
 }
 
                                

void userKeypress(char key)   // called with uppercase shifted letter, symbol or ctrl-key not decoded by LFS
{
  // control characters are decoded by subtracting 64 from alpha constant e.g.
  // 'A'-64 is Ctrl-A = ASCII decimal value 1  
   
  switch (key)
  {
    // few samples here 
    
    case 'Z'     :   println ("keypress Z decoded by userKeypress");
                     break;
               
    case 'X'-64  :   println ("keypress Ctrl-X decoded by userKeypress");
                     break;
    
 
    default : if (key>'A') 
       println (String.format("Key not decoded by LFS or userKeypress '%c' ASCII value %d ",key,(int) key));
       else 
       println (String.format("Key not decoded by LFS or userKeypress  Ctrl-%c  ASCII value %d ",key+64, (int) key ));
       break; 
            
  } // end case  
}  // end userKeypress 



boolean  userArrowKeyDecode(int keyCode)  // this method called when arrow key is about to be handled 
{
  // user behavior could be coded here
  
    
  //if (k ==  'S' )   trike.wheelVelocity = 0; //!!! need stop 
  
  RobotState cs = currentRobotState;
  // modify current state  
  
  println ("userArrowKeyDecode ",keyCode);
  
  switch (keyCode) {
  case UP  :  cs.wheelVelocity += 0.30; break;   
  case DOWN:  cs.wheelVelocity -= 0.30; break;
  case LEFT:  cs.steerAngleR += 0.05;  break;
  case RIGHT: cs.steerAngleR -= 0.05; break; 
  
  } // end case 
  
  if (cs.steerAngleR > 1.0 ) cs.steerAngleR = 1.0;    // steer wheel aft so + steer --> LEFT turn 
  if (cs.steerAngleR < -1.0 ) cs.steerAngleR = -1.0;  // think of wheel as rudder  wjk 6-21-20
     
     
  trikeDriveUpdate ();  //  allow for manual drive 
     
  
  
  
  return true;   // return true, if default key decode is NOT to be used. (See keypressed() method in LFS_Key tab)
                 // return false, if default key decode is to be used.
              
}  
 
