// The purpose of this function is to create a virtual scenerio that is controlled by the coordinates of the accelerometer.
void virtualEnvironment() {
  canvas.beginDraw();
  canvas.background(0);
  canvas.camera(0, 1, 0, 1, 0, 0, 0, 0, 1); // Define the initial view.

  canvas.beginCamera();
  // The canvas rotates using the accelerometer information.
  canvas.rotateX(x);
  canvas.rotateY(y);
  canvas.rotateZ(z);
  
  // Draw the images
  int center = 550;
  canvas.pushMatrix();
  canvas.translate(0, 0, center);
  canvas.image(img1, -img1.width/2, -img1.height/2); // Tecnun
  canvas.popMatrix();
  
  canvas.pushMatrix();
  canvas.translate(0, 0, center);
  canvas.image(img2, -img2.width/2, -img2.height/2-550);  // Concert
  canvas.popMatrix();

  canvas.pushMatrix();
  canvas.translate(0, 0, -center);
  canvas.image(img6, -img6.width/2, -img6.height/2); //Paris
  canvas.popMatrix();

  canvas.pushMatrix();
  canvas.translate(0, center, 0);
  canvas.rotateX(radians(90));
  canvas.rotateZ(radians(180));
  canvas.image(img6, -img6.width/2-500, -img6.height/2);  // Paris
  canvas.popMatrix();

  canvas.pushMatrix();
  canvas.translate(0, -center, 0);
  canvas.rotateX(radians(90));
  canvas.image(img3, -img3.width/2, -img3.height/2);  // San Sebastian
  canvas.popMatrix();
  
  canvas.pushMatrix();
  canvas.translate(0, -center, 0);
  canvas.rotateX(radians(90));
  canvas.image(img5, -img5.width/2, -img5.height/2-550); // Mountain
  canvas.popMatrix();

  canvas.pushMatrix();
  canvas.translate(center, 0, 0);
  canvas.rotateY(radians(90));
  canvas.image(img4, -img4.width/2, -img4.height/2); // Air balloons
  canvas.popMatrix();

  canvas.endCamera();
  canvas.endDraw();
  image(canvas, 0, 0);
}
