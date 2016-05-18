package net.winklerweb.cdoxtext.runtime

import java.io.Closeable
import java.io.IOException
import org.eclipse.emf.cdo.CDOObject
import org.eclipse.emf.cdo.common.id.CDOID
import org.eclipse.emf.cdo.eresource.CDOResource

class CDOResourceState extends CDOAbstractResourceState<CDOResource> {

	public static class CDORootClosable implements Closeable {
		val CDOObject cdoObject
		
		new(CDOObject cdoObject) {
			this.cdoObject = cdoObject
		}
		
		def getCDOObject() {
			return cdoObject
		}
		
		override close() throws IOException {
			cdoObject.cdoView.close
		}
		
	}

	new(CDOResource resource, CDOID cdoid, long timestamp) {
		super(resource, cdoid, timestamp)
	}
	
	def getRoot() {
		val historyView = resource.cdoView.session.openView(timestamp)
		val object = historyView.getObject(objectId, true)
		val history = object.cdoHistory
		return new CDORootClosable(object);
	}
}
