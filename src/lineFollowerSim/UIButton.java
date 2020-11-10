package lineFollowerSim;

import processing.core.*;
import java.lang.reflect.*;

/**
 * Button Class, instance of which includes all possible buttons -- not using descendant classes here. 
 * @author Ron Grant
 *
 */
public class UIButton implements PConstants {
    // new UIButton (this,40,height-40,bWidth+150,30,"Append Messages to Display File");

 PApplet p;          // ref to parent Processing applet 	
 UI ui;              // ref to UI class instance (singleton)

 int group;          // group membership 0..9 (replaces page) where group defines a bit position 
                     // allowing groups to be selectively displayed 
                     // UI method setVisibleGroups(groups) is used to create groupMask
                     // default 0 is special case, always displayed 
 int x,y,w,h;
 int fontH;
 public String label;      
 public String cmd;         // short e.g. 2 char string that holds command to be decoded or variable name to be sent 
                            // to robot e.g.  [Kp=5] button would send KP=value to robot
 public String hint;        // hover over hint 

 // char bType = 'X';   // using isXXX below for button type ID - for now  
 
 public boolean isValueButton;      // button holds variable and range of values
 public boolean isFloatButton;      // button holds floating point var and range
 public boolean isTextBox;          // text in frame - editable -- new May 2020 
 public boolean isCheckBox;
 public boolean isLabel;
 
 public boolean leftJustify;        // left justify text - default is center 
 
 public boolean boldMode;
 public boolean visible; 
 public boolean enabled;
 
 boolean hasBeenClicked;
 boolean waitForRelease;

 boolean outsideFrame;

 // button type dependent values 
 
 public int value; 
 public int vmin;             
 public int vmax;
 
 public float fvalue;  // isFloatValueButton
 public float fmin;
 public float fmax; 
 
 public boolean checked;

 public String  textStr;            // text box string (for now label == "", but might consider label [textStr]

 // special additions for robot variables 
 
 public boolean robotCmdOrVar;     // button holds variable OR value range for robot
                                   // e.g. change will be sent to robot  as cmd=value when value changed in value editor
                                   // which is invoked when clicking on a value button 
 public String  description;
 public boolean isFloatValue;      
 public int     floatScale;        // e.g. typical 1000  indicating values will be scaled by 0.001 in robot
                                   // but are handled as integers within this program e.g 1 to 1000 would map to 0.001 to 1.000 in 
                                   // robot - value adjustment might show the "real value" in () for example 
 public Object  linkObject;
 
 
 UIButton (PApplet parent,UI ui, int xpos, int ypos, int w, int h, String label, String cmd)
 {
  	
   p = parent;   // do need ref to applet - library code
   this.ui = ui;
		   
   group = 0;                          // default always visible, UI groups buttons into pages
   x = xpos;
   y = ypos;
   this.w = w;
   this.h = h;
   this.label = label;
   outsideFrame = false;
   this.cmd = cmd;
   isLabel = cmd.length()==0;
   boldMode = false;
   visible = true;
   enabled = true;
   fontH = 18;
   hasBeenClicked = false;
   waitForRelease = false;
   isValueButton = false;
   isFloatButton = false;
   robotCmdOrVar = false;
   isTextBox = false;
   description = "";       // added, optionally  after button created - robot supplies descriptions for all buttons..  
   
   leftJustify = false;
   linkObject  = null;     //   ui.newButtonLinkObject;  
                           //  seeUISetup  e.g.   ui.setVarLinkObject(cp);  !!! set null for now !!!     
   
   ui.buttons.add(this);
   
 }

 

 
 
 UIButton (PApplet parent, UI ui, int xpos, int ypos, int w, int h, String label, String cmd, int value, int vmin, int vmax)
 {
    this(parent,ui,xpos,ypos,w,h,label,cmd);
    
    setAsValueButton (value,vmin,vmax);   // turn into value button 
  
 }  
  
  
 UIButton (PApplet parent,UI ui,int xpos, int ypos, int w, int h, String label, String cmd, float value, float vmin, float vmax)   // floating point value button constructor
 {
    this(parent,ui,xpos,ypos,w,h,label,cmd);
    
    setAsFloatButton (value,vmin,vmax);   // turn into float value button 
  
 }  
   
  
  
  
 void setAsValueButton (int value, int vmin, int vmax) 
 {
    isValueButton = true;
    this.value = value;
    this.vmin = vmin;
    this.vmax = vmax;
 }
   
 void setAsFloatButton (float fvalue, float fmin, float fmax) 
 {
    isFloatButton = true;
    this.fvalue = fvalue;
    this.fmin = fmin;
    this.fmax = fmax;
 }    
 
 boolean clicked()
 {
   boolean t = hasBeenClicked && !waitForRelease;
   if (t)
   {
     hasBeenClicked = false;
     waitForRelease = false;
   }
   return t;
 }
 
 
 void setWidth(int width) { w = width; }
 
 
 void draw(int mask)
 {
   if (!visible) return; // if button individually hidden - don't display
   
   // selective display button groups controlled by 
   // UI.setVisibleGroups() defines groupMask
   // e.g. (51) would display groups 0 5 and 1
   // default group is 0, and is always displayed 
   
   if ((group != 0) && ((1<<group) & mask) ==0) return;  
   
   
   p.pushStyle();
  
   boolean mouseHover = false;
  
   if (enabled && (p.mouseX>x) && (p.mouseX<x+w) && (p.mouseY>y) && (p.mouseY<y+h))
   {
     // control enabled and mouse in rect region of control
     mouseHover = true;
     
     if (ui.hintEnable)
     {
       p.pushStyle ();
       p.fill (200);
       p.stroke(240);
       p.textSize(20);
       p.text (hint,ui.hintMsgX,ui.hintMsgY);  // hint message 
       p.popStyle();  
       
     }
   
     if (ui.showHoverMessage)
     {
       p.pushStyle ();
       p.fill (200);
       p.stroke(240);
       p.textSize(16);
       String hm = String.format ("%s (%s) [%s]",label,description,cmd);
       p.text (hm,p.width-p.textWidth(hm),p.height-4);    // hover message 
       p.popStyle();
     }  
        
     p.fill (ui.buttonHoverColor);
     
     if (p.mousePressed == true)
     {
       hasBeenClicked = true;
       waitForRelease = true;
       p.fill (ui.buttonClickedColor);  
              
     }
     else waitForRelease = false;
     
   
   }
   else
   {
    
     p.fill (ui.buttonBGColor);
   }  
   
   
   p.rectMode (CORNER);
   if (!isLabel)
   {
     p.stroke (40,40,100);
     
     if (isTextBox)
     {  p.noFill();
        if (mouseHover) p.stroke (ui.buttonHoverColor); // buttonBGColor);
        else p.stroke (ui.buttonBGColor);
     }
     p.rect (x,y,w,h,6);
     
     if (outsideFrame) { // draw frame beyond extents of button -- used for radio button effect of page buttons..
       p.pushStyle();
       p.stroke (ui.buttonOutsideFrameColor);
       p.noFill();
       p.strokeWeight (2.0f);
       p.rect (x-3,y-3,w+6,h+6,8);
       p.popStyle();
     }
     
   }  
   
   p.textSize(fontH);
   p.textAlign(CENTER);
   if (leftJustify) p.textAlign(LEFT);
   
  //  if (boldMode) textMode(BOLD_MODE) else textMode(NORMAL);  // not supported
   
   if (isTextBox)
   { p.fill (ui.buttonAsTextEditColor);
   }
   else
   if (isLabel)
   {
     p.fill( ui.buttonAsLabelTextColor);
   } else
   {
   if (enabled) p.fill(ui.buttonEnabledTextColor);
   else p.fill (ui.buttonDisabledTextColor);
   }
  
   if (isTextBox) ui.textButtonDraw(this,fontH,x+10,y+h/2+fontH/2);
   else
   if (isValueButton)  p.text (String.format ("%s=%d",label,getIntValue()),x+w/2,y+h/2+fontH/2);   // value mode  e.g.  [radius=4]
   else
   if (isFloatButton)  p.text (String.format ("%s=%3.2f",label,getFloatValue()),x+w/2,y+h/2+fontH/2);   // value mode  e.g.  [radius=4]
   else 
   if (isCheckBox)
   {
     int xi = x+4;
     int yi = y+fontH/3;
     p.rect(xi,yi,fontH,fontH);
     p.textAlign(LEFT);
     String s = label.replaceAll("#","");     // strip off # if present
     p.text (s,x+2*fontH,y+h/2+fontH/2);
     
     if (label.contains("#"))   // overdraw # char
     {
       // over draw #highlighted first char  
       if (enabled)
       { p.fill(ui.buttonKeyCodeTextColor);
         if (!leftJustify)
         {
            p.text (label.substring(1,2),x+2*fontH,y+h/2+fontH/2);
            p.text (label.substring(1,2),x+2*fontH,y+h/2+fontH/2);
         }   
       }
     }
     
     
     if (getChecked()) {
       p.stroke (240);
       p.line (xi+2,yi+2,xi+fontH-2,yi+fontH-2);
       p.line (xi+fontH-2,yi+2,xi+2,yi+fontH-2);
    }
     
   }
   else 
   { // regular text
     
     // interpreting "#Loop " as "Loop" with bright L might be tricky
     // maybe restrict to first character simpler
     
     String s = label.replaceAll("#","");
             
     if (leftJustify) p.text (s,x,y+h/2+fontH/2);
     else  p.text (s,x+w/2,y+h/2+fontH/2);
     
     if (label.contains("#"))
     {
       float tw2 = p.textWidth(s)/2;
       
       // over draw #highlighted first char  
       if (enabled)
       { p.fill(ui.buttonKeyCodeTextColor);
         if (!leftJustify)
         {
            p.textAlign(LEFT);
            p.text (label.substring(1,2),x+w/2-tw2,y+h/2+fontH/2);
            p.text (label.substring(1,2),x+w/2-tw2-1,y+h/2+fontH/2);
         }   
       }
     }
     
     
   }
   
   
   p.popStyle();
 }
 
  
 void setTextBold()  { boldMode = true; }
 void setVisible(boolean v) { visible = v; }
 
 void setTextPlain() { boldMode = false; } 
 void setTextItalic() {  } // do nothing 
 void setEnabled (boolean e) { enabled = e; } 
 
 int getX() { return x; }
 int getY() { return y; }
 int getWidth() { return w; }
 int getHeight(){ return h; }
 
 
 
 // set and gets dependent on linked control or not.
 // Long and Double not supported as of May 14 2020
 
 String getText()  // return text value based on using linkedObject or not
 {
   Object p = linkObject;
   if (p == null) return textStr;
   else
   {
    Field f = ui.getField(p.getClass(),cmd);   // cmd=name of field within given class 
    return UI.getStringField(f,p);             // get value of field in particular instance of class
   }
 }
 
 
 
 boolean getChecked()  // return checked value based on using linkedObject or not
 {
   Object p = linkObject;
   if (p == null) return checked;
   else
   {
    Field f = ui.getField(p.getClass(),cmd);   // cmd=name of field within given class 
    return UI.getBooleanField(f,p);   // get value of field in particular instance of class
   }
 }
 
 
 void checkedToggle()
 {
   
   Object p = linkObject;
   if (p == null) checked = !checked;
   else
   {
    Field f = ui.getField(p.getClass(),cmd);   // cmd=name of field within given class 
    boolean  old = UI.getBooleanField(f,p);   // get value of field in particular instance of class
    UI.setBooleanField(f,p,!old);        // set value of field in particular instance of class with !value   
  }
  
 }  
 
 int getIntValue()  // get value from value control 
 {
   Object p = linkObject;
   if (p == null)  return value;   // value stored in control 
   else
   {
      Field f = ui.getField(p.getClass(),cmd);   // value linked to parameter object where cmd=name of variable in string form 
      return UI.getIntField(f,p);                // get value of field in particular instance of class
    }
 }
 
   
 void setIntValue(int newVal)  // get value from value control 
 {
   Object p = linkObject;
   if (p == null)  value = newVal;   // value stored in control 
   else
   {
      Field f = ui.getField(p.getClass(),cmd);   // value linked to parameter object where cmd=name of variable in string form 
      UI.setIntField(f,p,newVal);                // get value of field in particular instance of class
    }
 }
 
 float getFloatValue()  // get value from value control 
 {
   Object p = linkObject;
   if (p == null)  return fvalue;   // value stored in control 
   else
   {
      Field f = ui.getField(p.getClass(),cmd);   // value linked to parameter object where cmd=name of variable in string form 
      return UI.getFloatField(f,p);                // get value of field in particular instance of class
    }
 }
 
   
 void setFloatValue(float newVal)  // get value from value control 
 {
   Object p = linkObject;
   if (p == null)  fvalue = newVal;   // value stored in control 
   else
   {
      Field f = ui.getField(p.getClass(),cmd);   // value linked to parameter object where cmd=name of variable in string form 
      UI.setFloatField(f,p,newVal);                // get value of field in particular instance of class
    }
 }
 
 
 
}  // end class
 