// Class to create buttons. 
class twoStateButton {
  //A button that has two possible states(0 and 1), with different colors and texts
  float xA; //Position of the button. x-axis
  float yA; //Position of the button. y-axis. top-left(xA,yA)
  float xB;
  float yB; //Position of the butto. Bottom-right(xB,yB)
  float w; //width of the button
  float h; //height of the button
  String txtS0; //Text of the button when it is in state 0
  String txtS1; //Text of the button when it is in state 1
  color ColorS0; //Color of the button when it is in state 0
  color ColorS1; //Color of the button whe it is in state 1
  boolean ButtonState; //false:state 0 ; true:state 1
  
  // Constructor
  twoStateButton(float tempx, float tempy, float tempw, float temph, String temptxtS0, String temptxtS1, color tempColorS0, color tempColorS1) {
    xA=tempx;
    yA=tempy;
    xB=xA+tempw;
    yB=yA+temph;
    w=tempw;
    h=temph;
    txtS0=temptxtS0;
    txtS1=temptxtS1;
    ColorS0= tempColorS0;
    ColorS1=tempColorS1;
    ButtonState=false; //state 0
  }

  //We display the button with the corresponding text and color depending on the state
  void display() {
    textAlign(CENTER, CENTER);

    if (ButtonState) { //state 1
      fill(ColorS1);
      stroke(ColorS1);
      rect(xA, yA, w, h);
      fill(0); //font color 
      text(txtS1, xA+w/2, yA+h/2);
    } else { //state 0
      fill(ColorS0);
      stroke(ColorS0);
      rect(xA, yA, w, h);
      fill(0); //font color 
      text(txtS0, xA+w/2, yA+h/2);
    }
  }//end display()

  //We get in if the mouse is over the button
  boolean isMouseOver() {
    //Chek if the coordinates of the mouse are over the area of the button
    if (mouseX>=xA && mouseX<=xB &&
      mouseY>=yA && mouseY<=yB) {
      return true;
    } else {
      return false;
    }
  }
  
  //It toggles the state of the button
  void toggle(){
    ButtonState=!ButtonState;
  }

  //We can set the state of the button
  void setState(boolean tmpState) {
    ButtonState=tmpState;
  }
  
  //We get the state of the button
  boolean getState() {
    return ButtonState;
  }
}// end of Class twoStateButton
