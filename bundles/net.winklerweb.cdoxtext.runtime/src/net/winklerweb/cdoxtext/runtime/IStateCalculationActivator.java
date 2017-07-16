package net.winklerweb.cdoxtext.runtime;

public interface IStateCalculationActivator {

    /**
     * Enables the state calculation.
     */
    void enableStateCalculation();

    /**
     * Disabled the state calculation.
     */
    void disableStateCalculation();
	
    /**
     * @return True if state calculation is enabled, false otherwise.
     */
    boolean isStateCalculation();
}
