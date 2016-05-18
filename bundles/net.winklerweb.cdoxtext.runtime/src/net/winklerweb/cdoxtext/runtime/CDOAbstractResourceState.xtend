package net.winklerweb.cdoxtext.runtime

import org.eclipse.emf.cdo.common.id.CDOID

abstract class CDOAbstractResourceState<T> {
	public T resource
	public CDOID objectId
	public long timestamp
	
	new(T resource, CDOID cdoid, long timestamp) {
		this.resource = resource
		this.objectId = cdoid
		this.timestamp = timestamp
	}
}