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

import org.eclipse.core.runtime.URIUtil
import org.eclipse.emf.cdo.internal.ui.CDOLobEditorInput
import org.eclipse.ui.IEditorInput
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.model.IResourceForEditorInputFactory
import org.eclipse.xtext.ui.editor.model.ResourceForIEditorInputFactory
import org.eclipse.xtext.resource.ResourceSetReferencingResourceSet

class CDOResourceForEditorInputFactory extends ResourceForIEditorInputFactory implements IResourceForEditorInputFactory {

	/** 
	 * Create an XtextResource for a given CDOLobEditorInput
	 */
	override createResource(IEditorInput input) {
		if (!(input instanceof CDOLobEditorInput)) {
			return super.createResource(input);
		}

		val cdoEditorInput = input as CDOLobEditorInput
		val emfUri = cdoEditorInput.resource.URI
		val uri = URIUtil::fromString(emfUri.toString)

		val resource = createResource(uri)
		if (resource instanceof XtextResource) {
			(resource as XtextResource).validationDisabled = false
		}
		if (resource.resourceSet instanceof ResourceSetReferencingResourceSet) {
			(resource.resourceSet as ResourceSetReferencingResourceSet).referencedResourceSets.add(cdoEditorInput.resource.cdoView.resourceSet)
		}
		return resource
	}
}
