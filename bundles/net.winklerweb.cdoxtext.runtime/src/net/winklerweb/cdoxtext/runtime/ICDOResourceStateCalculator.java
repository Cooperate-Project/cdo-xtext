package net.winklerweb.cdoxtext.runtime;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;

public interface ICDOResourceStateCalculator {

	void calculateState(Resource r);
	void calculateState(EObject object);
	
}
