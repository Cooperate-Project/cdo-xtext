package net.winklerweb.cdoxtext.runtime

import org.eclipse.xtext.resource.XtextResource
import org.eclipse.emf.cdo.common.id.CDOID

class CDOXtextResourceState extends CDOAbstractResourceState<XtextResource> {
	
	new(XtextResource resource, CDOID cdoid, long timestamp) {
		super(resource, cdoid, timestamp)
	}
	
}