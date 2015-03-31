/*********************************************
 * OPL 12.6.1.0 Model
 * Author: EF Tittu
 * Creation Date: Jan 9, 2015 at 4:16:00 PM
 * resources: http://www-01.ibm.com/support/knowledgecenter/SSSA5P_12.6.1/ilog.odms.ide.help/OPL_Studio/usroplide/topics/opl_ide_solpool_ide_set.html
  * http://orinanobworld.blogspot.com/2013/01/finding-all-mip-optima-cplex-solution.html
  http://www.gams.com/dd/docs/solvers/cplex/index.html
  http://www-eio.upc.edu/lceio/manuals/cplex-11/html/refcppcplex/html/optional.html#1
  http://www-01.ibm.com/support/knowledgecenter/SSSA5P_12.6.1/ilog.odms.ide.help/OPL_Studio/oplparams/topics/PLUGINS_ROOT/ilog.odms.cplex.help/CPLEX/Parameters/topics/SolnPoolIntensity.html?lang=en
  http://www-01.ibm.com/support/knowledgecenter/SSSA5P_12.6.1/ilog.odms.ide.help/OPL_Studio/oplparams/topics/PLUGINS_ROOT/ilog.odms.cplex.help/CPLEX/UsrMan/topics/discr_optim/soln_pool/17_enumerate_title_synopsis.html?lang=en
  http://www-01.ibm.com/support/knowledgecenter/SSSA5P_12.4.0/ilog.odms.ide.help/OPL_Studio/opllanguser/topics/uss_langtut_script_intro_6.html
  http://www-01.ibm.com/support/docview.wss?uid=swg27039529&aid=1
  https://www.ibm.com/developerworks/community/forums/html/topic?id=77777777-0000-0000-0000-000014598447 <--not very good.
 *********************************************/

 


string requestMeal = ...;
float MIN_RATING = ...;
float budget=...;

tuple items
{

	//key string itemID;
 	float costPerUnit;
	{string} OptionalIngrID;
	{string} RequiredIngrID;
	float rating;
	
	//the following are indicator variables
	int bfItem;
	int lunchItem;
	int highTeaItem;
	int dinnerItem;
	
	int appetizer;
	int entree;
	int dessert;
	int beverage;
};

{string} itemIDs=...;

items Items[itemIDs]=...;



//User definition
tuple userDislikedIngr
{
	//key string userID;
	{string} dislikes_IngrID;
};
{string} userIDs = ...;

userDislikedIngr UserDislikedIngr[userIDs] = ...;


tuple IndUserRating
{
	string userID;
	string itemID;
	float mostRecentRating;
};

int numUserRatings = ...;
IndUserRating UserRatings[1..numUserRatings]=...;

{string} itemsPrechosen = ...;

tuple UserItemCombo
{
string userIDs;
string itemIDs;
};

{UserItemCombo} preAssDishes = ... ;

//Menu definition
 tuple menuProps
 {
    int PERSON_APPET_MIN;
    int PERSON_APPET_MAX;
    int PERSON_ENTREE_MIN;
    int PERSON_ENTREE_MAX;
    int PERSON_DESSERT_MIN;
    int PERSON_DESSERT_MAX;
    int PERSON_BEVERAGE_MIN;
    int PERSON_BEVERAGE_MAX;
    int PARTY_APPET_MAX;
    int PARTY_ENTREE_MAX;
    int PARTY_DESSERT_MAX;
    int PARTY_BEVERAGE_MAX;
};

menuProps menus=...;

{string} Appetizer;
{string} Entree;
{string} Dessert;
{string} Beverage;



execute INITIALIZE2
{
	cplex.solnpoolagap = .5; //for rounding errors
	cplex.solnpoolintensity = 4; //""exhaustive search"", not really. will search for more. up to some limit determined by i don't know.'
	cplex.populatelim = 50; //must set this in this case it terminates prematurely. CAveat, may terminate prematurely bc of this.
	for(var i in itemIDs){
	
		if(Items[i].appetizer == 1) Appetizer.add(i);
		if(Items[i].entree == 1) Entree.add(i);
		if(Items[i].dessert == 1) Dessert.add(i);
		if(Items[i].beverage == 1) Beverage.add(i);
			
	}
}	

//{UserItemCombo} AllCombos = {<u,i>| u in userIDs, i in itemIDs};

//MM
tuple itemIngr {
  string itemID;
  string ingrID;
}

{string} OptionalIngrs = { ingr | itemID in itemIDs, ingr in Items[itemID].OptionalIngrID };

{itemIngr} ItemOptionalIngrs = { <itemID, ingrID> | itemID in itemIDs, ingrID in Items[itemID].OptionalIngrID};




// Decision Variables:
dvar boolean Assignment[userIDs][itemIDs];
dvar boolean satisfiedUser[userIDs];
dvar boolean satAppetMin[userIDs];
dvar boolean satAppetMax[userIDs];
dvar boolean satEntreeMin[userIDs];
dvar boolean satEntreeMax[userIDs];
dvar boolean satDessertMin[userIDs];
dvar boolean satDessertMax[userIDs];
dvar boolean satBeverageMin[userIDs];
dvar boolean satBeverageMax[userIDs];

constraint	BadIngrConstraint[userIDs][itemIDs];
constraint	WhichMealConstraints[userIDs][itemIDs];

constraint FullSat[userIDs];
constraint PersonMinMaxConstraints1AppetMin[userIDs];
constraint PersonMinMaxConstraints1AppetMax[userIDs];
constraint PersonMinMaxConstraints1EntreeMin[userIDs];
constraint PersonMinMaxConstraints1EntreeMax[userIDs];
constraint PersonMinMaxConstraints1DessertMin[userIDs];
constraint PersonMinMaxConstraints1DessertMax[userIDs];
constraint PersonMinMaxConstraints1BeverageMin[userIDs];
constraint PersonMinMaxConstraints1BeverageMax[userIDs];

constraint PersonMinMaxConstraints2AppetMin[userIDs];
constraint PersonMinMaxConstraints2AppetMax[userIDs];
constraint PersonMinMaxConstraints2EntreeMin[userIDs];
constraint PersonMinMaxConstraints2EntreeMax[userIDs];
constraint PersonMinMaxConstraints2DessertMin[userIDs];
constraint PersonMinMaxConstraints2DessertMax[userIDs];
constraint PersonMinMaxConstraints2BeverageMin[userIDs];
constraint PersonMinMaxConstraints2BeverageMax[userIDs];




//MM 
maximize  sum(u in userIDs)( satAppetMin[u] + satAppetMax[u] + satEntreeMin[u] + satEntreeMax[u] + satDessertMin[u] + satDessertMax[u] + satBeverageMin[u] + satBeverageMax[u]);

subject to
{
	BudgetConstraint:
	sum(u in userIDs, i in itemIDs )(Assignment[u][i]*Items[i].costPerUnit) <= budget;

	forall(u in userIDs, i in itemIDs )
	{

		  	BadIngrConstraint[u][i]:
			if((card( UserDislikedIngr[u].dislikes_IngrID inter Items[i].RequiredIngrID) !=0) &&
			(<u,i> not in preAssDishes ))
			{Assignment[u][i]==0;}
			
			WhichMealConstraints[u][i]:
			if(requestMeal == "b" && Items[i].bfItem==0)	
			{Assignment[u][i]==0;}	
			if(requestMeal == "l" && Items[i].lunchItem==0)	
			{Assignment[u][i]==0;}	
			if(requestMeal == "d" && Items[i].dinnerItem==0)	
			{Assignment[u][i]==0;}	
			if(requestMeal == "t" && Items[i].highTeaItem==0)	
			{Assignment[u][i]==0;}		
  }
  forall(u in userIDs)
  {
		PersonMinMaxConstraints1AppetMin[u]:
		menus.PERSON_APPET_MIN <= sum(i in itemIDs : Items[i].appetizer == 1 )( Assignment[u][i]) => satAppetMin[u] == 1; 
		
		PersonMinMaxConstraints1AppetMax[u]:
		sum(i in itemIDs : Items[i].appetizer == 1)( Assignment[u][i]) <= menus.PERSON_APPET_MAX => satAppetMax[u] == 1;
		
		PersonMinMaxConstraints1EntreeMin[u]:
		menus.PERSON_ENTREE_MIN <= sum(i in itemIDs : Items[i].entree == 1)( Assignment[u][i]) => satEntreeMin[u] == 1;
		
		PersonMinMaxConstraints1EntreeMax[u]:
		sum(i in itemIDs : Items[i].entree == 1)( Assignment[u][i]) <= menus.PERSON_ENTREE_MAX => satEntreeMax[u] == 1;
		
		PersonMinMaxConstraints1DessertMin[u]:
		menus.PERSON_DESSERT_MIN <= sum(i in itemIDs : Items[i].dessert == 1)( Assignment[u][i]) => satDessertMin[u] == 1;
		
		PersonMinMaxConstraints1DessertMax[u]:
		sum(i in itemIDs : Items[i].dessert == 1)( Assignment[u][i]) <= menus.PERSON_DESSERT_MAX => satDessertMax[u] == 1;
		
		PersonMinMaxConstraints1BeverageMin[u]:
		menus.PERSON_BEVERAGE_MIN <= sum(i in itemIDs : Items[i].beverage == 1)( Assignment[u][i]) => satBeverageMin[u] == 1;
		
		PersonMinMaxConstraints1BeverageMax[u]:
		sum(i in itemIDs : Items[i].beverage == 1)( Assignment[u][i]) <= menus.PERSON_BEVERAGE_MAX => satBeverageMax[u] == 1;
		
		/////////////////////////////////////////////////////////////////////////////////////////////
		PersonMinMaxConstraints2AppetMin[u]:
		satAppetMin[u] == 1 => menus.PERSON_APPET_MIN <= sum(i in itemIDs : Items[i].appetizer == 1)( Assignment[u][i]) ;
		
		PersonMinMaxConstraints2AppetMax[u]:
		satAppetMax[u] == 1 => sum(i in itemIDs : Items[i].appetizer == 1)( Assignment[u][i]) <= menus.PERSON_APPET_MAX ;
		
		PersonMinMaxConstraints2EntreeMin[u]:
		satEntreeMin[u] == 1 => menus.PERSON_ENTREE_MIN <= sum(i in itemIDs : Items[i].entree == 1)( Assignment[u][i]);
		
		PersonMinMaxConstraints2EntreeMax[u]:
		satEntreeMax[u] == 1 =>	sum(i in itemIDs : Items[i].entree == 1)( Assignment[u][i]) <= menus.PERSON_ENTREE_MAX ;

		PersonMinMaxConstraints2DessertMin[u]:
		satDessertMin[u] == 1 => menus.PERSON_DESSERT_MIN <= sum(i in itemIDs : Items[i].dessert == 1)( Assignment[u][i]);
		
		PersonMinMaxConstraints2DessertMax[u]:
		satDessertMax[u] == 1 => sum(i in itemIDs : Items[i].dessert == 1)( Assignment[u][i]) <= menus.PERSON_DESSERT_MAX;
		
		
		PersonMinMaxConstraints2BeverageMin[u]:
		satBeverageMin[u] == 1 => menus.PERSON_BEVERAGE_MIN <= sum(i in itemIDs : Items[i].beverage == 1)( Assignment[u][i]);
		 
		 
		PersonMinMaxConstraints2BeverageMax[u]:
		satBeverageMax[u] == 1 => sum(i in itemIDs : Items[i].beverage == 1)( Assignment[u][i]) <= menus.PERSON_BEVERAGE_MAX;
		
		
		
		/*
		PersonMinMaxConstraints2AppetMin[u]:
		(sum(i in Appetizer )( Assignment[<u,i>])+1<= menus.PERSON_APPET_MIN)
		=> satAppetMin[u] == 0; 
		PersonMinMaxConstraints2AppetMax[u]:
		(menus.PERSON_APPET_MAX+1 <= sum(i in Appetizer )( Assignment[<u,i>]))
		=> satAppetMax[u] == 0;
		PersonMinMaxConstraints2EntreeMin[u]:
		(sum(i in Entree )( Assignment[<u,i>])+1 <= menus.PERSON_ENTREE_MIN )
		=> satEntreeMin[u] == 0;
		PersonMinMaxConstraints2EntreeMax[u]:
		(menus.PERSON_ENTREE_MAX +1 <= sum(i in Entree )( Assignment[<u,i>]) )
		=> satEntreeMax[u] == 0;
		PersonMinMaxConstraints2DessertMin[u]:
		(sum(i in Dessert )( Assignment[<u,i>])+1 <= menus.PERSON_DESSERT_MIN )
		=> satDessertMin[u] == 0;
		PersonMinMaxConstraints2DessertMax[u]:
		(menus.PERSON_DESSERT_MAX + 1 <= sum(i in Dessert )( Assignment[<u,i>]))
		=> satDessertMax[u] == 0;
		PersonMinMaxConstraints2BeverageMin[u]:
		 (sum(i in Beverage )( Assignment[<u,i>]) +1 <= menus.PERSON_BEVERAGE_MIN )
		=> satBeverageMin[u] == 0;
		PersonMinMaxConstraints2BeverageMax[u]:
		(menus.PERSON_BEVERAGE_MAX +1 <= sum(i in Beverage )( Assignment[<u,i>]) )
		=> satBeverageMax[u] == 0;
		*/
		FullSat[u]:
		satAppetMin[u] + satAppetMax[u] + 
		satEntreeMin[u] + satEntreeMax[u] +
		satDessertMin[u] + satDessertMax[u] +
		satBeverageMin[u] + satBeverageMax[u] <= 7 
		=> satisfiedUser[u]==0;
		satAppetMin[u] + satAppetMax[u] + 
		satEntreeMin[u] + satEntreeMax[u] +
		satDessertMin[u] + satDessertMax[u] +
		satBeverageMin[u] + satBeverageMax[u] >=8 
		=> satisfiedUser[u]==1;
		

	}
 
 	PartyMaxConstraints:
	sum(i in itemIDs : Items[i].appetizer == 1)(sum(u in userIDs)(Assignment[u][i]) >=1) <= menus.PARTY_APPET_MAX; 
	sum(i in itemIDs : Items[i].entree == 1)(sum(u in userIDs)(Assignment[u][i]) >=1) <= menus.PARTY_ENTREE_MAX; 
	sum(i in itemIDs : Items[i].dessert == 1)(sum(u in userIDs)(Assignment[u][i]) >=1) <= menus.PARTY_DESSERT_MAX; 
	sum(i in itemIDs : Items[i].beverage == 1)(sum(u in userIDs)(Assignment[u][i]) >=1) <= menus.PARTY_BEVERAGE_MAX;

	UserRatingConstraints:
	forall(i in 1..numUserRatings)
	  {
	  	if(UserRatings[i].mostRecentRating < MIN_RATING && <UserRatings[i].userID,UserRatings[i].itemID> not in preAssDishes)	
	  		{
	  		Assignment[UserRatings[i].userID][UserRatings[i].itemID] == 0;	  		
	  		}
	  }
	  
	DishRatingConstraints:
	forall(i in itemIDs)
	  {
	  	forall(u in userIDs)
	  	  	{	  
	  		
		  	if((Items[i].rating < MIN_RATING))
		  		{
		  		Assignment[u][i] == 0;	  		
		  		}	  
   			}	  		
	  }

	PreSelectedDishesConstraints:
	forall(i in itemIDs)
	  {
	  	if ( (card(itemsPrechosen)!=0) && (i not in itemsPrechosen) )	
	  		{sum(u in userIDs)(Assignment[u][i]) == 0 ;}
	  }
	  
	PreassignedDishesConstraints:
	forall(p in preAssDishes)
	  {
		Assignment[ p.userIDs ][p.itemIDs] == 1;
	  }
	/*
	forall(i in itemIDs,ingr in Items[i].OptionalIngrID,user in userIDs)
		  {
		    //(Assignment[user][i] == 1) && (ingr in (UserDislikedIngr[user].dislikes_IngrID)) => EatDislikeRxps[<user,ingr>]  == 1;		  
		  }		
	*/

	

}

execute POSTPROCESS1
{
	writeln("Pre-Chosen Dishes: ");

	
	for(var u in itemsPrechosen)
	{
	writeln(u + ",");	
	}

    writeln("Pre-Assigned Dishes: ");

	
	for(var u in preAssDishes)
	{
	writeln(u + ",");	
	}
    writeln("ItemOptionalIngrs that are disliked by somebody");
    
	for(var i in ItemOptionalIngrs){
	  writeln(i.itemID + ": " + i.ingrID);	
	}
	
	for(var u in userIDs)
	{
	writeln("User "+ u + ": {");	
	
	for(var i in itemIDs)	
	{
        	
		if((Assignment[u][i]==1)){
		  	writeln(i + "	");  
		  	}  	  
  	}
  	writeln("}\n");	
 }  	  	
}

//how to create set of strings in main routine, set data element (external) so second iteration?
//if not, from a function?



main { //ilog


	function calcScore(Assignment, Disliked_Ingrs){
   		var score = 0;
   		//calculate how many disliked optional ingrs there are (sum over each item)
   		for(var i in thisOplModel.itemIDs){
   		  for(var u in thisOplModel.userIDs){
   		    if (thisOplModel.Assignment[u][i] >= 1 ){
   		      for(var ingr in thisOplModel.Items[i].OptionalIngrID){
   		         if (existsIn(ingr, Disliked_Ingrs)){
   		           score = score + 1;   		         
   		           writeln("Count <" + i + ", " + ingr + ">,");
   		         }		      
   		      }   		    
   		      break;
   		    }   		  
   		  }   		
   		}
   		return score;
	};
	function existsIn(item, array){
	  var x = 0;
	  var arr_length = array.length;
	  var exists = false;
	  while(!exists && x < arr_length){
	    if (item == array[x]){
	      exists = true;	    
	    }	  
	    x = x + 1;
	  }	
	  return exists;
	}
	
	function arrToString(array){
	  var x = 0;
	  var arr_length = array.length;	
	  while(x < arr_length){
	    write(disliked_ingrs[x] + ",");
	    x  = x + 1;	
	  }
	  writeln("");
	}
	thisOplModel.generate();
	
	cplex.solve();
	cplex.populate();
	
	if (true) {
	  var disliked_ingrs = new Array();
	  for(var udi in thisOplModel.UserDislikedIngr){
	    for(var i in thisOplModel.UserDislikedIngr[udi].dislikes_IngrID){
	      if (!existsIn(i, disliked_ingrs)){
	        disliked_ingrs[disliked_ingrs.length] = i;	      
	      }	  
	    }	
     }	  
	writeln("DislikedIngrs: ");
	arrToString(disliked_ingrs);
    

	  var nsolns = cplex.solnPoolNsolns;
	  
	  var curr_best_soln = 0;
	  var curr_min_score = calcScore(thisOplModel.Assignment, disliked_ingrs);
	  
	  var curr_score;
	  writeln("Number of solutions found = ", nsolns);
	  writeln("---------");
	  for (var s=0; s<nsolns; s++) {
        thisOplModel.setPoolSolution(s);
        writeln("solution #", s, ": objective = ", cplex.getObjValue(s));
        writeln("Assignment = [ ");
        for (var i in thisOplModel.Assignment)
          writeln(thisOplModel.Assignment[i], " ");
        writeln("]");  
        write("satisfiedUser = [ ");
        for (var i in thisOplModel.satisfiedUser)
          write(thisOplModel.satisfiedUser[i], " ");
        writeln("]"); 
        
        writeln("curr_min_score: ", curr_min_score);
        writeln("DislikedIngrs: ");
	    arrToString(disliked_ingrs);
        curr_score = calcScore(thisOplModel.Assignment[i], disliked_ingrs);
        writeln("curr_score: ", curr_score);
        if (curr_score < curr_min_score){
          curr_min_score = curr_score;
          curr_best_soln = s;        
        }
        writeln("---------");
      }
      writeln("#############");
      writeln("Best solution: ");
      writeln("curr_min_score: ", curr_min_score);
      writeln("solution #", curr_best_soln);
      thisOplModel.setPoolSolution(curr_best_soln);
        writeln("solution #", curr_best_soln, ": objective = ", cplex.getObjValue(curr_best_soln));
        writeln("Assignment = [ ");
        for (var i in thisOplModel.Assignment)
          writeln(thisOplModel.Assignment[i], " ");
        writeln("]");  
        write("satisfiedUser = [ ");
        for (var i in thisOplModel.satisfiedUser)
          write(thisOplModel.satisfiedUser[i], " ");
        writeln("]"); 
        writeln("---------");
      
      
	}
	

}

    