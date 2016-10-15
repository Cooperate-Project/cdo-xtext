package net.winklerweb.cdoxtext.runtime;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.formatting2.regionaccess.internal.StringBasedRegionAccess;

@SuppressWarnings("restriction")
public class CDOStringBasedRegionAccess extends StringBasedRegionAccess {
	
	protected CDOStringBasedRegionAccess(Resource resource) {
		super(new XtextResourceDummy(resource));
	}
	
}
