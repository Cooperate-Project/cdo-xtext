package net.winklerweb.cdoxtext.runtime;

import java.lang.reflect.Field;

import org.apache.log4j.Logger;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.formatting2.regionaccess.internal.StringBasedRegionAccess;
import org.eclipse.xtext.formatting2.regionaccess.internal.StringHiddenRegion;
import org.eclipse.xtext.formatting2.regionaccess.internal.TextRegionAccessBuildingSequencer;
import org.eclipse.xtext.serializer.ISerializationContext;
import org.eclipse.xtext.serializer.analysis.SerializationContext;

@SuppressWarnings("restriction")
public class CDOTextRegionAccessBuildingSequencer extends TextRegionAccessBuildingSequencer {

	private static final Logger LOGGER = Logger.getLogger(CDOTextRegionAccessBuildingSequencer.class);
	
	@Override
	public TextRegionAccessBuildingSequencer withRoot(ISerializationContext ctx, EObject root) {
		CDOStringBasedRegionAccess regionAccess = new CDOStringBasedRegionAccess(root.eResource());
		setRegionAccess(regionAccess);
		setLastRegion(createHiddenRegion());
		regionAccess.setRootEObject(enterEObject(((SerializationContext) ctx).getActionOrRule(), root));
		return this;
	}
	
	protected void setRegionAccess(StringBasedRegionAccess regionAccess) {
		setHiddenAttribute("regionAccess", regionAccess);
	}
	
	protected void setLastRegion(StringHiddenRegion lastRegion) {
		setHiddenAttribute("last", lastRegion);
	}
	
	private void setHiddenAttribute(String attributeName, Object value) {
		try {
			Field f = TextRegionAccessBuildingSequencer.class.getDeclaredField(attributeName);
			f.setAccessible(true);
			f.set(this, value);
		} catch (NoSuchFieldException | SecurityException | IllegalArgumentException | IllegalAccessException e) {
			LOGGER.error(String.format("Could not set the \"%s\" property.", attributeName), e);
		}
	}
	
}
