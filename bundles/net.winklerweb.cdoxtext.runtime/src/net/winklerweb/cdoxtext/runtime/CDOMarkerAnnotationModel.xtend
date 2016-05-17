package net.winklerweb.cdoxtext.runtime

import org.eclipse.ui.texteditor.AbstractMarkerAnnotationModel
import org.eclipse.core.resources.IMarker
import org.eclipse.core.runtime.CoreException
import org.eclipse.emf.cdo.internal.ui.CDOLobEditorInput

class CDOMarkerAnnotationModel extends AbstractMarkerAnnotationModel {
	
	val CDOLobEditorInput input
	
	new(CDOLobEditorInput input) {
		this.input = input
	}
	
	def fireQueuedEvents() {
		fireModelChanged();
	}
	
	override protected deleteMarkers(IMarker[] markers) throws CoreException {
		return
	}
	
	override protected isAcceptable(IMarker marker) {
		return false
	}
	
	override protected listenToMarkerChanges(boolean listen) {
		return
	}
	
	override protected retrieveMarkers() throws CoreException {
		return #[]
	}
	
}