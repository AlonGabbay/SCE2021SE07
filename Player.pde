class Player {
  
  NeuralNet brain;
  
  ArrayList<Pad> pads;
  ArrayList<Pad> padPos;
  
  PVector pos;
  PImage sprite;
  PImage sheet;
  
  float lifetime;
  float movement = 0;
  float padspacing;
  float w, h;
  float fitness;
  float yspeed;
  float xacc;
  
  int score = 0;
  int padCount = 10;
  int padItter = 0;
  
  boolean dead = false;
  boolean replay = false;
  int stage = 0;
  int numOfErasedPads = 0;
  int atCurrentPad = 1;
  float[] vision;
  float[] decision;
  
  
  
   QLearning qlearning_matrix;
  int ydivision = 10;
  int xdivision = 40;
  int previous_score = 0;
  int previous_collision = -1; 
  int target_platform = 2;
  int base_score = 0;
  
  
  
  Player() {
    if(RL==true)
        qlearning_matrix = new QLearning();
       
    if(DNN)
    lifetime = 100;
    else lifetime =500;
    brain = new NeuralNet(input_nodes,hidden_nodes,output_nodes,hidden_layers);
    pads = new ArrayList<Pad>();
    padPos = new ArrayList<Pad>();
    padspacing = height/padCount;
    for(int i=padCount; i>=1; i--) {
      Pad newPad = new Pad(random(40,width-40), i*padspacing, padCount - i + 1, 0); 
      pads.add(newPad);
      padPos.add(newPad.clone());
    }
    pos = new PVector(width/2, height/2);
    sprite = loadImage("/sprites/Idle.png");
    w = 43.5;
    h = 79.5;
    fitness = 0;
    yspeed = -gravity;
    xacc = 0;
  }
    Player(QLearning myQTable) {
    qlearning_matrix = myQTable;
    if(DNN)
    lifetime = 100;
    else lifetime =500;    
    brain = new NeuralNet(input_nodes,hidden_nodes,output_nodes,hidden_layers);
    pads = new ArrayList<Pad>();
    padPos = new ArrayList<Pad>();
    padspacing = height/padCount;
    for(int i=padCount; i>=1; i--) {
      Pad newPad = new Pad(random(40,width-40), i*padspacing, padCount - i + 1, 0); 
      pads.add(newPad);
      padPos.add(newPad.clone());
    }
    pos = new PVector(width/2, height/2);
    sprite = loadImage("/sprites/Idle.png");
    w = 43.5;
    h = 79.5;
    fitness = 0;
    yspeed = -gravity;
    xacc = 0;
  }
  
  Player(int layers) {
    lifetime = 100;
    brain = new NeuralNet(input_nodes,hidden_nodes,output_nodes,layers);
    pads = new ArrayList<Pad>();
    padPos = new ArrayList<Pad>();
    padspacing = height/padCount;
    for(int i=padCount; i>=1; i--) {
      Pad newPad = new Pad(random(40,width-40), i*padspacing, padCount - i + 1, 0); 
       pads.add(newPad);
       padPos.add(newPad.clone());
    }
    pos = new PVector(width/2, height/2);
    sprite = loadImage("/sprites/Idle.png");
    w = 43.5;
    h = 79.5;
    fitness = 0;
    yspeed = -gravity;
    xacc = 0;
    }
  
  Player(ArrayList<Pad> padPositions) {
    replay = true;
    lifetime = 100;
    brain = new NeuralNet(input_nodes,hidden_nodes,output_nodes,hidden_layers);
    pads = new ArrayList<Pad>();
    padPos = padPositions;
    for(int i=1; i<=10; i++) {
       Pad newPad = padPos.get(padItter).clone();
       pads.add(newPad);
       padItter += 1;
    }
    pos = new PVector(width/2, height/2);
    sprite = loadImage("/sprites/Idle.png");
    //sheet = loadImage("/sprites/spritesheet.png");
    w = 43.5;
    h = 79.5;
    fitness = 0;
    yspeed = -gravity;
    xacc = 0;
  }
  
  void show() {
    for(int i=0; i<pads.size(); i++) {
      pads.get(i).show(); 
    }
    imageMode(CENTER);
    //image(sheet.get(20,20,100,100), pos.x, pos.y, w, h);
    image(sprite, pos.x, pos.y, w, h);
  }
  
  void catchUp() {
     pos.y -= yspeed/1.5; 
  }
  
  void moveLeft() {
    if(xacc > 0) {
      moveStop();
    }
    if(xacc > -10) {
      xacc -= 0.5;
    }
  }
  
  void moveRight() {
    if(xacc < 0) {
      moveStop();
    }
    if(xacc < 10) {
      xacc += 0.5;
    }
  }
  
  void moveStop() {
     xacc = 0; 
  }
  
  void move() {
    if(!dead) {
      if(yspeed > 0) {
        if(pos.y > height/2) {
           catchUp(); 
        } else {
           moveUp();
        }
      }
      if(yspeed < 0) {
         moveDown();
      }
      yspeed -= gravity;
      pos.x += xacc;
      //println(xacc);
      /*
      if(pos.x < 0) {
         pos.x = 25; 
      } else if(pos.x > width) {
         pos.x = width - 25; 
      }
      */
      if(pos.x < 0) {
         pos.x = width; 
      } else if(pos.x > width) {
         pos.x = 0; 
      }
      
      if(DNN||RL) {
        if(DNN)
        lifetime-=1;
        else{lifetime=lifetime-0.5;}
        if(lifetime < 0) {
         dead = true; 
        }
      }
      for(int i=0; i<pads.size(); i++) {
         pads.get(i).movex();
      }
    }
  }
  
   void moveUp() {
    for(int i=0; i<pads.size(); i++) {
       pads.get(i).move(yspeed);
    }
    if(pads.get(0).pos.y > height) {
       //float pady = pads.get(0).pos.y;
       pads.remove(0);
       this.numOfErasedPads++;
       
       if((this.numOfErasedPads >= 39 + (50 * stage)) && stage < 10)
           stage++;
        
       if(pads.size() < padCount) {
         if(replay) {
              pads.add(padPos.get(padItter).clone());
              padItter += 1;
         } else {
             int choice = floor(random(0,10));
             Pad newPad;
             if(choice == 1) {
               newPad = new  MovingPad(random(40,width-40), pads.get(pads.size()-1).pos.y-padspacing, pads.get(pads.size()-1).id, stage); 
             } else {
               newPad = new Pad(random(40,width-40), pads.get(pads.size()-1).pos.y-padspacing, pads.get(pads.size()-1).id, stage);
             }
             pads.add(newPad);
             padPos.add(newPad.clone());
         }
       }
     } 
     score+=1;
     if(score % 1000 == 0 && padCount > 5) {
        padCount-=1; 
        padspacing = height / padCount;
     }
     if(DNN)
     lifetime = 100;
     if(RL)
     lifetime = 500;
  }
  
  void moveDown() {
    if(pos.y > height) {
       dead = true;
    }
    pos.y += abs(yspeed);
    for(int i=0; i<pads.size(); i++) {
        Pad currentpad = pads.get(i);
        int padId = currentpad.checkCollisionBounce(pos.x-w/2,pos.y+h/2);
        if(((this.atCurrentPad = currentpad.checkCollisionBounce(pos.x-w/2,pos.y+h/2)) != 0) || (this.atCurrentPad = currentpad.checkCollisionBounce(pos.x+20, pos.y+h/2)) != 0) {
            yspeed = 15;
            this.atCurrentPad = this.numOfErasedPads + padId;
        }
    } 
  }
  
  int padCollision(float x, float y) {
    for(int i=0; i<pads.size(); i++) {
      int id;
      if((id = pads.get(i).checkCollision(x,y)) != 0) {
        return id;
      }
    }
    return 0;
    
  }
  
  void look() {
      //bottom vision //<>//
      vision = new float[5];
      vision[0] = lookInDirection(new PVector(10,0));
      vision[1] = lookInDirection(new PVector(10,10));
      vision[2] = lookInDirection(new PVector(0,10));
      vision[3] = lookInDirection(new PVector(-10,10));
      vision[4] = lookInDirection(new PVector(-10,0));


  }
  float lookInDirection(PVector direction) {
     float look = 0;
     PVector vis = new PVector(pos.x, pos.y);
     float distance = 0;
     while(padCollision(vis.x, vis.y) == 0) {
        if (vis.x < 0 || vis.x > width || vis.y < 0 || vis.y > height) {
          return 0; 
        }
        vis.add(direction);
        distance+=1;
        if(replay) {
          fill(255, 255, 255);
          noStroke();
          ellipse(vis.x,vis.y,3,3);
        }
     }
     look = 1/distance;
     return look;
  }
  
  void think() {
      decision = brain.output(vision);
      int maxIndex = 0;
      float max = 0;
      for(int i=0; i< decision.length; i++) {
         if(decision[i] > max) {
            max = decision[i];
            maxIndex = i;
         }
      }
      switch(maxIndex) {
         case 0:
           moveLeft();
           break;
         case 1:
           moveStop();
           break;
         case 2:
           moveRight();
           break;
      }
  }
  
  float calculateFitness() {
     fitness = score;
     return fitness;
  }
  
  void mutate() {
     brain.mutate(mutationRate); 
  }
  
  Player clone() {
     Player clone = new Player();
     clone.brain = brain.clone();
     return clone;
  }
  
  Player cloneReplay() {
     Player clone = new Player(padPos);
     clone.brain = brain.clone();
     return clone;
  }
  
  Player breed(Player parent) {
     Player child = new Player();
     child.brain = brain.crossover(parent.brain);
     return child;
  }
  
  
  int[][] get_state(){
    int[][] states = new int[10][3];
    for(int i=0; i<=pads.size()-1; i++) {
      states[i][0]= (1*(pads.get(i).state)|pads.get(i).type);
      states[i][1]= round((pads.get(i).pos.y-pos.y)/ydivision) * ydivision;
      states[i][2]= abs(round( (pads.get(i).pos.x - pos.x) / xdivision))*xdivision;
     }
     return states;   
  }
  int[][] myStates = new int[10][3];
  float previous_player_height = 0;
  float scale_reward_pos = 1/75; // scale down reward because height difference is too high
  float scale_death;
  int previous_collision2 = -3;
  void decide(){
    
      if (target_platform >= 0 && previous_collision >= 0 ) {
        print("wtf");
        if (dead==true) {
            scale_death = 1 + score/2000;
            qlearning_matrix.reward(-100*scale_death);
            //console.log("dead");
            highscore = player.score;
            player = new Player(); 
        } else {
            if(previous_collision != target_platform){
              if(myStates[target_platform][1] < myStates[previous_collision][1])
                  qlearning_matrix.reward(-20);
                else
                  qlearning_matrix.reward(-10);
            }
            qlearning_matrix.predict(myStates[previous_collision]);
            float r = (score-previous_score-20);
            qlearning_matrix.reward(r);

        }
    }
    previous_score = score;
    for(int i = 0; i < get_state().length; i++)
      myStates[i] = get_state()[i].clone();
    float [] predictions = new float[pads.size()];
    float maxreward = 0;
    int maxrewardindex = 0;
    for (int zz = 0; zz < pads.size()-1; zz++) {
            predictions[zz] = qlearning_matrix.predict(myStates[zz]);
            pads.get(zz).reward = predictions[zz];
            if(predictions[zz] > predictions[maxrewardindex]){
              maxreward = predictions[zz];
              maxrewardindex = zz;
            }
    }
    target_platform = maxrewardindex;

    qlearning_matrix.predict(myStates[target_platform]);
    for(int i=0;i<pads.size();i++){
      pads.get(i).target=0;
    }
    pads.get(target_platform).target =1;
    previous_player_height = player.h;
    previous_collision2 = previous_collision;
  }
  
  String direction(float n){
    //println(n);
    String dir="none";
    if(n==int(n) &&n>=0 && n<=9){
      Pad p=pads.get((int)n).cloneRL();
      if(p.pos.x+25<pos.x)
          dir="left";
          else if(pos.x<p.pos.x+15)
                   dir="right";
    
    }
    return dir;
  }
  
  
  QLearning RLcalc(){
    float decision=-50;
      if(round(this.yspeed*5) ==decision){
        //print("deciding");  
        decide();
      }
      if (direction(target_platform) == "left") {
            moveLeft();
            
        } else if(direction(target_platform) == "right"){
            moveRight();


        }
  SwitchTarget();
  return qlearning_matrix.clone();
  }
  
  
   void SwitchTarget(){
          imageMode(CENTER);
          image(pic, pads.get(target_platform).pos.x, pads.get(target_platform).pos.y, w+40, h+15);
    }
}
