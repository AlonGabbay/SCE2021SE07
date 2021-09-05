class MovingPad extends Pad {
  
  float xspd = 3;
  
  MovingPad(float x, float y, int id, int stage) {
    super(x, y, id, stage);
    this.type=1;  
}
  
  void move(float yspeed) {
      pos.y+=yspeed;
  }
  
  void movex() {
     if(pos.x < 40) {
          xspd = 3;
      } else if(pos.x > width - 40) {
          xspd = -3;
      }
      pos.x+=xspd; 
  }
  
  Pad clone() {
      Pad clone = new MovingPad(pos.x,pos.y, id, stage);
      return clone;
   }
}
