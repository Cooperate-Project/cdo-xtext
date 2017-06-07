package net.winklerweb.cdoxtext.runtime;

import java.util.Iterator;

import org.eclipse.emf.compare.Match;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;

public interface IFeatureFilter {

    /**
     * The diff engine expects this to return the set of references that need to be checked for differences
     * for the given {@link Match} element.
     * <p>
     * This default implementation assumes that all three sides of the match are conform to the same
     * metamodel, and simply returns one of the side's {@link EClass#getEAllReferences()
     * side.eClass().getEAllReferences()}, ignoring only the derived and container.
     * </p>
     * 
     * @param match
     *            The match for which we are trying to compute differences.
     * @return The set of references that are to be checked by the diff engine. May be an empty iterator, in
     *         which case no difference will be detected on any of this <code>match</code>'s references.
     */
    public Iterator<EReference> getReferencesToCheck(final Match match);

    /**
     * The diff engine expects this to return the set of attributes that need to be checked for differences
     * for the given {@link Match} element.
     * <p>
     * This default implementation assumes that all three sides of the match are conform to the same
     * metamodel, and simply returns one of the side's {@link EClass#getEAllAttributes()
     * side.eClass().getEAllAttributes()}, ignoring only the derived.
     * </p>
     * 
     * @param match
     *            The match for which we are trying to compute differences.
     * @return The set of attributes that are to be checked by the diff engine. May be an empty iterator, in
     *         which case no difference will be detected on any of this <code>match</code>'s attributes.
     */
    public Iterator<EAttribute> getAttributesToCheck(Match match);
    
    /**
     * Tells the diff engine whether the given feature should be checked for changed in the ordering or not.
     * This default implementation considers that any "ordered" or "containment" feature should be checked for
     * changes.
     * 
     * @param feature
     *            The feature we are currently checking.
     * @return <code>true</code> if the diff engine should consider the ordering of this feature,
     *         <code>false</code> otherwise.
     */
    public boolean checkForOrderingChanges(EStructuralFeature feature);    
}
