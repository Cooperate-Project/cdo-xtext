/**
 * Copyright (c) 2013-2014 Stefan Winkler (Kiel, Germany) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *    Stefan Winkler - initial contribution
 * 
 */
package net.winklerweb.cdoxtext.runtime

import com.google.inject.Inject
import java.util.ArrayList
import java.util.Map
import java.util.concurrent.ConcurrentHashMap
import org.apache.log4j.Logger
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.SubMonitor
import org.eclipse.emf.cdo.CDOObject
import org.eclipse.emf.cdo.common.id.CDOID
import org.eclipse.emf.cdo.common.revision.CDORevision
import org.eclipse.emf.cdo.eresource.CDOResource
import org.eclipse.emf.cdo.internal.ui.CDOLobEditorInput
import org.eclipse.emf.cdo.transaction.CDOTransaction
import org.eclipse.emf.common.util.BasicMonitor
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.compare.DifferenceSource
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.merge.BatchMerger
import org.eclipse.emf.compare.rcp.EMFCompareRCPPlugin
import org.eclipse.emf.compare.scope.DefaultComparisonScope
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.jface.text.IDocument
import org.eclipse.jface.text.source.AnnotationModel
import org.eclipse.ui.IEditorInput
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.serializer.ISerializer
import org.eclipse.xtext.ui.editor.model.IResourceForEditorInputFactory
import org.eclipse.xtext.ui.editor.model.XtextDocument
import org.eclipse.xtext.ui.editor.model.XtextDocumentProvider

class CDOXtextDocumentProvider extends XtextDocumentProvider {

	static val Map<IEditorInput, OriginalInputState> inputToResource = new ConcurrentHashMap
 	static val Logger LOGGER = Logger.getLogger(CDOXtextDocumentProvider) 
 
	@Inject
	var ISerializer serializer

	@Inject
	var IResourceForEditorInputFactory resourceForEditorInputFactory
	
	@Inject
	var ICDOResourceStateHandler resourceStateHandler

	/* instead of overriding createDocument(element), we just intercept isWorkspaceExternalEditorInput to
	 * regard CDOLobEditorInput as workspace-external.
	 * This makes createDocument do the right thing(s), namely to call setDocumentContent and setupDocument, which we 
	 * override as well.
	 */
	override isWorkspaceExternalEditorInput(Object element) {
		return super.isWorkspaceExternalEditorInput(element) || element.isCDOInput
	}
	
	override setDocumentContent(IDocument document, IEditorInput editorInput, String encoding) throws CoreException {

		// default behavior for all other editor inputs		
		if (!editorInput.isCDOInput) {
			return super.setDocumentContent(document, editorInput, encoding)
		}

		// special behavior for CDOLobEditorInput
		val resource = editorInput.CDOResource

		val contents = resource.contents.head as CDOObject

		if(contents !== null) {
		    resourceStateHandler.cleanState(contents);
		    resourceStateHandler.initState(contents);
		    resourceStateHandler.calculateState(contents);
			document.set(serializer.serialize(contents))
		}
 
		val xtextDocument = document as XtextDocument
		val xtextResource = resourceForEditorInputFactory.createResource(editorInput) as XtextResource
		loadResource(xtextResource, xtextDocument.get(), encoding)
		xtextDocument.setInput(xtextResource)

		// we need to remember the XtextResource and the original object for saving ...
		if(contents !== null) {
			inputToResource.put(editorInput, new OriginalInputState(xtextResource, contents.cdoID, System.currentTimeMillis()))			
		} else {
			inputToResource.put(editorInput, new OriginalInputState(xtextResource, null, CDORevision::INVALID_DATE))				
		}
	
		return true
	}

	override isModifiable(Object element) {
		if (!element.isCDOInput) {
			return super.isModifiable(element)
		}

		return !element.CDOResource.cdoView.isReadOnly
	}

	override isReadOnly(Object element) {
		val result = !isModifiable(element)
		return result
	}

	override isDeleted(Object element) {
		return false
	}

	override doSaveDocument(IProgressMonitor monitor, Object element, IDocument document, boolean overwrite) throws CoreException {
		if (!element.isCDOInput) {
			super.doSaveDocument(monitor, element, document, overwrite)
			return
		}

		val mon = SubMonitor::convert(monitor, 5)
		var EObject newRootObject = null
		val finalizers = new ArrayList<Runnable>()
		try {
			newRootObject = mergeChanges(element as IEditorInput, mon, finalizers);
		} finally {
			finalizers.forEach[run]
		}
		
		document.set(serializer.serialize(newRootObject))
		mon.done()	
	}
	
	private def mergeChanges(IEditorInput cdoInput, SubMonitor mon, ArrayList<Runnable> finalizers) {
		// get modified model from XtextResource
		val originalInputState = inputToResource.get(cdoInput)
		val documentResource = ResourceWrapper.create(originalInputState.resource)
		finalizers.add(documentResource.disableStateCalculation)
		val newStateRoot = documentResource.contents.head
		val newStateResource = ResourceWrapper.create(newStateRoot.eResource)
		finalizers.add(newStateResource.disableStateCalculation)
		newStateResource.forceCleanup
		resourceStateHandler.cleanState(newStateRoot)

		// get original state from CDO
		val targetResource = ResourceWrapper.create(cdoInput.CDOResource)
		finalizers.add(targetResource.disableStateCalculation)
		targetResource.forceCleanup
		
		val cdoSession = cdoInput.CDOResource.cdoView.session

		if(originalInputState.timestamp == CDORevision::INVALID_DATE) {
			// if the resource was empty before, add the new root
			targetResource.contents.add(newStateRoot)			
		} else {
			val historicView = cdoSession.openView(originalInputState.timestamp)
			try {			
				val originalStateRoot = historicView.getObject(originalInputState.objectId, true)
				originalStateRoot.eResource.forceCleanup
				val targetStateRoot = targetResource.contents.head
				
				// fire up EMFCompare								
				val scope = new DefaultComparisonScope(newStateRoot, targetStateRoot, originalStateRoot)
				val matcherRegistry = EMFCompareRCPPlugin::^default.matchEngineFactoryRegistry
				val compare = EMFCompare::builder().setMatchEngineFactoryRegistry(matcherRegistry).build()
				val result = compare.compare(scope, BasicMonitor::toMonitor(mon.newChild(1)))
				result.diagnostic.children.filter(d | d.severity >= Diagnostic.WARNING).forEach[d | LOGGER.warn(d)]
				
				val merger = new BatchMerger(EMFCompareRCPPlugin::^default.mergerRegistry, [ diff | 
					diff.source == DifferenceSource::LEFT 
				])
				merger.copyAllLeftToRight(result.differences, BasicMonitor::toMonitor(mon.newChild(1)))
				
			}
			finally {
				historicView.close()
			}
		}
		
		val transaction = targetResource.wrappedResource.cdoView() as CDOTransaction
		val newCommitInfo = transaction.commit(mon.newChild(3))
		val rootObject = targetResource.contents.head as CDOObject
		inputToResource.put(cdoInput, new OriginalInputState(documentResource.wrappedResource, rootObject.cdoID, newCommitInfo.timeStamp))	

        rootObject.recalculateState
        newStateRoot.recalculateState
        return rootObject
	}
	
	private def recalculateState(EObject rootObject) {
        resourceStateHandler.cleanState(rootObject)
        resourceStateHandler.initState(rootObject)
        resourceStateHandler.calculateState(rootObject)
	}
	
	private def forceCleanup(ResourceWrapper<? extends Resource> wrapper) {
		wrapper.wrappedResource.forceCleanup
	}
	
	private def forceCleanup(Resource r) {
		resourceStateHandler.forceCleanState(r)
	}
	
	override getEncoding(Object element) {
		try {
			return super.getEncoding(element)
		} catch (ClassCastException e) {
			return getWorkspaceOrDefaultEncoding();
		}
	}
	
	override createAnnotationModel(Object element) {
		if (element.isCDOInput) {
			return new AnnotationModel();
		}
		return super.createAnnotationModel(element)
	}
	
	private static def isCDOInput(Object element) {
		return element instanceof CDOLobEditorInput
	}
	
	private static def getCDOResource(Object editorInput) {
		if (editorInput.isCDOInput) {
			return (editorInput as CDOLobEditorInput).resource as CDOResource
		}
		return null
	}
}

class OriginalInputState {
	public XtextResource resource
	public CDOID objectId
	public long timestamp
	
	new(XtextResource resource, CDOID cdoid, long timestamp) {
		this.resource = resource
		this.objectId = cdoid
		this.timestamp = timestamp
	}
}
