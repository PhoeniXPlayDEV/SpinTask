package org.example;

import java.util.LinkedList;

public class Train {

    private final int id;
    private Directions vec;
    private LinkedList<Railcar> behind = new LinkedList<>();
    private LinkedList<Railcar> ahead = new LinkedList<>();
    private Location currLoc;
    public Train(int id, Location loc, Directions dir, int railcarsInitAmount) {
        this.id = id;
        this.currLoc = loc;
        loc.setOccupied(true);
        this.vec = dir;
        for(int i = 0; i < railcarsInitAmount; i++) {
            behind.addLast(new Railcar(id));
        }
    }

    public void disconnectRailcar(Directions dir) throws TrainActionException {
        Railcar railcar;
        if(this.vec == dir) {
            if(this.ahead.isEmpty())
                throw new TrainActionException("Train-" + id + " does not have railcars ahead!");
            railcar = this.ahead.pollLast();
        } else {
            if(this.behind.isEmpty())
                throw new TrainActionException("Train-" + id + " does not have railcars behind!");
            railcar = this.behind.pollLast();
        }

        if(dir == Directions.LEFT) {
            this.currLoc.getLeft().addLast(railcar);
        } else {
            this.currLoc.getRight().addFirst(railcar);
        }
    }

    public void connectRailcar(Directions dir) throws TrainActionException {
        Railcar railcar;
        if(dir == Directions.LEFT) {
            if(this.currLoc.getLeft().isEmpty())
                throw new TrainActionException("Train-" + id + " can't take railcars on the left side!");
            railcar = this.currLoc.getLeft().pollLast();
        } else {
            if(this.currLoc.getRight().isEmpty())
                throw new TrainActionException("Train-" + id + " can't take railcars on the right side!");
            railcar = this.currLoc.getRight().pollFirst();
        }

        if(this.vec == dir) {
            this.ahead.addLast(railcar);
        } else {
            this.behind.addLast(railcar);
        }
    }

    public void disconnectAllRailcars(Directions dir) throws TrainActionException {
        int n;
        if(this.vec == dir) n = this.ahead.size();
        else n = this.behind.size();
        for(int i = 0; i < n; i++) {
            disconnectRailcar(dir);
        }
    }

    public void connectAllRailcars(Directions dir) throws TrainActionException {
        int n;
        if(dir == Directions.LEFT) n = this.currLoc.getLeft().size();
        else n = this.currLoc.getRight().size();
        for(int i = 0; i < n; i++) {
            connectRailcar(dir);
        }
    }

    public void oneStepMove(Directions dir) throws TrainActionException {
        Location newLoc;
        if(dir == Directions.LEFT) {
            if(this.currLoc.getPrevLoc() == null)
                throw new TrainActionException("Train-" + id + " can't move to the left!");
            this.connectAllRailcars(dir);
            newLoc = this.currLoc.getPrevLoc();
        } else {
            if(this.currLoc.getNextLoc() == null)
                throw new TrainActionException("Train-" + id + " can't move to the right!");
            this.connectAllRailcars(dir);
            newLoc = this.currLoc.getNextLoc();
        }
        if(newLoc.isOccupied())
            throw new TrainActionException("Location-" + newLoc.getId() + " is occupied!");
        this.currLoc.setOccupied(false);
        this.currLoc = newLoc;
        newLoc.setOccupied(true);
    }

    public void stepsMove(Directions dir) throws TrainActionException {
        if(dir == Directions.LEFT)
            while(this.currLoc.getPrevLoc() != null && !this.currLoc.getPrevLoc().isOccupied()) {
                oneStepMove(dir);
            }

        if(dir == Directions.RIGHT)
            while(this.currLoc.getNextLoc() != null && !this.currLoc.getNextLoc().isOccupied()) {
                oneStepMove(dir);
            }
    }

    public void moveToDeadend(Location deadendLoc, Directions dir, int limit) throws TrainActionException {
        if(this.ahead.size() + this.behind.size() +
                deadendLoc.getRight().size() + deadendLoc.getLeft().size() > limit)
                    throw new TrainActionException("Train-" + id + "can't move to deadend!");
        if(deadendLoc.isOccupied()) {
            throw new TrainActionException("Train-" + id + "can't move to deadend! Daedend is occupied!");
        }
        this.currLoc.setOccupied(false);
        this.currLoc = deadendLoc;
        deadendLoc.setOccupied(true);
        if(dir == Directions.LEFT && this.vec == Directions.RIGHT) {
            this.vec = Directions.LEFT;
        } else if(dir == Directions.LEFT && this.vec == Directions.LEFT) {
            this.vec = Directions.RIGHT;
        }
    }

    public void moveFromDeadend(Location loc, Directions dir) throws TrainActionException {
        if(loc.isOccupied()) {
            throw new TrainActionException("Train-" + id + "can't move to loc-" + loc.getId() + "! Location is occupied!");
        }
        this.connectAllRailcars(Directions.LEFT);
        this.currLoc.setOccupied(false);
        this.currLoc = loc;
        loc.setOccupied(true);

        if(dir == Directions.RIGHT && this.vec == Directions.RIGHT) {
            this.vec = Directions.LEFT;
        } else if(dir == Directions.RIGHT && this.vec == Directions.LEFT) {
            this.vec = Directions.RIGHT;
        }

        stepsMove(dir);
    }

    public Location getCurrLoc() {
        return currLoc;
    }

    public LinkedList<Railcar> getBehind() {
        return behind;
    }

    public LinkedList<Railcar> getAhead() {
        return ahead;
    }

    public Directions getVec() {
        return vec;
    }

    public int getId() {
        return id;
    }

}
