 /* Line Following Simulator User Application - Processing Environment
   (Main file (notebook tab) of multi-file project)

   LFS_XXX  Main Tab   new (lib 1.5)
   
   The main tab now contains basic skeleton of sketch.
   It contains core functions setup() and draw() with calls to methods that are 
   effectively the body of setup and draw. It is easy to right click on them below and be taken 
   to their declarations via (Jump to declaration)
   
   This tab shows what libraries are imported and also gives easy access to basic settings relating to
   screen resolution.
   
   A big goal here is that updates to the library or application code should only affect
   LFS_tabs other than this one.
   
   That is, with a new library release and download the .pde files should be able to be copied
   over the files in your sketch if your release is (lib 1.4.3) or later.
   
   LFS_G
   LFS_Key
   LFS_M
   LFS_Panel
   LFS_Par
   LFS_RS
      
  
   The Processing sound library is required for this program   
   
   To install the sound library:
   On the Processing command menu bar click Sketch > Import Library... > Add Library ... 
   The Contribution Manager Window will appear.
   Click on the Filter Box and enter the word "sound"  
   Then click on item  Sound | Provides a simple way to work with audio.
   Then click Install at bottom right of window. 
   After the library installs completes, close the Contribution Manager window and
   run your sketch.
   
*/

import lineFollowerSim.*;   // LFS Simulator API, renders views, calculates robot location, generates sensor data and more.
import processing.sound.*;  // Sound library. See above for installation instructions.

  
boolean  fullScreenDisplay  = false;    // full screen (designed for 1920x1080 display only) (lib 1.4.2)
                                        // sketch has a few tweaks to display correctly on 1920x1080 (HD) display
                                        // when this setting is true

void settings()  // processing calls this one time at start of program
{                // allows selection of different sizes, not allowed in setup. 

  if (fullScreenDisplay) fullScreen(P3D);     
  else size (1800,900,P3D);                  // window width,height in pixels
}
   
void setup()  {
frameRate(120);          // request high frame rate, e.g. 1000 max,  to run simulator as fast as possible.
                         // frame rate (frames per second - fps) reported top right of display.
                         // A frame rate of 60 would closely match the simulator default time step, but 
                         // there is no need to restrict the simulator speed. The stopwatch will count the 
                         // same amount of time regardless of how fast the simulator executes.
                         // (lib 1.6) is game changer including timeWarp, allowing multiple simulation steps
                         // between each screen update. For example a time warp of 100 might speed up simulation 
                         // by factor of as much as 100. If insufficient CPU power, frame rate will fall, but still
                         // net time steps/sec will be greatly increased
                         
                         
  setupLFS();            // LFS related setup, see LFS_M tab
} 

void draw() { lfsDraw(); } // called by Processing at frame display rate (as fast as possible with frameRate(1000)
                           // See LFS_M tab
