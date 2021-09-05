final int hidden_layers = 2;
final int hidden_nodes = 5;
final int input_nodes = 5;
final int output_nodes = 3;
final float gravity = 0.3;
final float mutationRate = 0.02; 
final boolean replayBest = true;

boolean DNN= false;
boolean RL= false;
boolean humanPlaying = false;
boolean menu = true;

PImage bg;
PImage menu_bg;
PImage pic;
int highscore = 0;
int last_gen_highscore = 0;
boolean newBest = true;
boolean modelLoaded = false;
boolean networkPlaying = true;


int RL_HS=0;
int RL_iter=0;
Player player;
Player model;
Population pop;
PFont font;

ArrayList<Integer> evolution;
Button graphButton;
Button saveButton;
Button loadButton;

Button goBack;

Button dnnButton;
Button rlButton;
Button humanButton;

EvolutionGraph graph;



int yvdivison = 10;
int xdivision = 40;
int previous_score = 0;
int previous_collision = -1;
int target_platform = -2;
int base_score = 0;



public void settings() {
  size(600,1000);
   bg = loadImage("/sprites/tower_background_full.png");
   menu_bg = loadImage("/sprites/Icy_Tower_Logo_and_tower_bg.png");
   bg.resize(600, 1000);
   menu_bg.resize(600, 1000);
   
}

void setup() {

  frameRate(120);

  pic =loadImage("/sprites/Target.png");
  evolution = new ArrayList<Integer>();
  graphButton = new Button(60,185,100,30,"Graph", false);
  saveButton= new Button(60,225,100,30,"Save", false);
  loadButton = new Button(60,265,100,30,"Load", false);
  goBack = new Button(60,800,100,30,"Back", false);
  dnnButton = new Button(300,700,300,30,"Deep Neural Network", true);
  rlButton = new Button(300,600,300,30,"Reinforcement Learning", true);
  humanButton = new Button(300,500,300,30,"Human mode", true);
  
}

void draw() {
   if(humanPlaying && !menu) {
     background(bg);
     if(keyPressed) {
        if(key == 'a') {
          player.moveLeft();
        }
        if(key == 'd') {
          player.moveRight();
        } 
     }
     player.move();
     player.show();
     if(player.dead) {
        if(player.score > highscore)
           highscore = player.score;
        player = new Player(); 
     }
     fill(255);
     textAlign(CORNER,TOP);
     textSize(30);
     text("Score : "+player.score, 10, 10);
     text("Highscore : "+highscore, 10, 50);

   } else if(DNN && !menu){
     background(bg);
     if(!modelLoaded) {
      if(pop.done()) {
         highscore = pop.bestPlayer.score;
         pop.calculateFitness();
         pop.naturalSelection();
      } else {
         pop.update();
         pop.show();
      }
     }
     else{
      model.look();
      model.think();
      model.move();
      model.show();
      model.brain.show(10,height-160,200,150,model.vision,model.decision);
      if(model.dead) {
        Player newmodel = new Player();
        newmodel.brain = model.brain.clone();
        model = newmodel;
        
     }

    }
      
      
      fill(255, 255, 255);
      textAlign(CORNER,TOP);
      textSize(30);
      
     int score = 0;
     if(!modelLoaded){
       text("life time: "+pop.bestPlayer.lifetime, 10, 130);
       score = pop.bestPlayer.score;
       text("Highscore : "+highscore, 10, 50);  
      if(newBest==false){
        text("Last Gen Highscore : "+last_gen_highscore, 10, 90);
      }
      else{
        text("New best!!",10,90);

      }
      text("Gen : "+pop.gen, 450, 10);
     }
     else{
       score = model.score;
     }
      text("Score : "+score, 10, 10);
      graphButton.show();
      saveButton.show();
      loadButton.show();
   }
   else if(RL && !menu){
     background(bg);
     player.move();
     player.show();
     QLearning qlearning_matrix =player.RLcalc();
     if(player.dead) {
         RL_iter+=1;
        player = new Player(qlearning_matrix); 
 }
     if(RL_HS<player.score)
         RL_HS=player.score;
 
  //println(player.yspeed);
     fill(255);
     textAlign(CORNER,TOP);
     textSize(30);
     text("Score : "+player.score, 10, 10);
     text("Highscore : "+RL_HS, 10, 50);
     text("Iteration : "+RL_iter, 10, 90);
     text("Life time: "+player.lifetime, 10, 130);
     text("Unique states: "+player.qlearning_matrix.explored, 10, 170);



 }
 if (menu){
     background(menu_bg);
     dnnButton.show();
     rlButton.show();
     humanButton.show();
     fill(255);
     textSize(15);
     textAlign(CORNER,BOTTOM);
     text("Authors:", 20, 30);
     text("Yakir Kobaivanov", 20, 60);
     text("Alon Gabay", 20, 90);
 }
}
void fileSelectedOut(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    String path = selection.getAbsolutePath();
    Table modelTable = new Table();
    Player modelToSave = pop.bestPlayer.clone();
    Matrix[] modelWeights = modelToSave.brain.pull();
    float[][] weights = new float[modelWeights.length][];
    for(int i=0; i<weights.length; i++) {
       weights[i] = modelWeights[i].toArray(); 
    }
    for(int i=0; i<weights.length; i++) {
       modelTable.addColumn("L"+i); 
    }
    modelTable.addColumn("Graph");
    int maxLen = weights[0].length;
    for(int i=1; i<weights.length; i++) {
       if(weights[i].length > maxLen) {
          maxLen = weights[i].length; 
       }
    }
    int g = 0;
    for(int i=0; i<maxLen; i++) {
       TableRow newRow = modelTable.addRow();
       for(int j=0; j<weights.length+1; j++) {
           if(j == weights.length) {
             if(g < evolution.size()) {
                newRow.setInt("Graph",evolution.get(g));
                g++;
             }
           } else if(i < weights[j].length) {
              newRow.setFloat("L"+j,weights[j][i]); 
           }
       }
    }
    saveTable(modelTable, path);
    
  }
}

void fileSelectedIn(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    String path = selection.getAbsolutePath();
    Table modelTable = loadTable(path,"header");
    Matrix[] weights = new Matrix[modelTable.getColumnCount()-1];
    float[][] in = new float[hidden_nodes][input_nodes+1];
    for(int i=0; i< hidden_nodes; i++) {
      for(int j=0; j< (input_nodes+1); j++) {
        in[i][j] = modelTable.getFloat(j+i*(input_nodes+1),"L0");     
      }  
    }
    weights[0] = new Matrix(in);
    
    for(int h=1; h<weights.length-1; h++) {
       float[][] hid = new float[hidden_nodes][hidden_nodes+1];
       for(int i=0; i< hidden_nodes; i++) {
          for(int j=0; j< hidden_nodes+1; j++) {
            hid[i][j] = modelTable.getFloat(j+i*(hidden_nodes+1),"L"+h);
          }  
       }
       weights[h] = new Matrix(hid);
    }
    
    float[][] out = new float[output_nodes][hidden_nodes+1];
    for(int i=0; i< output_nodes; i++) {
      for(int j=0; j< hidden_nodes+1; j++) {
        out[i][j] = modelTable.getFloat(j+i*(hidden_nodes+1),"L"+(weights.length-1));
      }  
    }
    weights[weights.length-1] = new Matrix(out);
    
    evolution = new ArrayList<Integer>();
    int g = 0;
    int genscore = modelTable.getInt(g,"Graph");
    while(genscore != 0) {
       evolution.add(genscore);
       g++;
       genscore = modelTable.getInt(g,"Graph");
    }
    humanPlaying = false;
    model = new Player(weights.length-1);
    model.brain.load(weights);
    
    delay(3000);    
    modelLoaded = true;
    networkPlaying = false;

  }
}


void mousePressed() {
   if(graphButton.collide(mouseX,mouseY)) {
       graph = new EvolutionGraph();
   }
   if(saveButton.collide(mouseX,mouseY)) {
       selectOutput("Save Player Model", "fileSelectedOut");
   }
   if(loadButton.collide(mouseX,mouseY)) {
       selectInput("Load Player Model", "fileSelectedIn");
   }
   if(dnnButton.collide(mouseX,mouseY)) {
       DNN= true;
       RL= false;
       humanPlaying = false;
       menu = false;
       pop = new Population(200);
      
   }
   if(rlButton.collide(mouseX,mouseY)) {
       DNN= false;
       RL= true;
       humanPlaying = false;
       menu = false;
       player = new Player();
       RL_iter=0;
       RL_HS=0;
       
   }
   if(humanButton.collide(mouseX,mouseY)) {
       DNN= false;
       RL= false;
       humanPlaying = true;
       menu = false;
       player = new Player();
   }
   
   //dnnButton.show();
   //rlButton.show();
   //humanButton.show();
}


void keyReleased() {
   if(key == 'a' || key == 'd') {
    player.moveStop();
  } 
}

// get back to the first menu
void keyPressed(){
   if(key == ESC){
     key = 0;
     menu = true;
     humanPlaying = false;
     DNN= true;
     RL= false;   
     highscore = 0;
     evolution = new ArrayList<Integer>();
   }
}

//void keyReleased() {
//   if(key == 'a') {
//    player.moveLeft();
//  } else if(key == 'd'){
//    player.moveRight();
//  }
//  player.moveStop();
//}
