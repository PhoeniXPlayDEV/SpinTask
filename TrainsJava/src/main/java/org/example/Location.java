package org.example;

import java.util.LinkedList;

public class Location {

    private final int id;
    private boolean isOccupied = false;
    private Location prevLoc;
    private Location nextLoc;

    private LinkedList<Railcar> left = new LinkedList<>();
    private LinkedList<Railcar> right = new LinkedList<>();

    public Location(int id) {
        this.id = id;
    }

    public void setNextLocation(Location loc) {
        this.nextLoc = loc;
        this.right = loc.left;
    }

    public void setPrevLocation(Location loc) {
        this.prevLoc = loc;
        this.left = loc.right;
    }

    public Location getPrevLoc() {
        return prevLoc;
    }

    public Location getNextLoc() {
        return nextLoc;
    }

    public LinkedList<Railcar> getLeft() {
        return left;
    }

    public LinkedList<Railcar> getRight() {
        return right;
    }

    public boolean isOccupied() {
        return isOccupied;
    }

    public void setOccupied(boolean occupied) {
        isOccupied = occupied;
    }

    public int getId() {
        return id;
    }

    @Override
    public String toString() {
        return "Loc-" + id + ": isOccupied = " + isOccupied + "\n\tleft = [" +
                String.join(", ", left.stream().map(railcar -> String.valueOf(railcar.getId())).toList()) +
                "]\n\tright = [" +
                String.join(", ", right.stream().map(railcar -> String.valueOf(railcar.getId())).toList()) +
                "]";
    }
}
