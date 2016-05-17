package net.winklerweb.cdoxtext.runtime

import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.jface.text.source.IAnnotationModel
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionProvider
import org.eclipse.xtext.ui.editor.validation.AnnotationIssueProcessor

class CDOAnnotationIssueProcessor extends AnnotationIssueProcessor {
	
	val IAnnotationModel annotationModel
	
	new(IXtextDocument xtextDocument, IAnnotationModel annotationModel, IssueResolutionProvider issueResolutionProvider) {
		super(xtextDocument, annotationModel, issueResolutionProvider)
		this.annotationModel = annotationModel
	}
	
	override fireQueuedEvents() {
		if (annotationModel instanceof CDOMarkerAnnotationModel)
			(annotationModel as CDOMarkerAnnotationModel).fireQueuedEvents();
	}
	
	override updateMarkerAnnotations(IProgressMonitor monitor) {
		super.updateMarkerAnnotations(monitor)
	}

}