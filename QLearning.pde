class QLearning{
  int[][][] actions;
  int PLATFORM_TYPE = 2;
  int HEIGHT_SPACE = 1000;
  int WIDTH_SPACE = 1000;
  int explored;
  int[] last_state;
  float learning_rate;
  float random=1;
  QLearning(){
    actions = new int[PLATFORM_TYPE][WIDTH_SPACE][HEIGHT_SPACE] ; // the full set of actions
    this.explored = 0; // how many states have been explored
    this.last_state = new int[3]; // the last state predicted
    this.learning_rate=1;
    this.random = 1;
  }  
  QLearning(int[][][] actions,int explored,int[] last_state){
    this.actions =  new int[PLATFORM_TYPE][WIDTH_SPACE][HEIGHT_SPACE];
    this.last_state = new int[3];
    for(int i = 0; i < PLATFORM_TYPE; i++)
      for(int j = 0; j < WIDTH_SPACE; j++)
        for(int k = 0; k < HEIGHT_SPACE; k++){
            //print(i,j,k);
            this.actions[i][j][k] = actions[i][j][k];
        }
      this.explored = explored;
      arrayCopy(last_state,this.last_state);
      this.learning_rate=1;
      this.random=1;

  }
  QLearning clone(){
      QLearning clone = new QLearning(this.actions,this.explored,this.last_state);
      return clone;
  }
  int predict(int[] state) {
        arrayCopy(state,this.last_state);
        int i = state[0]; // type of platform / size of 2
        int j = state[1]; // ydistance to platform
        int k = state[2]; // xdist
        if(j<0)
           j+=1000;
        if (this.actions[i][j][k]!=0) // if this type of platform has been seen
              return this.actions[i][j][k];
                else{ // this type of platform has not been seen
            this.actions[i][j][k] = 1+round(random(0,1)*100); // add the distance
            this.explored++; // new state discovered
            return this.actions[i][j][k];
                }
    }
    
    void reward(float amount){
        int positive =0;
        int i =this.last_state[0]; // type of platform / size of 2
        int j =this.last_state[1]; // ydistance to platform
        int k =this.last_state[2]; // xdist
        if(this.actions[i][j][k] > 0)
            positive = 1;
        this.actions[i][j][k] += this.learning_rate*amount;
        if(this.actions[i][j][k] == 0 && positive == 1)
            this.actions[i][j][k] -= 1;
    }
    
    
    
    
    
    
}
