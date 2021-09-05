class Button { 
  float X, Y, W, H;
  boolean menu;
  String text;
  Button(float x, float y, float w, float h, String t, boolean menu) {
    X = x;
    Y = y;
    W = w;
    H = h;
    text = t;
    this.menu = menu;
  }
  
  boolean collide(float x, float y) {
    if(x >= X-W/2 && x <= X+W/2 && y >= Y-H/2 && y <= Y+H/2) {
       return true; 
    }
    return false;
  }
  
  void show() {
      if(this.menu){
        menuButtonShow();
      }else {
        regularButtonShow();
      }
  }
  
  void regularButtonShow(){
    fill(255);
    stroke(0);
    rectMode(CENTER);
    rect(X, Y, W, H);
    textSize(22);
    textAlign(CENTER,CENTER);
    fill(0);
    noStroke();
    text(text,X,Y-3);
  }
  
  void menuButtonShow(){
    fill(3, 252, 148);
    stroke(0);
    rectMode(CENTER);
    rect(X, Y, W, H, 20, 20, 20, 20);
    textSize(22);
    textAlign(CENTER,CENTER);
    fill(0);
    noStroke();
    text(text,X,Y-3);
  }
}
