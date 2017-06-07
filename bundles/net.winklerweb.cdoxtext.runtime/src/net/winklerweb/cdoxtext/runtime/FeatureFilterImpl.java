package net.winklerweb.cdoxtext.runtime;

import java.util.Iterator;

import org.eclipse.emf.compare.Match;
import org.eclipse.emf.compare.diff.FeatureFilter;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;

public class FeatureFilterImpl extends FeatureFilter {

    private static class DefaultFeatureFilter extends FeatureFilter implements IFeatureFilter {
        
    }
    
    private final IFeatureFilter delegate;
    
    public FeatureFilterImpl(IFeatureFilter delegate) {
        if (delegate == null) {
            this.delegate = new DefaultFeatureFilter();
        } else {
            this.delegate = delegate;            
        }
    }

    @Override
    public Iterator<EReference> getReferencesToCheck(Match match) {
        return delegate.getReferencesToCheck(match);
    }

    @Override
    public Iterator<EAttribute> getAttributesToCheck(Match match) {
        return delegate.getAttributesToCheck(match);
    }

    @Override
    public boolean checkForOrderingChanges(EStructuralFeature feature) {
        return delegate.checkForOrderingChanges(feature);
    }
    
}
