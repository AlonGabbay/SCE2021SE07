class Pad {
   int id;
   int stage;
   PVector pos;
   float w, h;
   PImage platform;
   PImage platformTarget;
   int state;
   int type;
   int target;
   float reward;
   PImage temp;
   Pad(float x, float y, int id, int stage) {
     this.type =0;
     this.state=0;
     this.target=0;
     this.reward=0;
     this.id = id;
     this.platformTarget=null;
     pos = new PVector(x, y);
     this.stage = stage;
     switch(this.stage){
       case 0:
       platform = loadImage("/sprites/pad_1.png"); 
       break;
       case 1:
       platform = loadImage("/sprites/pad_2.png");
       break;
       case 2:
       platform = loadImage("/sprites/pad_3.png");
       break;
       case 3:
       platform = loadImage("/sprites/pad_4.png");
       break;
       case 4:
       platform = loadImage("/sprites/pad_5.png");
       break;
       default:
       platform = loadImage("/sprites/platform.png"); 
     }
     temp=platform;
     w = 70;
     h = 17;
   }
   Pad(float x,float y,int id,int stage,int target,int type,float reward,int state) {
     this.type =type;
     this.state=state;
     this.target=target;
     this.reward=reward;
     this.id = id;
     this.platformTarget=null;

     pos = new PVector(x, y);
     this.stage = stage;
     switch(this.stage){
       case 0:
       platform = loadImage("/sprites/pad_1.png"); 
       break;
       case 1:
       platform = loadImage("/sprites/pad_2.png");
       break;
       case 2:
       platform = loadImage("/sprites/pad_3.png");
       break;
       case 3:
       platform = loadImage("/sprites/pad_4.png");
       break;
       case 4:
       platform = loadImage("/sprites/pad_5.png");
       break;
       default:
       platform = loadImage("/sprites/platform.png"); 
     }   
     w = 70;
     h = 17;
   }
   void show() {
      imageMode(CENTER);
      image(platform, pos.x, pos.y, w, h);
   }
   
   void move(float yspeed) {
     pos.y+=yspeed;
   }
   
   void movex() {}
   
   int checkCollisionBounce(float x, float y) {
      if(x >= pos.x-w/2 && x <= pos.x+w/2 && y >= pos.y-h/2 && y <= pos.y+h/2) {
        this.state=1;
        return this.id; 
      }
      return 0;
   }
   
   int checkCollision(float x, float y) {
      if(x >= pos.x-w/2 && x <= pos.x+w/2 && y >= pos.y-h/2 && y <= pos.y+h/2) {
        this.state=1;
        return this.id; 
      }
      return 0;
   }
   
   Pad clone() {
      Pad clone = new Pad(pos.x,pos.y, this.id, stage);
      return clone;
   }
   Pad cloneRL(){
     Pad clone = new Pad(pos.x,pos.y, this.id, this.stage,this.target,this.type,this.reward,this.state);
     return clone;
   }
   
}
