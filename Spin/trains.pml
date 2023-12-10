#define IS_MSG_ENABLE false
#define IS_ASSERT_FINDER false
#define INIT_CARS_FOR_ONE_TRAIN 2
#define MAX_CARS_IN_ONE_SIDE INIT_CARS_FOR_ONE_TRAIN * 2
#define MAX_CARS_FOR_ONE_TRAIN MAX_CARS_IN_ONE_SIDE * 2
#define GROUP_OF_CARS INIT_CARS_FOR_ONE_TRAIN / 2

#define calcTrainPosByDir(trainID, dir) (trainsPos[trainID] == 0 -> dir : 1 - dir)
#define dir_conv(dir) (dir == 0 -> -1 : 1)

short trainsLocs[2] = {0, 4};
/* was bit */
byte trainsPos[2] = {0, 1};
byte trainsCarsNum[4] = {INIT_CARS_FOR_ONE_TRAIN, 0, INIT_CARS_FOR_ONE_TRAIN, 0};
/* was byte */
byte trainsCarsStacks[MAX_CARS_FOR_ONE_TRAIN * 2];
byte carsInLocs[10];
/* was byte */
byte carsLocsStacks[MAX_CARS_FOR_ONE_TRAIN * 5];
byte lastAction = 0;



inline disconnectOneCar_T(trainID, loc, dir, pos) {
	if
	:: IS_MSG_ENABLE -> printf("Train-%d starting disconnection (loc = %d; dir = %d; pos = %d; behind = %d; ahead = %d)\n", 
		trainID + 1, loc, dir, pos, trainsCarsNum[trainID * 2], trainsCarsNum[trainID * 2 + 1]);
	:: else
	fi

	/* trainsCarsStacks_idx_1 - the index where contains the car type at the end of stack (first car in the head || last car in the tail) */
	int trainsCarsStacks_idx_1 = trainID * MAX_CARS_FOR_ONE_TRAIN + pos * MAX_CARS_IN_ONE_SIDE + trainsCarsNum[trainID * 2 + pos] - 1;

	/* was byte */
	byte carType_1 = trainsCarsStacks[trainsCarsStacks_idx_1];
	/* was int */
	byte newCarsNumInLoc_1 = carsInLocs[loc * 2 + dir] + 1;

	/* carsLocsStacks_idx_1[1600] - the index where car will be left on the railway */
	int carsLocsStacks_idx_1 = loc * MAX_CARS_FOR_ONE_TRAIN + dir * MAX_CARS_IN_ONE_SIDE + newCarsNumInLoc_1 - 1;

	trainsCarsNum[trainID * 2 + pos] = trainsCarsNum[trainID * 2 + pos] - 1;
	trainsCarsStacks[trainsCarsStacks_idx_1] = 0;
	
	carsInLocs[loc * 2 + dir] = newCarsNumInLoc_1;
	carsLocsStacks[carsLocsStacks_idx_1] = carType_1;

	if
	:: IS_MSG_ENABLE -> printf("\nTrain-%d disconnected 1 car (loc = %d; dir = %d; pos = %d; car type = %d; behind = %d; ahead = %d; trainsPos = %d)\n", 
		trainID + 1, loc, dir, pos, carType_1, trainsCarsNum[trainID * 2], trainsCarsNum[trainID * 2 + 1], trainsPos[trainID]);
	:: else
	fi

	assert(carType_1 == 1 || carType_1 == 2);
}

inline connectOneCar_T(trainID, loc, dir, pos, isReverse) {
	byte dir_crt = dir;

	if
	:: IS_MSG_ENABLE -> printf("Train-%d starting connection (loc = %d; dir = %d; pos = %d; behind = %d; ahead = %d)\n", 
		trainID + 1, loc, dir_crt, pos, trainsCarsNum[trainID * 2], trainsCarsNum[trainID * 2 + 1]);
	:: else
	fi

	/* was byte */
	byte carType_2;
	/* was int */
	byte oldCarsNumInLoc_1 = carsInLocs[loc * 2 + dir_crt];

	/* was int */
	int tmp = loc * MAX_CARS_FOR_ONE_TRAIN + dir_crt * MAX_CARS_IN_ONE_SIDE;
	int carsLocsStacks_idx_2 = tmp + oldCarsNumInLoc_1 - 1;

	/* trainsCarsStacks_idx_2 - the index where car will be added to the train */
	int trainsCarsStacks_idx_2 = trainID * MAX_CARS_FOR_ONE_TRAIN + pos * MAX_CARS_IN_ONE_SIDE + trainsCarsNum[trainID * 2 + pos];

	carsInLocs[loc * 2 + dir_crt] = oldCarsNumInLoc_1 - 1;

	if
	:: isReverse -> { 
		carType_2 = carsLocsStacks[tmp];
		/* was int */
		int k = 1;
		do
		:: if 
		   :: k < oldCarsNumInLoc_1 -> {
				carsLocsStacks[tmp + k - 1] = carsLocsStacks[tmp + k]; 
				k = k + 1;  			
		      }
		   :: else -> break;
		   fi
		od
	   }
	:: else -> { 
		carType_2 = carsLocsStacks[carsLocsStacks_idx_2]; 
	   }
	fi

	carsLocsStacks[carsLocsStacks_idx_2] = 0;

	trainsCarsNum[trainID * 2 + pos] = trainsCarsNum[trainID * 2 + pos] + 1;
	trainsCarsStacks[trainsCarsStacks_idx_2] = carType_2;

	if
	:: IS_MSG_ENABLE -> printf("\nTrain-%d connected 1 car (loc = %d; dir = %d; pos = %d; car type = %d; behind = %d; ahead = %d)\n", 
		trainID + 1, loc, dir_crt, pos, carType_2, trainsCarsNum[trainID * 2], trainsCarsNum[trainID * 2 + 1]);
	:: else
	fi

	assert(carType_2 == 1 || carType_2 == 2);
}

#define canDisconnectCars(trainID, dir, n) trainsCarsNum[trainID * 2 + calcTrainPosByDir(trainID, dir)] >= n && \
	(trainsLocs[trainID] != 2 || dir == 1) && (trainsLocs[trainID] != 1 || dir == 0)  && (trainsLocs[trainID] != 3 || dir == 1)
#define canConnectCars(trainID, dir, n) carsInLocs[trainsLocs[trainID] * 2 + dir] >= n

inline disconnectCars_U(trainID, loc, dir, pos, m) {
	/* was int */
	int i_dc = 0;
	do
	:: i_dc < m -> {
		disconnectOneCar_T(trainID, loc, dir, pos);
		i_dc = i_dc + 1;
	   }
	:: else -> break
	od
}

inline connectCars_U(trainID, loc, dir, pos, m, isReverse) {
	/* was int */
	int i_cc = 0;
	do
	:: i_cc < m -> {
		connectOneCar_T(trainID, loc, dir, pos, isReverse);
		i_cc = i_cc + 1;
	   }
	:: else -> break
	od
}

inline disconnectCars(trainID, dir, n_disconnectCars) {
	assert(canDisconnectCars(trainID, dir, n_disconnectCars));
	byte pos_disconnectCars = calcTrainPosByDir(trainID, dir);
	short loc_disconnectCars = trainsLocs[trainID]; 
	disconnectCars_U(trainID, loc_disconnectCars, dir, pos_disconnectCars, n_disconnectCars);			
}

inline connectCars(trainID, dir, n_connectCars) {
	assert(canConnectCars(trainID, dir, n_connectCars));
	byte pos_connectCars = calcTrainPosByDir(trainID, dir);
	short loc_connectCars = trainsLocs[trainID]; 
	connectCars_U(trainID, loc_connectCars, dir, pos_connectCars, n_connectCars, false);			
}

#define canDoSpecialConnection(trainID, dir, n_canDoSpecialConnection) (((trainsLocs[trainID] == 1 && dir == 0) || (trainsLocs[trainID] == 3 && dir == 1)) && \
	(carsInLocs[trainsLocs[trainID] * 2 + dir] == 0) && (carsInLocs[(trainsLocs[trainID] + dir_conv(dir)) * 2 + (1 - dir)] >= n_canDoSpecialConnection))

inline doSpecialConnection(trainID, dir, n_doSpecialConnection) {
	byte pos_doSpecialConnection = calcTrainPosByDir(trainID, dir);
	short newLoc_doSpecialConnection = trainsLocs[trainID] + dir_conv(dir);
	connectCars_U(trainID, newLoc_doSpecialConnection, 1 - dir, pos_doSpecialConnection, n_doSpecialConnection, true);	
}





#define canDoOneStepMove(trainID, dir) \
        (trainsLocs[trainID] + dir_conv(dir) >= 0 && trainsLocs[trainID] + dir_conv(dir) <= 4 && trainsLocs[trainID] != 2) && \
        ((trainsLocs[trainID] + dir_conv(dir) != 2 && trainsLocs[1 - trainID] != trainsLocs[trainID] + dir_conv(dir)) || \
        (trainsLocs[trainID] + dir_conv(dir) == 2 && trainsLocs[1 - trainID] != trainsLocs[trainID] + 2 * dir_conv(dir)))

inline doOneStepMove(trainID, dir) {
	assert(dir == 0 || dir == 1);

	/* was int */
	short oldLoc = trainsLocs[trainID];
	int dir_tmp = dir_conv(dir);

	assert((oldLoc + dir_tmp >= 0 && oldLoc + dir_tmp <= 4) &&
		 ((oldLoc + dir_tmp != 2 && trainsLocs[1 - trainID] != oldLoc + dir_tmp) ||
		 (oldLoc + dir_tmp == 2 && trainsLocs[1 - trainID] != oldLoc + 2 * dir_tmp))
	);


	/* was int */
	short newLoc;
	if
	:: oldLoc + dir_tmp != 2 ->  {
			  newLoc = oldLoc + dir_tmp;
	   }
	:: else ->  { newLoc = oldLoc + 2 * dir_tmp }
	fi

	/* was bit */
	byte dir_m = dir;
	/* was bit */
	byte pos_m = calcTrainPosByDir(trainID, dir_m);

	if
	:: IS_MSG_ENABLE -> printf("Train-%d start moving from the loc-%d to the loc-%d (dir = %d; trainPos = %d)\n[[[\n", trainID + 1, oldLoc, newLoc, dir_m, trainsPos[trainID]);
	:: else
	fi

	/*printf("[!] Loc-%d | car on the left = %d | cars on the right = %d\n", oldLoc, carsInLocs[oldLoc * 2], carsInLocs[oldLoc * 2 + 1]);*/

	/* was int */
	byte n = carsInLocs[oldLoc * 2 + dir_m];
	if
	:: n > 0 -> { connectCars_U(trainID, oldLoc, dir_m, pos_m, n, false); }
	:: else
	fi

	dir_m = 1 - dir_m;

	/*printf("[!] Loc-%d | car on the left = %d | cars on the right = %d\n", newLoc, carsInLocs[newLoc * 2], carsInLocs[newLoc * 2 + 1]);*/

	n = carsInLocs[newLoc * 2 + dir_m];
	if
	:: n > 0 -> { connectCars_U(trainID, newLoc, dir_m, pos_m, n, true); }
	:: else
	fi

	if
        :: IS_MSG_ENABLE -> printf("]]]\nTrain-%d moved from the loc-%d to the loc-%d (pos = %d; trainsPos = %d)\n", trainID + 1, oldLoc, newLoc, pos_m, trainsPos[trainID]);
        :: else
        fi
        trainsLocs[trainID] = newLoc;
}

inline doStepsMove(trainID, dir) {
	assert(dir == 0 || dir == 1);
	do
        :: canDoOneStepMove(trainID, dir) -> {
        	doOneStepMove(trainID, dir);
           }
        :: else -> break;
        od
}







#define canMoveToDeadend(trainID) \
	(trainsLocs[trainID] == 1 || trainsLocs[trainID] == 3) && trainsLocs[0] != 2 && trainsLocs[1] != 2 && (carsInLocs[4] + carsInLocs[5] + trainsCarsNum[trainID * 2 + 0] + \
                trainsCarsNum[trainID * 2 + 1] + (trainsLocs[trainID] == 1 -> carsInLocs[1 * 2 + 1] : carsInLocs[3 * 2 + 0]) <= GROUP_OF_CARS)

inline moveToDeadend(trainID) {
	assert(canMoveToDeadend(trainID));

    if
    :: IS_MSG_ENABLE -> printf("\nTrain-%d start moving to deadend (loc = %d; ahead = %d, behind = %d)\n[[[\n",
		trainID + 1, trainsLocs[trainID], trainsCarsNum[trainID * 2 + 1], trainsCarsNum[trainID * 2]);
	:: else
	fi

	short oldLoc_td = trainsLocs[trainID];
	short newLoc_td = 2;
	/* was bit */
	byte dir_td;
	if
	:: (oldLoc_td == 1) ->  { dir_td = 1; }
	:: else ->  { dir_td = 0; }
	fi

	/* was bit */
	byte pos_td = calcTrainPosByDir(trainID, dir_td);

	byte n_td = carsInLocs[oldLoc_td * 2 + dir_td];
	if
	:: n_td > 0 -> { connectCars_U(trainID, oldLoc_td, dir_td, pos_td, n_td, false); }
	:: else
	fi

	if
	:: dir_td == 1 && trainsPos[trainID] == 0 -> { pos_td = 1; trainsPos[trainID] = 0; }
	:: dir_td == 1 && trainsPos[trainID] == 1 -> { pos_td = 0; trainsPos[trainID] = 1; }
	:: dir_td == 0 && trainsPos[trainID] == 0 -> { pos_td = 0; trainsPos[trainID] = 1; }
	:: dir_td == 0 && trainsPos[trainID] == 1 -> { pos_td = 1; trainsPos[trainID] = 0; }
	:: else
	fi

	n_td = carsInLocs[newLoc_td * 2 + 0];
	if
	:: n_td > 0 -> { connectCars_U(trainID, newLoc_td, 0, pos_td, n_td, true); }
	:: else
	fi

	if
	:: IS_MSG_ENABLE -> printf("]]]\nTrain-%d moved from the loc-%d to the deadend (pos = %d; trainsPos = %d)\n", 
		trainID + 1, oldLoc_td, pos_td, trainsPos[trainID]);
	:: else
	fi
	trainsLocs[trainID] = newLoc_td;
}

#define S(trainID) trainsCarsNum[trainID * 2 + 0] + trainsCarsNum[trainID * 2 + 1] + carsInLocs[2 * 2 + 0] + carsInLocs[2 * 2 + 1]
#define S1(trainID) (S(trainID) + carsInLocs[1 * 2 + 1]) <= GROUP_OF_CARS
#define S0(trainID) ((S(trainID) + carsInLocs[0 * 2 + 1] + carsInLocs[1 * 2 + 0] + carsInLocs[1 * 2 + 1]) <= GROUP_OF_CARS) && trainsLocs[1 - trainID] != 1
#define S3(trainID) (S(trainID) + carsInLocs[3 * 2 + 0]) <= GROUP_OF_CARS
#define S4(trainID) ((S(trainID) + carsInLocs[4 * 2 + 0] + carsInLocs[3 * 2 + 1] + carsInLocs[3 * 2 + 0]) <= GROUP_OF_CARS) && trainsLocs[1 - trainID] != 3

#define canMoveToDeadend_U(trainID) \
	trainsLocs[0] != 2 && trainsLocs[1] != 2 && \
	(trainsLocs[trainID] != 0 || S0(trainID)) && (trainsLocs[trainID] != 1 || S1(trainID)) && \
	(trainsLocs[trainID] != 3 || S3(trainID)) && (trainsLocs[trainID] != 4 || S4(trainID))

inline moveToDeadend_U(trainID) {
	assert(canMoveToDeadend_U(trainID));
	short currLoc = trainsLocs[trainID];
	if
	:: currLoc == 0 -> {
		doOneStepMove(trainID, 1);
	   }
	:: currLoc == 4 -> {
		doOneStepMove(trainID, 0);
	   }
	:: else
	fi

	moveToDeadend(trainID);
}






#define canMoveFromDeadend(trainID, dir) trainsLocs[trainID] == 2 && trainsLocs[1 - trainID] != trainsLocs[trainID] + (dir == 0 -> -1 : 1)

inline moveFromDeadend(trainID, dir) {
	if
	:: IS_MSG_ENABLE -> printf("\nTrain-%d start moving from the deadend (loc = %d; ahead = %d, behind = %d)\n[[[\n",
		trainID + 1, trainsLocs[trainID], trainsCarsNum[trainID * 2 + 1], trainsCarsNum[trainID * 2]);
	:: else
	fi

	short oldLoc_fd = 2;
	short newLoc_fd = 2 + (dir == 0 -> -1 : 1);
	byte dir_fd = dir;
	/* was bit */
	byte pos_fd;
	if
	:: trainsPos[trainID] == 1 && dir_fd == 0 -> { pos_fd = 1; trainsPos[trainID] = 1; }
	:: trainsPos[trainID] == 1 && dir_fd == 1 -> { pos_fd = 1; trainsPos[trainID] = 0; }
	:: trainsPos[trainID] == 0 && dir_fd == 0 -> { pos_fd = 0; trainsPos[trainID] = 0; }
	:: trainsPos[trainID] == 0 && dir_fd == 1 -> { pos_fd = 0; trainsPos[trainID] = 1; }
	:: else
	fi

	byte n_fd = carsInLocs[oldLoc_fd * 2 + 0];
	if
	:: n_fd > 0 -> { connectCars_U(trainID, oldLoc_fd, 0, pos_fd, n_fd, false); }
	:: else
	fi
	
	pos_fd = calcTrainPosByDir(trainID, dir_fd);
	dir_fd = 1 - dir_fd;

	n_fd = carsInLocs[newLoc_fd * 2 + dir_fd];
	if
	:: n_fd > 0 -> { connectCars_U(trainID, newLoc_fd, dir_fd, pos_fd, n_fd, true); }
	:: else
	fi

	if
	:: IS_MSG_ENABLE -> printf("]]]\nTrain-%d moved from the deadend to the loc-%d (pos = %d; trainsPos = %d)\n", 
		trainID + 1, newLoc_fd, pos_fd, trainsPos[trainID]);
	:: else
	fi
	trainsLocs[trainID] = newLoc_fd;

	if
	:: canDoOneStepMove(trainID, dir) -> { doStepsMove(trainID, dir); }
	:: else
	fi
}









bool isTrainFixed[2] = {false, false};
bool isCarsInTheirPosBoolArr[2] = {true, true};

inline printCarsLocsStacks() {
	int i_p = 0;
	do
	:: i_p < 5 -> {
		int j_p = 0;
		do
		:: j_p < 2 -> {
			int k_p = 0;
			do
			:: k_p < MAX_CARS_IN_ONE_SIDE -> {
				int idx = i_p * MAX_CARS_FOR_ONE_TRAIN + j_p * MAX_CARS_IN_ONE_SIDE + k_p;
				printf("%d:%d ", idx, carsLocsStacks[idx]);
				k_p = k_p + 1;
			   }
			:: else -> break;
			od
			j_p = j_p + 1;
			printf("| ");
		   }
		:: else -> break;
		od
		i_p = i_p + 1;
		printf("\n");
	   }
	:: else -> break;
	od
}

inline isCarsInTheirPos(trainID) {
	isCarsInTheirPosBoolArr[trainID] = (trainsCarsNum[trainID * 2] == INIT_CARS_FOR_ONE_TRAIN && trainsCarsNum[trainID * 2 + 1] == 0);
	if
	:: (isCarsInTheirPosBoolArr[trainID] == false) -> { goto Exit; } 
	:: else
	fi

	int j_c = 0;
	do
	:: j_c < INIT_CARS_FOR_ONE_TRAIN -> {
		if
		:: trainsCarsStacks[MAX_CARS_FOR_ONE_TRAIN * trainID + j_c] != trainID + 1 -> { 
			isCarsInTheirPosBoolArr[trainID] = false;
			goto Exit; 
		   }
		:: else
		fi
		j_c = j_c + 1;
	   }
	:: else -> break
	od

	Exit:;
}

inline isAllCarsInTheirPos() {
	isCarsInTheirPos(0);
	isCarsInTheirPos(1);
	
	int i_c = 0;
	do
	:: i_c < 2 -> {
		if
		:: isTrainFixed[i_c] == false -> {
			/* printf("Train-%d: isCarsInTheirPosBoolArr[i_c] = %d, %d %d"); */
			isTrainFixed[i_c] = (isCarsInTheirPosBoolArr[i_c] && carsInLocs[(1 - i_c) * 9] == 0 && 
				(i_c != 0 || trainsLocs[i_c] == 4) && (i_c != 1 || trainsLocs[i_c] == 0));
			if
			:: isTrainFixed[i_c] && IS_MSG_ENABLE -> {
				printf("Train-%d is fixed!\n", i_c + 1);
			   }
			:: else
			fi
		   } 
		:: else
		fi
		i_c = i_c + 1;
	   }
	:: else -> break;
	od

	if
	:: IS_ASSERT_FINDER -> { assert(!(isTrainFixed[0] && isTrainFixed[1])); }
	:: else
	fi
}

active proctype runTask() {
	/* Initialize trainsCarsStacks array */
	/* was int */
	int i_run = 0;
        do
        :: i_run < 2 -> {
                int j_run = 0;
                do 
                :: j_run < INIT_CARS_FOR_ONE_TRAIN -> {
                                trainsCarsStacks[MAX_CARS_FOR_ONE_TRAIN * i_run + j_run] = i_run + 1;
                                j_run = j_run + 1;
                   }
                :: else -> break
                od
                i_run = i_run + 1;
           }
        :: else -> break
        od


        bool isRand = true;


        /* Do elementary actions */
        if
        :: isRand -> {
	        do
	        :: (canMoveToDeadend_U(0) && !isTrainFixed[0]) -> atomic { 
	        	printf("moveToDeadend_U(0)\n");
	        	moveToDeadend_U(0); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 0; 
	           }
	        :: (canMoveToDeadend_U(1) && !isTrainFixed[1]) -> atomic { 
	        	printf("moveToDeadend_U(1)\n");
	        	moveToDeadend_U(1); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 0; 
	           }



	        :: (canMoveFromDeadend(0, 0) && !isTrainFixed[0] && lastAction != 1) -> atomic { 
	        	printf("moveFromDeadend(0, 0)\n");
	        	moveFromDeadend(0, 0); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 0; 
	           }
	        :: (canMoveFromDeadend(0, 1) && !isTrainFixed[0] && lastAction != 2) -> atomic { 
	        	printf("moveFromDeadend(0, 1)\n");
	        	moveFromDeadend(0, 1); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 0; 
	           }
	        :: (canMoveFromDeadend(1, 0) && !isTrainFixed[1] && lastAction != 3) -> atomic { 
	        	printf("moveFromDeadend(1, 0)\n");
	        	moveFromDeadend(1, 0); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 0; 
	           }
	        :: (canMoveFromDeadend(1, 1) && !isTrainFixed[1] && lastAction != 4) -> atomic { 
	        	printf("moveFromDeadend(1, 1)\n");
	        	moveFromDeadend(1, 1); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 0; 
	           }



	        :: (canDoOneStepMove(0, 0) && !isTrainFixed[0] && lastAction != 10) -> atomic { 
	        	printf("doStepsMove(0, 0)\n");
	        	doStepsMove(0, 0); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 0; 
	           }
	        :: (canDoOneStepMove(0, 1) && !isTrainFixed[0] && lastAction != 9) -> atomic { 
	        	printf("doStepsMove(0, 1)\n");
	        	doStepsMove(0, 1); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 0; 
	           }
	        :: (canDoOneStepMove(1, 0) && !isTrainFixed[1] && lastAction != 12) -> atomic { 
	        	printf("doStepsMove(1, 0)\n");
	        	doStepsMove(1, 0); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 0; 
	           }
	        :: (canDoOneStepMove(1, 1) && !isTrainFixed[1] && lastAction != 11) -> atomic { 
	        	printf("doStepsMove(1, 1)\n");
	        	doStepsMove(1, 1); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 0; 
	           }



	        :: (canDisconnectCars(0, 0, GROUP_OF_CARS) && !isTrainFixed[0] && lastAction != 17 && lastAction != 21) -> atomic { 
	        	printf("disconnectCars(0, 0, %d)\n", GROUP_OF_CARS);
	        	disconnectCars(0, 0, GROUP_OF_CARS); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 13; 
	           }
	        :: (canDisconnectCars(0, 1, GROUP_OF_CARS) && !isTrainFixed[0] && lastAction != 18 && lastAction != 22) -> atomic { 
	        	printf("disconnectCars(0, 1, %d)\n", GROUP_OF_CARS);
	        	disconnectCars(0, 1, GROUP_OF_CARS); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 14; 
	           }
	        :: (canDisconnectCars(1, 0, GROUP_OF_CARS) && !isTrainFixed[1] && lastAction != 19 && lastAction != 23) -> atomic { 
	        	printf("disconnectCars(1, 0, %d)\n", GROUP_OF_CARS);
	        	disconnectCars(1, 0, GROUP_OF_CARS); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 15; 
	           }
	        :: (canDisconnectCars(1, 1, GROUP_OF_CARS) && !isTrainFixed[1] && lastAction != 20 && lastAction != 24) -> atomic { 
	        	printf("disconnectCars(1, 1, %d)\n", GROUP_OF_CARS);
	        	disconnectCars(1, 1, GROUP_OF_CARS); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 16; 
	           }



	        :: (canConnectCars(0, 0, GROUP_OF_CARS) && !isTrainFixed[0] && lastAction != 13) -> atomic { 
	        	printf("connectCars(0, 0, %d)\n", GROUP_OF_CARS);
	        	connectCars(0, 0, GROUP_OF_CARS); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 17; 
	           }
	        :: (canConnectCars(0, 1, GROUP_OF_CARS) && !isTrainFixed[0] && lastAction != 14) -> atomic { 
	        	printf("connectCars(0, 1, %d)\n", GROUP_OF_CARS);
	        	connectCars(0, 1, GROUP_OF_CARS); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 18; 
	           }
	        :: (canConnectCars(1, 0, GROUP_OF_CARS) && !isTrainFixed[1] && lastAction != 15) -> atomic { 
	        	printf("connectCars(1, 0, %d)\n", GROUP_OF_CARS);
	        	connectCars(1, 0, GROUP_OF_CARS); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 19; 
	           }
	        :: (canConnectCars(1, 1, GROUP_OF_CARS) && !isTrainFixed[1] && lastAction != 16) -> atomic { 
	        	printf("connectCars(1, 1, %d)\n", GROUP_OF_CARS);
	        	connectCars(1, 1, GROUP_OF_CARS); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 20; 
	           }



	        :: (canDoSpecialConnection(0, 0, GROUP_OF_CARS) && !isTrainFixed[0] && lastAction != 13) -> atomic { 
	        	printf("doSpecialConnection(0, 0, %d)\n", GROUP_OF_CARS);
	        	doSpecialConnection(0, 0, GROUP_OF_CARS); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 21; 
	           }
	        :: (canDoSpecialConnection(0, 1, GROUP_OF_CARS) && !isTrainFixed[0] && lastAction != 14) -> atomic { 
	        	printf("doSpecialConnection(0, 1, %d)\n", GROUP_OF_CARS);
	        	doSpecialConnection(0, 1, GROUP_OF_CARS); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 22; 
	           }
	        :: (canDoSpecialConnection(1, 0, GROUP_OF_CARS) && !isTrainFixed[1] && lastAction != 15) -> atomic { 
	        	printf("doSpecialConnection(1, 0, %d)\n", GROUP_OF_CARS);
	        	doSpecialConnection(1, 0, GROUP_OF_CARS); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 23; 
	           }
	        :: (canDoSpecialConnection(1, 1, GROUP_OF_CARS) && !isTrainFixed[1] && lastAction != 16) -> atomic { 
	        	printf("doSpecialConnection(1, 1, %d)\n", GROUP_OF_CARS);
	        	doSpecialConnection(1, 1, GROUP_OF_CARS); 
	        	isAllCarsInTheirPos(); 
	        	lastAction = 24; 
	           }
	        /*:: else -> { 
	        	printf("No any actions!\n");
	        	break;
	           }*/
	        od
	}
	:: else
	fi


	/*
	printf("\nTrain-1:\n %d %d %d %d\n%d %d %d %d\n\n", 
                trainsCarsStacks[0], trainsCarsStacks[1], trainsCarsStacks[2], trainsCarsStacks[3],
                trainsCarsStacks[4], trainsCarsStacks[5], trainsCarsStacks[6], trainsCarsStacks[7]);
        printf("Train-2:\n %d %d %d %d\n%d %d %d %d\n", 
                trainsCarsStacks[8], trainsCarsStacks[9], trainsCarsStacks[10], trainsCarsStacks[11],
                trainsCarsStacks[12], trainsCarsStacks[13], trainsCarsStacks[14], trainsCarsStacks[15]);
        printf("\nTrain-1: loc = %d, behind = %d, ahead = %d, trainsPos = %d\n", trainsLocs[0], trainsCarsNum[0], trainsCarsNum[1], trainsPos[0]);
        printf("Train-2: loc = %d, behind = %d, ahead = %d, trainsPos = %d\n", trainsLocs[1], trainsCarsNum[2], trainsCarsNum[3], trainsPos[1]);
        printf("(0,0):%d (0,1):%d (1,0):%d (1,1):%d (2,0):%d (2,1):%d (3,0):%d (3,1):%d (4,0):%d (4,1):%d\n", carsInLocs[0], carsInLocs[1], carsInLocs[2], carsInLocs[3],
		carsInLocs[4], carsInLocs[5], carsInLocs[6], carsInLocs[7], carsInLocs[8], carsInLocs[9]);
	printCarsLocsStacks();
	printf("================================================\n\n");
	*/
}



ltl solution {
        !<>(isTrainFixed[0] && isTrainFixed[1])
}