package org.example;

public class TrainActionException extends Exception {

    public TrainActionException() {
        super();
    }

    public TrainActionException(String message) {
        super(message);
    }

    public TrainActionException(String message, Throwable cause) {
        super(message, cause);
    }

    public TrainActionException(Throwable cause) {
        super(cause);
    }

    protected TrainActionException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }
}
