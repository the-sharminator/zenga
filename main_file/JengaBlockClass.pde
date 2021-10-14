class JengaBlock {

  PVector pos;
  PVector size = new PVector(250, 100, 750);
  PVector velocity = new PVector(0,0,0);
  color blockColor;

  JengaBlock(int xPosTemp, int yPosTemp, color blockColorTemp) {
    pos = new PVector(xPosTemp, yPosTemp, 0);
    blockColor = blockColorTemp;
  }
  
  void display() {
    // Method for handling the rendering of each block, depending on its position. Rotation changes depending on the row (pos.y).
    pos.set(pos.x += velocity.x, pos.y += velocity.y, pos.z += velocity.z);
    pushMatrix();
    rotateY(radians(pos.y % 2 == 0 ? 45 : -45));
    translate((pos.x * size.x) - size.x, (height * 0.75) - (pos.y * size.y), 0);
    box(size.x, size.y, size.z);
    popMatrix();
  }
  
  void collapse() {
    velocity.set(random(-2,2), -2, random(-2,2));
    velocity.x = (velocity.x == 0 ? velocity.x + 1 : velocity.x);
    velocity.z = (velocity.z == 0 ? velocity.z - 1 : velocity.z);
  }

}
