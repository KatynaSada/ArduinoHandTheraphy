// The purpose of this function is to display the timer.
void time() {
  textAlign(CENTER);
  text(nf(sw.hour(), 2)+":"+nf(sw.minute(), 2)+":"+nf(sw.second(), 2), width-400, height-50);
}

// Class to create a timer. 
class StopWatchTimer {
  int startTime = 0, stopTime = 0;
  boolean running = false;

  // Start the timer.
  void start() {
    startTime = millis();
    running = true;
  }

  // Stop the timer.
  void stop() {
    stopTime = millis();
    running = false;
  }

  // Obtain the elapsed time.
  int getElapsedTime() {
    int elapsed;
    if (running) {
      elapsed = (millis() - startTime);
    } else {
      elapsed = (stopTime - startTime);
    }
    return elapsed;
  }

  // Get the seconds, minutes and hours.
  int second() {
    return (getElapsedTime() / 1000) % 60;
  }
  int minute() {
    return (getElapsedTime() / (1000*60)) % 60;
  }
  int hour() {
    return (getElapsedTime() / (1000*60*60)) % 24;
  }
}
