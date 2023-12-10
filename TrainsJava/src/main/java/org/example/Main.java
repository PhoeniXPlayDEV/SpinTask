package org.example;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class Main {

    private static Location loc_0, loc_1, loc_2, loc_3, loc_4;
    private static Train train_1, train_2;

    public static void main(String[] args) {
        loc_0 = new Location(0);
        loc_1 = new Location(1);
        loc_2 = new Location(2);
        loc_3 = new Location(3);
        loc_4 = new Location(4);

        loc_0.setNextLocation(loc_1);
        loc_1.setPrevLocation(loc_0);
        loc_1.setNextLocation(loc_3);
        loc_3.setPrevLocation(loc_1);
        loc_3.setNextLocation(loc_4);
        loc_4.setPrevLocation(loc_3);

        train_1 = new Train(1, loc_0, Directions.RIGHT, 2);
        train_2 = new Train(2, loc_4, Directions.LEFT, 2);

        int i = 0;
        String cmd = "";
        try(BufferedReader in = new BufferedReader(new InputStreamReader(System.in))) {
            while(true) {
                cmd = in.readLine().trim();
                if(cmd.equals("q")) break;
                i++;

                switch (cmd) {
                    case "moveToDeadend_U(0)" -> moveToDeadendCmd(train_1);
                    case "moveToDeadend_U(1)" -> moveToDeadendCmd(train_2);

                    case "moveFromDeadend(0, 0)" -> train_1.moveFromDeadend(loc_1, Directions.LEFT);
                    case "moveFromDeadend(0, 1)" -> train_1.moveFromDeadend(loc_3, Directions.RIGHT);
                    case "moveFromDeadend(1, 0)" -> train_2.moveFromDeadend(loc_1, Directions.LEFT);
                    case "moveFromDeadend(1, 1)" -> train_2.moveFromDeadend(loc_3, Directions.RIGHT);

                    case "doStepsMove(0, 0)" -> train_1.stepsMove(Directions.LEFT);
                    case "doStepsMove(0, 1)" -> train_1.stepsMove(Directions.RIGHT);
                    case "doStepsMove(1, 0)" -> train_2.stepsMove(Directions.LEFT);
                    case "doStepsMove(1, 1)" -> train_2.stepsMove(Directions.RIGHT);

                    case "disconnectCars(0, 0, 1)" -> train_1.disconnectRailcar(Directions.LEFT);
                    case "disconnectCars(0, 1, 1)" -> train_1.disconnectRailcar(Directions.RIGHT);
                    case "disconnectCars(1, 0, 1)" -> train_2.disconnectRailcar(Directions.LEFT);
                    case "disconnectCars(1, 1, 1)" -> train_2.disconnectRailcar(Directions.RIGHT);

                    case "connectCars(0, 0, 1)", "doSpecialConnection(0, 0, 1)" -> train_1.connectRailcar(Directions.LEFT);
                    case "connectCars(0, 1, 1)", "doSpecialConnection(0, 1, 1)" -> train_1.connectRailcar(Directions.RIGHT);
                    case "connectCars(1, 0, 1)", "doSpecialConnection(1, 0, 1)" -> train_2.connectRailcar(Directions.LEFT);
                    case "connectCars(1, 1, 1)", "doSpecialConnection(1, 1, 1)" -> train_2.connectRailcar(Directions.RIGHT);

                    case "status" -> {
                        showTrainStatus(train_1);
                        showTrainStatus(train_2);
                        showLocsStatus();
                    }

                    case "trainsStatus" -> {
                        showTrainStatus(train_1);
                        showTrainStatus(train_2);
                    }

                    case "locsStatus" -> showLocsStatus();
                }

                if(isTaskSolved()) {
                    System.out.println("Task solved!");
                    break;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (TrainActionException tae) {
            System.out.println();
            System.out.println("Ошибка после действия на " + i + " строке: " + cmd);
            tae.printStackTrace();
            showTrainStatus(train_1);
            showTrainStatus(train_2);
        }
    }

    public static void showLocsStatus() {
        Location[] locs = {loc_0, loc_1, loc_2, loc_3, loc_4};
        for(Location loc : locs) {
            System.out.println(loc.toString());
        }
    }

    public static void showTrainStatus(Train train) {
        System.out.printf("Train-%d: currLoc = %d, behind = %d [%s], ahead = %d [%s], vec = %s\n",
                train.getId(),
                train.getCurrLoc().getId(),
                train.getBehind().size(),
                String.join(", ", train.getBehind().stream().map(railcar -> String.valueOf(railcar.getId())).toList()),
                train.getAhead().size(),
                String.join(", ", train.getAhead().stream().map(railcar -> String.valueOf(railcar.getId())).toList()),
                train.getVec().name());
    }

    public static void moveToDeadendCmd(Train train) throws TrainActionException {
        Location currLoc = train.getCurrLoc();
        if(currLoc.getId() == 2) {
            throw new RuntimeException("Train already in the deadend!");
        } else if(currLoc.getId() == 0) {
            train.oneStepMove(Directions.RIGHT);
            train.moveToDeadend(loc_2, Directions.RIGHT, 1);
        } else if(currLoc.getId() == 1) {
            train.moveToDeadend(loc_2, Directions.RIGHT, 1);
        } else if(currLoc.getId() == 4) {
            train.oneStepMove(Directions.LEFT);
            train.moveToDeadend(loc_2, Directions.LEFT, 1);
        } else if(currLoc.getId() == 3) {
            train.moveToDeadend(loc_2, Directions.LEFT, 1);
        }
    }

    public static boolean isTaskSolved() {
        boolean res = train_1.getCurrLoc().getId() == 4 && train_2.getCurrLoc().getId() == 0;
        res = res && train_1.getBehind().size() == 2 && train_1.getAhead().isEmpty();
        res = res && train_2.getBehind().size() == 2 && train_2.getAhead().isEmpty();
        res = res && train_1.getBehind().stream().allMatch(railcar -> railcar.getId() == 1);
        res = res && train_2.getBehind().stream().allMatch(railcar -> railcar.getId() == 2);
        return res;
    }

}