package net.winklerweb.cdoxtext.runtime;

import java.util.function.Consumer;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;

public interface ICDOResourceStateHandler {

    void initState(EObject o);

    void calculateState(EObject o);

    void cleanState(EObject o);
    
    default void initState(Resource r) {
        execute(r, this::initState);
    }
    
    default void calculateState(Resource r) {
        execute(r, this::calculateState);
    }
    
    default void cleanState(Resource r) {
        execute(r, this::cleanState);
    }

    static void execute(Resource r, Consumer<EObject> o) {
        if (r != null) {
            r.getContents().forEach(o::accept);
        }
    }

}
