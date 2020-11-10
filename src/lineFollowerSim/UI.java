package lineFollowerSim;


import processing.core.*;
import processing.data.*;
import java.lang.reflect.*;   // Reflection allows the ability to obtain Class member names and to modify them by name..  
import java.util.ArrayList;
import java.io.File;

/*
Create simple GUI

Ron Grant  2019
Last update Sept 10 2020
Sept 10,2020   added showHoverMessage and moved message to screen lower-right




*/

/**
* simple GUI (documentation not complete) 
* <p> 
*
* Push Buttons
* <p>
* Check Box    click on button to toggle check box 
* <p> 
* Radio Button -- hack for now  for page select buttons, may not be supported
* <p>
* Value Button    integer value , min,max range
* <p>
* Text Box        edit string
*
*
*
* 
* 
* 
* @author Ron Grant
*
*/

public class UI implements PConstants 
{


int buttonEnabledTextColor; 
int buttonKeyCodeTextColor;   // # character color override  e.g.  #Help  activated with H, highlight  
int buttonDisabledTextColor;
int buttonBGColor;
int buttonHoverColor;
int buttonClickedColor;
int buttonAsLabelTextColor;
int buttonOutsideFrameColor;
int buttonAsTextEditColor;	
	
	
int borgX;              // button origin 
int borgY;
int borgYMax;           // guideline for max button Y

int currentCol;         // current col used when dropping controls in from Robot

public int newButtonGroup = 0;   // as buttons are defined, they are included in currentGroup 
public int groupMask = 0x1FF;    // current button pages displayed (all default)

// removed page select code, now using groups
//int newButtonPage = 0;  // page used for new buttons set by page(page)
//public int BUTTON_PAGES = 4;
//public UIButton[] pageSelectButton;   // allows modification of button frameOutline used to show active page 

public UIButton valueEditorButton = null;

                     // button parameters - set in uiSetup() 
int bx;
int by;              // current button Y postion (auto inremented as buttons are created 
int bw;              // width of button cell 
int bh;              // height of button cell

int rowH;            // row height
int colW;

float deltaCol;      // auto increment values in row,col scale 
float deltaRow;

int veX;             // variable editor origin, height, width
int veY;
int veH;  
int veW;   

int   veOriginalValue;           // variable editor - remember value in case cancel on edit
float veOriginalValueF;

boolean active;
boolean mouseHasLeftClicked;    // register fact that mouse has clicked, the "consumer" of this click
int mouseClickX;                // sets mouseHasClicked to false;
int mouseClickY;

boolean leftJust;               // when true, modify buttons,labels to be left justified 
                                
int hintMsgX;
int hintMsgY;              // hint message location, non zero active 

int hoverMsgX;             // show button command string when hovering over button
int hoverMsgY;

boolean hintEnable = true; 

boolean showHoverMessage = false;  // show button command string when hovering over button, useful 
                                   // for determining what command is decoded in UICmd tab
PApplet p; // parent 

/**
 * List of all defined buttons, automatically added as they are created using UI methods
 */
public ArrayList <UIButton> buttons;       // = new ArrayList <UIButton>();

Object newButtonLinkObject = null;  // when not null, button is linked to parameter class instance 
// where cmd field is variable name e.g. "cameraName"
// this allows button/control to modify variable directly upon edit... 

/**
 * UI - UserInterface Class
 * 
 * Supports definition of controls (buttons,check boxes,text boxes, integer and float value controls..
 * <p> 
 * Allows user to write response code, for simplicity, called as a chain of if() statements. 
 * This documentation is far from complete. At preset see user code in LFS Application , LFS_G tab.
 * 
 * @param parent Reference to parent applet (processing applet)
 */
public UI (PApplet parent)  // constructor 
{
  p = parent;
  active = true;
  mouseHasLeftClicked =false;
  hintMsgX = 0;
  hintMsgY = 0;
  hoverMsgX = 0;
  hoverMsgY = 0;
  
  
  buttonEnabledTextColor = p.color (20,20,120); 
  buttonKeyCodeTextColor = p.color  (0,0,50);   // # character color override  e.g.  #Help  activated with H, highlight  
  buttonDisabledTextColor = p.color (90,90,180);
  buttonBGColor = p.color(100,100,200);
  buttonHoverColor = p.color (140,140,220);
  buttonClickedColor = p.color (255,255,255);
  buttonAsLabelTextColor = p.color (120);
  buttonOutsideFrameColor = p.color (140,140,240);
  buttonAsTextEditColor = p.color (140,140,160);	
 
 // pageSelectButton = new UIButton[BUTTON_PAGES+1];    // reference to buttons defined as page selectors  
  
  
  buttons = new ArrayList <UIButton>();
  
  
  setColWidth(180);
  setButtonWidth (160);      
  setButtonYMax  (500); // max Y 
  setRowHeight(50);   
  setButtonOrigin(0,0);
  setDeltaColRow(0.0f,1.0f);  // default move down the page  
  
  
  
}


/**
 * Define visible button groups as multi digit decimal number which is encoded into a mask
 * used to determine button visibility based on their group definition 0..9.
 * For example 123 indicates button groups 1,2 and 3 will be visible.
 *  
 * @param groups multi digit number comprising all visible button groups.
 */
public void setVisibleGroups(int groups)
{
  groupMask = 0;	        // reset groupMask 
  while (groups != 0)
  {
	int lsd = groups % 10;     // least significant digit of b 
	groupMask |= 1<<lsd;       // set bit position in group mask, e.g. 3  or in   000001000
	groups /= 10;              // decimal shift to right one digit 
  }
  
  // when buttons are iterated for display
  //   if button's mask & groupMask is zero button is not displayed 
  
}

/**
 * Set location on screen where hint text (if defined) will appear on screen.
 * @param x horizontal offset from left side of screen
 * @param y vertical offset from top of screen
 */
public void setHintLocation(int x, int y)
{
 hintMsgX = x;
 hintMsgY = y;
}

public void hintEnable (boolean e) { hintEnable = e; }

/**
 * Location for Value Editor used when value button clicked on
 * @param x horizontal offset from left side of screen
 * @param y vertical offset from top of screen
 * @param w value editor panel width in pixels
 * @param h value editor panel height in pixels 
 */
public void setValEditRect (int x, int y, int w, int h) { veX = x; veY=y; veW=w; veH=h; }  // value editor pop up 
/**New control positioning: 
 * Location x,y of button array gotoCol(1) location.
 * @param x  horizontal offset from left side of screen
 * @param y  vertical offset from top of screen
 */
public void setButtonOrigin(int x, int y) {borgX = x;  borgY = y; }
/**New control positioning: 
 * Max Y of buttons being auto positioned, where column is incremented and row count reset 
 * @param ymax
 */
public void setButtonYMax  (int ymax)     {borgYMax = ymax; }
/**New control positioning: 
 * Defines the height of button bounding rectangle
 * @param h height in pixels
 */
public void setButtonHeight(int h) { bh=h;     }
/**New control sizing:
 * Defines the row total size, this should be greater than button height
 * @param h height in pixels
 */
public void setRowHeight(int h)    { rowH = h; }
/**
 * Set button x,y loction. This overrides auto positioning
 * @param x Offset from left side of screen
 * @param y Offset from top of screen
 */
public void setButtonPos   (int x, int y) { bx = x; by=y; }
/**
 * New control positioning: Set button bounding rectangle width in pixels
 * @param w  width in pixels
 */
public void setButtonWidth (int w)        { bw = w; }
/**
 * New control sizing: Sets column width for calculation of next column spacing, this value should be greater than 
 * button width
 * @param w button width in pixels
 */
public void setColWidth    (int w)        { colW = w; }
/**
 * New control positioning: Set col,row increment applied as controls are created, e.g. (0,1) move down the page  
 * @param dc  delta column value typically 0 or 1, but can be adjusted, e.g. 1.1 for more space.. 
 * @param dr  delta row value typically 0 or 1, but can be adjusted, e.g. 1.1 to increase spacing.
 */
public void setDeltaColRow(float dc, float dr) { deltaCol = dc; deltaRow = dr; }  
  
/**
 * Button/Label Text for subsequent controls will be left justified
 */
public void setLeftJustify()   { leftJust = true;  }
/**
 * Button/Label Text for subsequent controls will be center justtified
 */
public void setCenterJustify() { leftJust = false; }

/**
 *  Buttons that follow use parameter class field names and link to variables.
 *  * More Needs to be written here. 
 * @param linkObject
 */
public void setVarLinkObject(Object linkObject) { newButtonLinkObject=linkObject; } 

  
/**
 * New control positioning: Move to new column for for subsequent control placement, row set to 0
 * @param n column number 1,2,3... 
 */
public void gotoCol(int n)  // go to top of column n - for button / label placement 
{
  currentCol = n;
  bx = borgX + colW*(n-1);  // nth col   
  by = borgY; 
}

/**
 * New control positioning: Auto advance to next position, skip a button location using current delta set with setDeltaColRow
 */
public void nextPos() // auto advance to next position using current setDeltaColRow(dc,dr) values 
{
   bx += (int) (deltaCol*colW);
   by += (int) (deltaRow*rowH);
}
/**
 * New control positioning: Advance to next position manually specified here delta row, deta col distance.
 * @param dc Change in column position.
 * @param dr Change in row position.
 */
public void moveColRow (float dc, float dr)
{
   bx += (int) (dc*colW);
   by += (int) (dr*rowH); 
}

/**
 * New control positioning: goto to given row using multiple of row height
 * @param d
 */
public void gotoRow(float d)
{
  by = borgY + (int) (rowH*d);  
}

/**
 * Half row or column spacing depending on delta col, delta row setting
 */
public void gap() 
{
  float saveDC = deltaCol;
  float saveDR = deltaRow;
  
  deltaCol /= 2.0;
  deltaRow /= 2.0;
    
  nextPos();
  
  deltaCol = saveDC;
  deltaRow = saveDR;
  
}

/**
 * Define button, with unique command, and hint string.
 * @param s Button label
 * @param cmd Button resulting command string (when clicked)
 * @param hint Button Hint string 
 * @return optional reference to button assigned to UIButton variable
 */
public UIButton btn (String s, String cmd, String hint)  // button with hint
{
  UIButton b = new UIButton (p,this,bx,by,bw,bh,s,cmd);  // parent Applet, this UI instance, 
  b.group = newButtonGroup; 
  b.hint = hint;
  
  if (leftJust) b.leftJustify = true;
  
  nextPos();  // auto advance 
  return b;
}

public UIButton btn (String s, String cmd)   // button without hint
{ return btn (s,cmd,"");  }               
/**
 * Define button where label = command result
 * @param s Label and also command string 
 * @return optional reference to button assigned to UIButton variable
 */
public UIButton btnc (String s) // button definition where button label and command are same and no hint 
{ return btn (s,s,""); }

/**
 * Define button where label = command, also include hint 
 * @param s label of button and command returned when button clicked
 * @param hint Hint string than can be displayed when button is hovered over with mouse 
 * @return optional reference to button assigned to UIButton variable
 */
public UIButton btnc (String s, String hint)
{ return btn (s,s,hint); }



public UIButton textBox(String idText, String textField, int width, String hint)    // new button type for editing text  
{
  UIButton b = btn (idText,idText);
  b.textStr = textField;
  b.setWidth(width);
  b.isLabel = false;
  b.isTextBox = true; 
  b.hint = hint;
  return b;
}


public UIButton textBoxc(String idText,int width)    // new button type for editing text  
{
  return textBox(idText,"",width,"");
}


public UIButton textBoxc(String idText,int width, String hint)    // new button type for editing text  
{
  return textBox(idText,"",width,hint);
}


public UIButton checkBox (String idText, String cmd, boolean isChecked,String hint)
{
  UIButton b = btn (idText,cmd);
  b.isLabel   = false;
  b.isCheckBox = true;
  b.checked = isChecked;
  b.hint = hint;
  return b;
}


public UIButton checkBox  (String idText, String cmd)        { return checkBox(idText,cmd,false,""); }

/**
 * Define Checkbox where label = command string when clicked.
 * @param idText label string
 * @param isChecked boolean initial value 
 * @return optional reference to checkbox assigned to UIButton variable
 */
public UIButton checkBoxc (String idText, boolean isChecked) { return checkBox(idText,idText,isChecked,"");}

/**
 * Define Checkbox where label = command string when clicked, includes hint string.
 * @param idText label string
 * @param isChecked boolean initial value
 * @param hint Hint string that can be displayed when button is hovered over with mouse 
 * @return optional reference to checkbox assigned to UIButton variable
 */
public UIButton checkBoxc (String idText, boolean isChecked, String hint) { return checkBox(idText,idText,isChecked,hint);}
public UIButton checkBoxc (String idText)                    { return checkBox(idText,idText,false,""); } 



public UIButton val (String s, String cmd, int value, int vmin, int vmax)
{
  UIButton b = new UIButton (p,this,bx,by,bw,bh,s,cmd,value,vmin,vmax); // button variant with value, range min to max
                                                                 // label shows vname=value

  nextPos();  // auto advance 
  b.group = newButtonGroup;
 
 return b;  // return reference to button 
  
}

public UIButton valc (String s,int vmin, int vmax)   // value button with label=cmd  no value - suitable for VarLinked object
{
  return  val (s,s,0,vmin,vmax); 
}

public UIButton val (String s, String cmd, int vmin, int vmax)   // value button with label=cmd  no value - suitable for VarLinked object
{
  return  val (s,cmd,0,vmin,vmax); 
}


// floating point range value button defs 

public UIButton fval (String s, String cmd, float value, float vmin, float vmax)
{
  UIButton b = new UIButton (p,this,bx,by,bw,bh,s,cmd,value,vmin,vmax); // button variant with value, range min to max
                                                                 // label shows vname=value

  nextPos();  // auto advance 
  b.group = newButtonGroup;
 
 
 return b;  // return reference to button 
  
}

public UIButton fvalc (String s,int vmin, int vmax)   // value button with label=cmd  no value - suitable for VarLinked object
{
  return  fval (s,s,0,vmin,vmax); 
}


public UIButton fval (String s, String cmd,float vmin, float vmax)   // value button with label=cmd  no value - suitable for VarLinked object
{
  return  fval (s,cmd,0.0f,vmin,vmax); 
}




/**
 * create new label using button class, but is not clickable and does not have a bounding rectangle.
 * @param s Label string
 * @return optional reference to checkbox assigned to UIButton variable
 */
public UIButton label(String s) {
  UIButton b = btn(s,"");
  if (leftJust) b.leftJustify = true;
  return b;
  
}  // create new label "button" not really button -- but uses button class 


/*
  public void pageSelectBtn (int pageNum, String caption)   // defines button in column # pos 1 above column top (header location)
  {
   // gotoCol(pageNum);
   // gotoRow(-1);
    String cmd = "GoPage"+Integer.toString(pageNum);
    PApplet.println (String.format("Defined Page Select Button %d  cmd %s ",pageNum,cmd));
    pageSelectButton[pageNum] = btn(caption,cmd);       // define page select button and place reference  in pageSelectButton table
     
  }
*/  


/**
 * Define button group number 1..9 for subsequent control definitions.
 * Buttons can then be selectively displayed using  setVisibleGroups method.
 * @param groupNum number 1..9
 */
public void group(int groupNum)  { newButtonGroup = groupNum; }

void setGroup(int n) {
	if ((n>9) || (n<0)) PApplet.println("Error: setgroup must be 0..9");
	else newButtonGroup = n;
}


/**
 * Not supported 
 * @param f File 
 */
public void saveFileSelected(File f)
{
  if (f==null) return;
  
  PApplet.println ("Selected ",f.getAbsolutePath());
  PApplet.println ("Code for SAVE needed here ");     // !!! 
    
}


/**
 * Used with value buttons - not documented for this application
 * @param b Button to edit
 */

public void valueEditorBegin(UIButton b)
{
  valueEditorButton = b;
  if (b.isValueButton) veOriginalValue =  b.getIntValue();     // linked or normal internal value
  if (b.isFloatButton) veOriginalValueF = b.getFloatValue();
}

boolean valueEditMouseDown = false;  // state variable prevents OK/CANCEL while dragging bar graph

public void valueEditorUpdate()  // called from update() after user has clicked on a value  value button
{
  int barY = 100;
  
  p.pushMatrix();
  p.pushStyle();
  
  UIButton b = valueEditorButton;  // shorthand ref
  p.rectMode (CORNER);
  p.stroke (200);
  p.fill (50);
  
 
  p.translate (veX,veY);
  
  p.rect (0,0,veW,veH);
  
  p.textAlign(CENTER);
  int x = veW/2;
  p.textSize (18);
  p.fill (200);
  if (b.isValueButton) p.text (String.format("%s=%d",b.label,b.getIntValue()),x,20);
  if (b.isFloatButton) p.text (String.format("%s=%4.2f",b.label,b.getFloatValue()),x,20);
   
  p.text (b.description,x,40);
  
  p.fill (50);
  p.rect (20,barY,veW-40,20);
  
  int cancelColor = p.color (140);
  int okColor     = p.color (140);
  
    
  if ((p.mousePressed) && (p.mouseX>=veX) && (p.mouseX<=veX+veW) && (p.mouseY >=veY+barY) && (p.mouseY <= veY+barY+20))
  {
     if (b.isValueButton)
     {
       int oldValue = b.getIntValue(); 
       int newVal = b.vmin + (p.mouseX-veX)*(b.vmax-b.vmin+1)/veW;
       b.setIntValue(newVal); 
       if (oldValue!=newVal)
       {
        // local commands affected by change in value -- maybe better way to handle this 
        // maybe in its own method 
       }
     }
     
     if (b.isFloatButton)
     {
       float oldValue = b.getFloatValue(); 
       float newVal = b.fmin + (p.mouseX-veX)*(b.fmax-b.fmin+1)/veW;
       b.setFloatValue(newVal); 
       if (oldValue!=newVal)
       {
        // local commands affected by change in value -- maybe better way to handle this 
        // maybe in its own method 
       }   
       
       
     }
       
       
       
       
    valueEditMouseDown = true;
  }
  
  if (!p.mousePressed) valueEditMouseDown = false;
  
   
  if ((p.mouseY > veY+veH-20) && (p.mouseY < veY+veH))
  {
    if (p.mouseX > veX+veW/2) // right half, cancel side of box
    {
      if (!valueEditMouseDown) cancelColor = p.color(240);
      if (p.mousePressed && !valueEditMouseDown)
      {
        PApplet.println ("cancel variable edit");
        if (b.isValueButton) b.setIntValue  (veOriginalValue);       // revert to original value
        if (b.isFloatButton) b.setFloatValue(veOriginalValue);
        
        if ((b.robotCmdOrVar) && (b.isValueButton)) // !!! not support isFloatButton
        {
          String s = String.format (">%s=%d\r\n",b.cmd,b.getIntValue());
          PApplet.println ("send to robot (orignal value) : ",s);
         // tCom.write(s);
        }  
        else
        {
      
           PApplet.println ("cancel other edit");
            
          
        }  
              
              
              
        valueEditorButton = null;      // done editing
      }  
    }
    else
    {   if (!valueEditMouseDown) okColor = p.color (240);
       if (p.mousePressed && !valueEditMouseDown) valueEditorButton = null;  // signal box close
    }
  
  
  }
  
  p.fill (okColor);
  p.text ("OK",20,veH-2);
  p.fill (cancelColor);
  p.text ("CANCEL",veW-100,veH-2);
 
  p.fill (150);
  int xp = 0;
  
  if (b.isValueButton)
    xp =  (veW-40)*(b.getIntValue()-b.vmin)/(b.vmax-b.vmin);
  if (b.isFloatButton)
    xp = (int) ( (veW-40)*(b.getFloatValue()-b.fmin)/(b.fmax-b.fmin));
  
  
  p.rect (20,barY,xp,20); 
  
  
  p.fill (200);
  
  if (b.isValueButton)
  {
    p.text (String.format ("%d",b.vmin),50,barY-10);
    p.text (String.format ("%d",b.vmax),veW-50,barY-10);
  }
  
  if (b.isFloatButton)
  {
    p.text (String.format ("%3.2f",b.fmin),50,barY-10);
    p.text (String.format ("%2.2f",b.fmax),veW-50,barY-10); 
    
  }
  
 
  
  p.popStyle();
  p.popMatrix();
 
}





UIButton updateButtons()
{
   
   // add outside frame to current page button 
  // for (int i=1; i<pageSelectButton.length; i++)
    // pageSelectButton[i].outsideFrame = (currentPage ==i ); 
 
   UIButton buttonClicked = null;
	
   if (valueEditorButton != null) valueEditorUpdate();   // value editor is running if current value button is assigned
  
   boolean clickedOnAButton = false;  // register if any button has been clicked on in button list
   boolean clickCheck = mouseHasLeftClicked; 
  
   for (UIButton b : buttons)
   { 
     // b.draw(); -- draw handled elsewhere
   
     if (b.clicked())
     {
       clickedOnAButton = true;
       
       if (teButton != null) textEditorProcessClick(b);  // if text editor active & different button terminate text edit
                                                         // current button update cursor location
     
       if ((b.isValueButton) || (b.isFloatButton))
       {
         if (valueEditorButton != null)
         { // already editing varaiable 
            
            if (b.isValueButton) valueEditorButton.setIntValue(veOriginalValue);
            if (b.isFloatButton) valueEditorButton.setFloatValue(veOriginalValueF);
           
           PApplet.println ("canceled edit on current button");
         }  
         valueEditorBegin(b);
    
       }
       else
       if (b.isTextBox)
       {
         if (b != teButton) textEditorBegin(b);  // if not already editing, start up editor 
       }
       else if (b.isCheckBox)
       { b.checkedToggle();
         buttonClicked = b;
         //uiCmd(b);               // generate "command" to allow reaction to change in box state 
       }
       else buttonClicked = b; // uiCmd(b);            // must be standard button ,decode command buttons
      
     }  
   } 
   
   if (clickCheck && !clickedOnAButton) 
   {
     // println ("mouse has been clicked, but not on any button - cancel text edit if active ");
     textEditorEnd();
     mouseHasLeftClicked = false; // OK here?
   }

   return buttonClicked; 
  
}

boolean uiWaitMouseUp = false;  // prevent mouse clicks on file dialog from getting to buttons.. 


public void drawButtons(int mask)
{  for (UIButton b : buttons) b.draw(mask); }


/**
 * Called by application program, to draw currently visible buttons and to return a reference to 
 * clicked button, if none clicked returns null.
 * @return Clicked button reference, or null if no button clicked.
 */
public UIButton update()  // Process Commands 
{  
      
   UIButton clickedButton = null;
   
   //if (!fileDialog.active) 
   { //if (!uiWaitMouseUp)
     {drawButtons(groupMask);         // Draw UI Buttons 
      UIButton b = updateButtons();
      if (b != null) clickedButton = b;
     }
     if (!p.mousePressed) uiWaitMouseUp = false;
   }
   /*
   else 
   {
    // fileDialog.update();        // draws dialog if active
     loadSaveParamFileCheck();   // checks to see if Load/Save Params requested 
                                 // and performs action if file dialog finished 
    
     if (!fileDialog.active) uiWaitMouseUp = true;                                 
                                 
   }
   */
   
   return clickedButton; // if button clicked in draw buttons loop, return it for cmd decode
   
}


UIButton curCmdButton;
boolean cmdDecoded;


public boolean cmd (String keyStr) // helper for uiUpdate, makes for terse  if (cmd("XYZ")) doSomeCommand 
{ 
  boolean eq = curCmdButton.cmd.equals(keyStr);
  if (eq) cmdDecoded = true;
  //if (eq) PApplet.println (String.format ("cmd match %s ",keyStr));   // diagnostic print
  return eq;
}

/**
 * This method should be called with reference to clicked button provided by update() method
 * before chain of if(ui.cmd("label")) do action statements. 
 * @param b Current button that has been clicked. 
 */
public void beginDecode(UIButton b)
{ curCmdButton = b; 
  cmdDecoded = false;
}

/**
 * Call this method after all  if(ui.cmd("ButtonCmd") do action have been executed ,where it informs program
 * if a command has been decoded by one of the if statements.
 * @return true if the button was decoded, if not and error message is warranted.
 * 
 */
public boolean endCmdDecode() { return cmdDecoded; }





 public boolean handleMouseClick(int x, int y)
 {
    if (!active) return false;
    if (p.mouseButton == LEFT)
      mouseHasLeftClicked = true;   // register fact that mouse has clicked, the "consumer" of this click
    mouseClickX = x;                // sets mouseHasClicked to false;
    mouseClickY = y;
    return true; 
  }
  
  public boolean handleKeyPress(char key)
  {
    if (!active) return false;
    if (teButton != null) textEditKey(key);   // UIBText handle keypresses (editing text field )
    
    //if (textEditActive) textEditKey(char(key));
    return true;
   
  }
  
  // -------------------------------- TEXT BOX SUPPORT ----------------------------------------------------------------
  
//UIButton - text box (editable string)
//variable prefix te - text editor


String teOriginalTextStr;      // text edit - remember value on click
UIButton teButton;
int teCursor;
String editStr;

public void textButtonDraw (UIButton b, int fontH, int x, int y)
{
  p.textAlign(LEFT);
  
  if (teButton==b)
  {
   p.text (editStr,x,y);             // edit in progress, using editStr  
   textEditDrawCursor(fontH,x,y);  // draw cursor
  }
  else
  {
    p.text (b.getText(),x,y);   // normal text - not editing this text box button
    
  }  
 
}


public void textEditorBegin(UIButton b)
{
 teButton =  b;
 String s = b.textStr;
 Object p = b.linkObject;
 
 if (p != null)
 {
    Field f = getField(p.getClass(),b.cmd);   // cmd=name of field within given class 
    s = getStringField(f,p);                  // get value of field in particular instance of class
  
    PApplet.println ("Text Editor Begin using param instance :",s); 
 } 
 else  PApplet.println ("Text Editor Begin :",s); 
 
 editStr = s;                // for now operating on editStr (copy of textStr)
 teOriginalTextStr = s; 
 teCursor = editStr.length()-1;

}

public void textEditorEnd()
{
  if (teButton == null) return;
  
  teButton.textStr = editStr;       // copy editStr to button's textStr 
  
  Object p = teButton.linkObject; 
  if (p != null)
  {
    Field f = getField(p.getClass(),teButton.cmd);   // cmd=name of field within given class 
    setStringField(f,p,editStr);                     // get value of field in particular instance of class
  } 
  
  teButton = null;                  // done editing 
}


public void textEditorProcessClick(UIButton b)
{
  if (b==teButton)
  {
    PApplet.println ("Clicked on already selected textBox ");
    
  }
  else 
  {
    PApplet.println ("Clicked on different button than current text edit - update & terminate text edit");
    textEditorEnd();
  }
 
}

 
public void textEditKey(char key)
 {
   int n = editStr.length(); 
   
    if (key==CODED)
    {
      if (p.keyCode == LEFT)
      { if (teCursor>-1) teCursor--; }
      
      if (p.keyCode == RIGHT)
      {if (teCursor<editStr.length()-1) teCursor++;} 
      
     
      return;
    }
    
    
   // if (key==BACKSPACE)
   if (key==DELETE)
   {
     if (teCursor>-1)
     {
       if (teCursor <n-1) editStr = editStr.substring(0,teCursor+1) + editStr.substring(teCursor+2,editStr.length());
       else  editStr = editStr.substring(0,teCursor--);  // note also adjust teCursor as string deleted from end
     }
   }
   else if (key==BACKSPACE)
   {
     if ((teCursor>-1) && (teCursor <n-1)) teCursor--;
     else if (teCursor == -1) editStr = "";
     else  editStr = editStr.substring(0,teCursor--);
   }
   else if ((key>=32) && (key<128))  // normal key 
   {
     if ((teCursor>-1) && (teCursor <n-1)) editStr = editStr.substring(0,teCursor+1) + key + editStr.substring(teCursor+1,editStr.length()); 
     else editStr += key;
     teCursor++; }
  
 }
 

 public void textEditDrawCursor(int fontH, int x, int y)
 {
   
   // int textH = textHSize;
    
   int minDx = 9999;
   int minDxi = 0;
     
  
   for(int i=0; i<editStr.length(); i++)
   {
     char c = editStr.charAt(i);
     p.text (c,x,y);
     x+= p.textWidth(c);  // x after char 
     
     int dx = PApplet.abs(p.mouseX-x);
     if (dx<minDx) {minDx = dx; minDxi = i; }
      
     // show char sep line - normally invisible 
     
     p.stroke (0,50,0); 
     //line (x,y,x,y-fontH);     // enable this line to show all string break positions   
     
     if ((teCursor == i) && (p.frameCount/30 %2 == 0))  // display blinking cursor 
     { p.stroke (255);
       p.line (x,y,x,y-fontH);         
     }
    
   }
   
   if (editStr.length() == 0) // empty string 
   {
     p.stroke (255);               // just cursor 
     p.line (x,y,x,y-fontH);  
   }
   if (mouseHasLeftClicked)
   { if ((mouseClickY>y-fontH) && (mouseClickY<y))
     {
       teCursor = minDxi;
       mouseHasLeftClicked = false;  // consume the click
     }  
   }
 }
 
 
 // ------------------- UI Par RW -----------------------------------------------------------------------------------
 
 /*  Read/Write variables defined in a class to/from json file using java reflection which has ability 
 to access string names of variables (methods and classes too) using what I would call the compile time symbol
 table.
 
 Ron Grant
 May 10,2020
 
Reference Processing Forum  GotoLoop  May 2014 Post
 
 
Included data types boolean,char,double,float,int,long,String
 

paramWrite(parFilename,par);
paramRead(parFilename,par);
paramShow(par);

used by WebCamControl and WebCamServer apps (Params Tab)

one problem is order of class fields is not guaranteed, could consult source file... to obtain line numbers then sort ...


would be nice to associate var with control

    MyTextBoxLabel [Rons Office Cam]

                        textBox1.text is  cp.camName
                        

 could we make all vars  arrays or class refs?    to allow call by reference 




*/


//That is, at runtime we can get string names of fields, methods or class names
//In this example we list members of TestClass and modify one

/*
idea is create say a "parameter" class 
then in automated fashion save to JSON

then reload later 

in case of webcam, both camera and control have a copy of the class code.
The camera loads parameters at program start and can send to controller which modifies and can send back.

*/



//get and set methods for each data type 
//Boolean Char Double Float Int Long String 



Field getField(final Class c, final String fieldName)
{
try {
 return c.getDeclaredField(fieldName);   // get field declared in current class matching fieldName 
}

catch (final NoSuchFieldException e) {
 PApplet.println("Error ",e);
 return null;
}   
}  

static final void setBooleanField(final Field f, final Object instance, final boolean b) {
try { f.setBoolean(instance, b); }
catch (final IllegalAccessException e) {
 PApplet.println("Error ",e);
}
}

static final void setCharField(final Field f, final Object instance, final char c) {
try {f.setChar(instance, c);}
catch (final IllegalAccessException e) {
 PApplet.println("Error ",e);
}
}

static final void setDoubleField(final Field f, final Object instance, final double d) {
try {f.setDouble(instance,d);}
catch (final IllegalAccessException e) {
 PApplet.println("Error ",e);
}
}

static final void setFloatField(final Field f, final Object instance, final float num) {
try {f.setFloat(instance,num);}
catch (final IllegalAccessException e) {
 PApplet.println("Error ", e);
}
}

static final void setIntField(final Field f, final Object instance, final int num) {
try {f.setInt(instance, num); }
catch (final IllegalAccessException e) {
 PApplet.println("Error ",e);
}
}

static final void setLongField(final Field f, final Object instance, final long num) {
try {f.setLong(instance, num);}
catch (final IllegalAccessException e) {
 PApplet.println("Error ",e);
}
}

static final void setStringField(final Field f, final Object instance, String val) {
try { f.set (instance,val); }
catch (final IllegalAccessException e) {
 PApplet.println("Error ", e);
}
}



//get field values based on data type 

static final boolean getBooleanField(final Field f, final Object instance) {
try { return f.getBoolean(instance); }
catch (final IllegalAccessException e) {
 PApplet.println("Error ",e);
 return false;
}
}

static final char getCharField(final Field f, final Object instance) {
try { return f.getChar(instance); }
catch (final IllegalAccessException e) {
 PApplet.println("Error ",e);
 return '?';
}
}


static final double getDoubleField(final Field f, final Object instance) {
try { return f.getDouble(instance); }
catch (final IllegalAccessException e) {
 PApplet.println("Error ",e);
 return 0.0;
}
}

static final float getFloatField(final Field f, final Object instance) {
try { return f.getFloat(instance); }
catch (final IllegalAccessException e) {
 PApplet.println("Error ",e);
 return 0.0f;
}
}

static final int getIntField(final Field f, final Object instance) {
try { return f.getInt(instance); }
catch (final IllegalAccessException e) {
 PApplet.println("Error ",e);
 return 0;
}
}

static final long getLongField(final Field f, final Object instance) {
try { return f.getLong(instance); }
catch (final IllegalAccessException e) {
 PApplet.println("Error ",e);
 return 0;
}
}

static final String getStringField(final Field f, final Object instance) {
try { return (String) (f.get(instance)); }
catch (final IllegalAccessException e) {
 PApplet.println("Error ",e);
 return "";
}
}


void paramShow (Object p)
{ _paramReadWriteShow("",p,'S'); }

void paramWrite (String filename, Object p)
{ _paramReadWriteShow(filename,p,'W'); }

void paramRead (String filename, Object p)
{ if (!_paramReadWriteShow(filename,p,'R'))
{
  PApplet.println (String.format("Parameter file, %s, not found , performing paramWrite()",filename));
  paramWrite(filename,p);
}
}


boolean _paramReadWriteShow(String filename, Object par, char mode)  // called by paramShow parmRead paramWrite 
{

JSONObject j;

if (!filename.contains("\\")) filename = p.sketchPath(filename);

if (mode=='W') j = new JSONObject();
else
if (mode=='R') 
{
 File file=new File(filename);
 if (!file.exists()) return false;
 

 PApplet.println ("Read param file ",filename);
 
 j = p.loadJSONObject(filename);
}  
else if (mode=='S') 
{ PApplet.println ("Parameter Show");
 j = null;
}
else
{
 PApplet.println ("Error _paramReadWrite expected mode R,W or S ");    
 return false;
}



Class pClass = par.getClass();  // get the class of the "parameter" object
 
Field[] fs = pClass.getDeclaredFields();  // get the declared variable list 

for (Field f:fs)  // for each variable 
{
  String s = f.toString();       // field as string e.g   "float FieldReflectionDemo$ParamClass.age"
  
  // now parse data type (dtype) and variable name (everything after "." in second token 
  
 String[] tok = s.split(" ");   // e.g.  [float]  [FieldReflectionDemo$ParamClass.age]
 if (tok.length>1)
  if (tok[1].contains("."))
  {
    String t=tok[1];
    String[] t2 = t.split("\\.");  // split on "."  noting that split uses regular expression format 
    String dtype = tok[0];         // and dot means any char, backslash required for literal "."
    String id = t2[1];             
 
    //println (String.format("type [%16s]  Identifier [%s] ",type,id));
   
    if (mode=='W')
    {
      // write to json based on datatype 
      // getting values from class variables 
      if (dtype.contains("boolean")) j.setBoolean(id,getBooleanField(f,p));
      if (dtype.contains("char"))    j.setString(id,new String(new char[1]).replace('\0',getCharField(f,p)) );
      if (dtype.contains("double"))  j.setDouble(id,getDoubleField(f,p));       
      if (dtype.contains("float"))   j.setFloat(id,getFloatField(f,p));                                
      if (dtype.contains("int"))     j.setInt(id,getIntField(f,p));
      if (dtype.contains("long"))    j.setLong(id,getLongField(f,p));  
      if (dtype.contains("String"))  j.setString(id,getStringField(f,p)); 
    } 
  
    if (mode=='S') // show -- show each variable in class and value 
    {
      // write show based on datatype 
    
      if (dtype.contains("boolean")) PApplet.println (id," ",getBooleanField(f,p)?"true":"false"); 
      if (dtype.contains("char"))    PApplet.println (id,"  ",getCharField(f,p) );
      if (dtype.contains("double"))  PApplet.println (id," ",getDoubleField(f,p)); 
      if (dtype.contains("float"))   PApplet.println (id," ",getFloatField(f,p));
      if (dtype.contains("int"))     PApplet.println (id," ",getIntField(f,p));
      if (dtype.contains("long"))    PApplet.println (id," ",getLongField(f,p));
      if (dtype.contains("String"))  PApplet.println (id," ",getStringField(f,p)); 
                          
    } 
  
    if (mode=='R')
    { 
      // read data from json to class instance fields given the name of the field (id) 
      // and its type (dtype).
      // Hence requesting value from json file using j.get<type>(identifier name)
      // then performing set<type>Field with the values
      
      if (dtype.contains("boolean")) setBooleanField(f,p,j.getBoolean(id));  
      if (dtype.contains("char"))    setCharField(f,p,j.getString(id).charAt(0));
      if (dtype.contains("double"))  setDoubleField(f,p,j.getDouble(id));
      if (dtype.contains("float"))   setFloatField(f,p,j.getFloat(id));
      if (dtype.contains("int"))     setIntField(f,p, j.getInt(id));
      if (dtype.contains("long"))    setLongField(f,p, j.getLong(id)); 
      if (dtype.contains("String"))  setStringField(f,p,j.getString(id)); 
    }
    
     
  }
}

if (mode=='W') 
{  p.saveJSONObject(j,filename);  
   PApplet.println ("parameter write complete ",filename);
}

if (mode =='R') PApplet.println ("parameter read complete ",filename);
return true;

}
 
 

/* void uiCmd (UIButton b) //!!!   changed uo
{
  PApplet.println ("command decoder need to implement this method externally ");
  
	 
}
 
*/ 
 
 
 
 
 


}

