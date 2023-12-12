#define INIT 2
#define IS_SHOW_SYS_STATUS_ENABLE true
#define MAX (INIT * 2)

typedef Train {
    	bit vec;
    	byte pos;
};

Train trains[2];

bit mainStack[MAX + 2];
byte mainStackSize = MAX + 2;

bit deadendStack[INIT / 2 + 1];
byte deadendStackSize = 0;

bool isFinishedBool = false;

#define canMoveToDeadend(trainID, leftN, rightN) \
	(trains[trainID].pos >= 0 && trains[trainID].pos < MAX + 2) && (trains[1 - trainID].pos >= 0 && trains[1 - trainID].pos < MAX + 2) && \
		((leftN + rightN + deadendStackSize) <= (INIT / 2)) && \
		(trains[trainID].pos < trains[1 - trainID].pos -> trains[trainID].pos : trains[trainID].pos - trains[1 - trainID].pos - 1) >= leftN && \
		(trains[trainID].pos > trains[1 - trainID].pos -> mainStackSize - trains[trainID].pos - 1 : trains[1 - trainID].pos - trains[trainID].pos - 1) >= rightN


inline moveToDeadend(trainID, leftN, rightN) {
	byte i_td = 0;
	byte sum = leftN + 1 + rightN;
	do
	:: i_td < deadendStackSize -> {
		deadendStack[sum + i_td] = deadendStack[i_td];
		i_td = i_td + 1;
	   }
	:: else -> break;
	od

	i_td = 0;
	byte n_pos_td;
	if
	:: trains[trainID].vec == 0 -> {
		do
		:: i_td < sum -> {
			deadendStack[i_td] = mainStack[trains[trainID].pos - leftN + i_td];
			i_td = i_td + 1;
		   }
		:: else -> break;
		od

		i_td = 0;
		do
		:: i_td < mainStackSize - sum - (trains[trainID].pos - leftN) -> {
			mainStack[trains[trainID].pos - leftN + i_td] = mainStack[trains[trainID].pos + rightN + 1 + i_td];
			i_td = i_td + 1;
		   }
		:: else -> break;
		od

		n_pos_td = MAX + 2 + leftN;
	   }
	:: else -> {
		do
		:: i_td < sum -> {
			deadendStack[i_td] = mainStack[trains[trainID].pos + rightN - i_td];
			i_td = i_td + 1;
		   }
		:: else -> break;
		od

		i_td = 0;
		do
		:: i_td < mainStackSize - sum - (trains[trainID].pos - leftN) -> {
			mainStack[trains[trainID].pos - leftN + i_td] = mainStack[trains[trainID].pos + rightN + 1 + i_td];
			i_td = i_td + 1;
		   }
		:: else -> break;
		od

		n_pos_td = MAX + 2 + rightN;
	   }
	fi

	assert(n_pos_td >= MAX + 2 && n_pos_td < MAX + 2 + INIT / 2 + 1);
	
	if
	:: trains[1 - trainID].pos > trains[trainID].pos -> {
		trains[1 - trainID].pos = trains[1 - trainID].pos - sum;
	   }
	:: else
	fi

	trains[trainID].pos = n_pos_td;
	mainStackSize = mainStackSize - sum;
	deadendStackSize = deadendStackSize + sum;
}


#define canMoveFromDeadend(trainID, N, n_pos) \
	(n_pos >= 0 && n_pos <= mainStackSize) && (trains[trainID].pos >= MAX + 2 && trains[trainID].pos < MAX + 2 + INIT / 2 + 1) && \
	((deadendStackSize - 1) - (trains[trainID].pos - (MAX + 2))) >= N && n_pos < (MAX + 2 - N - (trains[trainID].pos - (MAX + 2)))

inline moveFromDeadend(trainID, N, n_pos) {
	assert(trains[trainID].pos >= MAX + 2 && trains[trainID].pos < MAX + 2 + INIT / 2 + 1);

	byte i_fd = 0;	
	byte sum = (trains[trainID].pos - (MAX + 2)) + N + 1;
	do
	:: i_fd < mainStackSize - n_pos -> {
		mainStack[mainStackSize + sum - 1 - i_fd] = mainStack[mainStackSize - 1 - i_fd];
		i_fd = i_fd + 1;
	   }
	:: else -> break;
	od

	i_fd = 0;
	byte n_pos_fd;	
	if
	:: trains[trainID].vec == 0 -> {
		do
		:: i_fd < sum -> {
			mainStack[n_pos + i_fd] = deadendStack[i_fd];
			i_fd = i_fd + 1;
		   }
		:: else -> break;
		od

		n_pos_fd = n_pos + (trains[trainID].pos - (MAX + 2));
	   }
	:: else -> {
		do
		:: i_fd < sum -> {
			mainStack[n_pos + i_fd] = deadendStack[sum - 1 - i_fd];
		   	i_fd = i_fd + 1;
		   }
		:: else -> break;
		od

		n_pos_fd = n_pos + N;
	   }
	fi

	i_fd = 0;
	do
	:: i_fd < deadendStackSize - sum -> {
		deadendStack[i_fd] = deadendStack[sum + i_fd];
		i_fd = i_fd + 1;	
	   }
	:: else -> break;
	od

	if
	:: trains[1 - trainID].pos > n_pos -> {
		trains[1 - trainID].pos = trains[1 - trainID].pos + sum;
	   }
	:: else
	fi

	trains[trainID].pos = n_pos_fd;
	mainStackSize = mainStackSize + sum;
	deadendStackSize = deadendStackSize - sum;	
}

#define canSwitchHeadAndTail(trainID) \
	(trains[trainID].pos >= MAX + 2 && trains[trainID].pos < MAX + 2 + INIT / 2 + 1) && deadendStackSize > 1 

inline switchHeadAndTail(trainID) {
	byte i_s = 0;
	do
	:: i_s < deadendStackSize / 2 -> {
		bit tmp = deadendStack[i_s];
		deadendStack[i_s] = deadendStack[deadendStackSize - 1 - i_s];
		deadendStack[deadendStackSize - 1 - i_s] = tmp;
		i_s = i_s + 1;
	   }
	:: else -> break;
	od
	trains[trainID].pos = (MAX + 2) + (deadendStackSize - 1 - (trains[trainID].pos - (MAX + 2)));
}

inline isFinishedCalc() {
	isFinishedBool = ((trains[0].pos == MAX + 1) && (trains[1].pos == 0));
	byte i_f = 0;
	do
	:: i_f < 2 && isFinishedBool -> {
		byte j_f = 0;
		do
		:: j_f < INIT && isFinishedBool -> {
			isFinishedBool = (isFinishedBool && (mainStack[1 + INIT * i_f + j_f] == (1 - i_f)));
			j_f = j_f + 1;
		   }
		:: else -> break;
		od
		i_f = i_f + 1;
	   }
	:: else -> break;
	od 

	if
	:: IS_SHOW_SYS_STATUS_ENABLE -> {
		printf("=====[ Positions ]=====\n");
		printf("Train-1: pos = %d\n", trains[0].pos);
		printf("Train-2: pos = %d\n", trains[1].pos);
		printf("=====[ Main ]=====\n");
		printf("mainStackSize = %d / %d\n", mainStackSize, MAX + 2);
		byte type;
		i_f = 0;
		do
		:: i_f < mainStackSize -> {
			if
			:: trains[0].pos == i_f -> { type = 101; } 
			:: trains[1].pos == i_f -> { type = 102; }
			:: mainStack[i_f] == 0 && trains[0].pos != i_f && trains[1].pos != i_f -> { type = 1; }
			:: mainStack[i_f] == 1 -> { type = 2; }
			:: else
			fi
			/*type = mainStack[i_f];*/
			printf("mainStack[%d] = %d\n", i_f, type);
			i_f = i_f + 1;
		   }
		:: else -> break;
		od

		printf("=====[ Deadend ]=====\n");
		printf("deadendStackSize = %d / %d\n", deadendStackSize, INIT / 2 + 1);
		i_f = 0;
		do
		:: i_f < deadendStackSize -> {
			if
			:: trains[0].pos == MAX + 2 + i_f -> { type = 101; } 
			:: trains[1].pos == MAX + 2 + i_f -> { type = 102; }
			:: deadendStack[i_f] == 0 && trains[0].pos != MAX + 2 + i_f && trains[1].pos != MAX + 2 + i_f -> { type = 1; }
			:: deadendStack[i_f] == 1 -> { type = 2; }
			:: else
			fi
			/*type = deadendStack[i_f];*/
			printf("deadendStack[%d] = %d\n", i_f, type);
			i_f = i_f + 1;
		   }
		:: else -> break;
		od
		printf("=======================\n\n");
	   }
	:: else
	fi
}

active proctype runTask() {
	trains[0].vec = 0;
	trains[0].pos = INIT;

	trains[1].vec = 1;
	trains[1].pos = INIT + 1;

	byte i_run = 0;
        do
        :: i_run < 2 -> {
                byte j_run = 0;
                do 
                :: j_run < INIT -> {
                	mainStack[INIT * i_run + 2 * i_run + j_run] = i_run;
                	j_run = j_run + 1;
                   }
                :: else -> break
                od
                i_run = i_run + 1;
           }
        :: else -> break
        od

        /*
        mainStack[INIT] = 101;
        mainStack[INIT + 1] = 102;
        */

        bit trainID = 0;
        byte t1 = 0;
        byte t2 = 0;
        byte max = MAX + 1;

        do
        :: canMoveToDeadend(trainID, t1, t2) -> atomic { 
        	printf("moveToDeadend(%d, %d, %d)\n", trainID, t1, t2);
        	moveToDeadend(trainID, t1, t2);
        	isFinishedCalc();
           }
        :: canMoveFromDeadend(trainID, t1, t2) -> atomic { 
        	printf("moveFromDeadend(%d, %d, %d)\n", trainID, t1, t2);
        	moveFromDeadend(trainID, t1, t2);
        	isFinishedCalc();
           }
        :: canSwitchHeadAndTail(trainID) -> atomic {
        	printf("switchHeadAndTail(%d)\n", trainID);
        	switchHeadAndTail(trainID);
        	isFinishedCalc();
           }
        :: t1 > 0 -> atomic {
        	t1 = t1 - 1;
           }
        :: t1 < max -> atomic {
        	t1 = t1 + 1;
           }
        :: t2 > 0 -> atomic {
        	t2 = t2 - 1;
           }
        :: t2 < max -> atomic {
        	t2 = t2 + 1;
           }
        :: true -> {
        	trainID = 1 - trainID;
           }
        od
}


ltl solution {
        !<>(isFinishedBool)
}