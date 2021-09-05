class Population {
   Player[] players;
   
   Player bestPlayer;
  
   int gen = 0;
   
   float fitnessSum;
   float bestFitness = 0;
  
   Population(int size) {
       players = new Player[size];
       for(int i=0; i<size; i++) {
          players[i] = new Player(); 
       }
       bestPlayer = players[0];
   }
   
   void show() {
     if(!replayBest) {
        for(int i=0; i<players.length; i++) {
           players[i].show(); 
        }
     } else {
        bestPlayer.show(); 
        bestPlayer.brain.show(10, height-160, 200, 150, bestPlayer.vision, bestPlayer.decision);
     }
   }
   
   void update() {
     if(!bestPlayer.dead) {
        bestPlayer.look();
        //println("looked");
        bestPlayer.think();
        bestPlayer.move();
     }
     for(int i=0; i<players.length; i++) {
        if(!players[i].dead) {
           players[i].look();
           players[i].think();
           players[i].move(); 
        }
     }
   }
   
   boolean done() {
      for(int i=0; i<players.length; i++) {
         if(!players[i].dead) {
            return false; 
         }
      }
      if(!bestPlayer.dead) {
         return false; 
      }
      return true;
   }
   
   void calculateFitness() {
     fitnessSum = 0;
     float mazeget;
     for(int i=0; i<players.length; i++) {
        mazeget=players[i].calculateFitness();
        fitnessSum +=  mazeget;
     }
   }
   
   void setBestPlayer() {
      int bestIndex = 0;
      float best = 0;
      for(int i=0; i<players.length; i++) {
          if(players[i].fitness > best) {
             best = players[i].fitness;
             bestIndex = i;
          }
      }
      evolution.add(int(best));

      if(best > bestFitness) {
         newBest = true;
        bestFitness = best;
        bestPlayer = players[bestIndex].cloneReplay();
        bestPlayer.replay = true;
        newBest = true;
      } else {
        newBest = false;
        last_gen_highscore = int(best);
        bestPlayer = bestPlayer.cloneReplay(); 

      }
   }
   
   Player selectPlayer() {
      float rand = random(fitnessSum);
      float runSum = 0;
      for(int i=0; i<players.length; i++) {
        runSum += players[i].fitness;
        if(runSum > rand) {
            return players[i];
        }
      }  
      return players[0];
   }
   
   void naturalSelection() {
        setBestPlayer();
        
        Player[] newPlayers = new Player[players.length];
        newPlayers[0] = bestPlayer.clone();
        for(int i=1; i<newPlayers.length; i++) {
            Player child = selectPlayer().breed(selectPlayer());
            child.mutate();
            newPlayers[i] = child;
            
        }
        players = newPlayers.clone();
        gen+=1;
     
   }
   
   
   
   
}
