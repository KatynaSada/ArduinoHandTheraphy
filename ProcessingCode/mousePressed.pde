// The function is called when the mouse is pressed.
// It has different functions depending on the button chosen, it changes the value of the variable "option". 
void mousePressed() {
  String option="0"; // Intialize variable. 

    if(button2G.isMouseOver()){// Verify if mouse is over button2G
      button2G.toggle();
      if(button2G.getState()==true){ // Get the state of the button. 
        option = "1"; 
        // Change state of all other buttons. 
        button4G.ButtonState = false;
        button8G.ButtonState = false;
        button16G.ButtonState = false;
      }  
    }else if(button4G.isMouseOver()){ // Verify if mouse is over button4G
      button4G.toggle();
      if(button4G.getState()==true){ // Get the state of the button. 
        option = "2"; 
        button2G.ButtonState = false;
        button8G.ButtonState = false;
        button16G.ButtonState = false;
      }  
    }else if(button8G.isMouseOver()){ // Verify if mouse is over button8G
      button8G.toggle();
      if(button8G.getState()==true){ // Get the state of the button. 
        option = "3"; 
        button2G.ButtonState = false;
        button4G.ButtonState = false;
        button16G.ButtonState = false;
      }  
    }else if(button16G.isMouseOver()){ // Verify if mouse is over button16G
      button16G.toggle();
      if(button16G.getState()==true){ // Get the state of the button. 
        option = "4"; 
        button2G.ButtonState = false;
        button4G.ButtonState = false;
        button8G.ButtonState = false;
      }  
    }else if(buttonTemp.isMouseOver()){ // Verify if mouse is over the temperature button
      buttonTemp.toggle();
      if(buttonTemp.getState()==true){ // Get the state of the button. 
        option = "5"; 
      }  
    }else if(buttonPulse.isMouseOver()){ // Verify if mouse is over the pulse sensor button
      buttonPulse.toggle();
      if(buttonPulse.getState()==true){ // Get the state of the button. 
        option = "6"; 
      }  
    }else if(buttonNext.isMouseOver()){ // Verify if mouse is over the buttonNext
      if(round<10){ 
        scores[round]=sw.second(); // Saves the seconds taken to look for the image. 
        buttonNext.toggle();
        round = round+1; // Goes to next round. 
        sw.stop(); // Stops timer.
        sw.start(); // Starts timer again.
      }else{
        showScore=true; // Score can now be displayed. 
      }
    }
    port.write(option); // Prints value to port, it sends a message to the Arduino.
    port.write(10); // New Line
  }
