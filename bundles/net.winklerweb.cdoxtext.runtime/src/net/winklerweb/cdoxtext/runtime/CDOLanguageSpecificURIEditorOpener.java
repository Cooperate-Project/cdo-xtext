package net.winklerweb.cdoxtext.runtime;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

import org.eclipse.emf.cdo.internal.ui.CDOLobEditorInput;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IEditorReference;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.xtext.ui.editor.LanguageSpecificURIEditorOpener;

public class CDOLanguageSpecificURIEditorOpener extends LanguageSpecificURIEditorOpener {

	@Override
	public IEditorPart open(URI uri, EReference crossReference, int indexInList, boolean select) {
		if (!uri.scheme().startsWith("cdo")) {
			return super.open(uri, crossReference, indexInList, select);
		}

		Collection<IEditorPart> editors = Arrays.stream(PlatformUI.getWorkbench().getWorkbenchWindows())
				.flatMap(w -> Arrays.stream(w.getPages())).flatMap(p -> Arrays.stream(p.getEditorReferences()))
				.map(r -> r.getEditor(false)).filter(Objects::nonNull).collect(Collectors.toSet());
		return editors.stream().filter(e -> hasMatchingEditorInput(e, uri)).findFirst().orElseGet(null);
	}

	private static boolean hasMatchingEditorInput(IEditorPart editor, URI uri) {
		IEditorInput editorInput = editor.getEditorInput();
		if (editorInput instanceof CDOLobEditorInput) {
			CDOLobEditorInput cdoEditorInput = (CDOLobEditorInput) editorInput;
			URI inputUri = cdoEditorInput.getResource().getURI();
			if (inputUri != null) {
				URI deresolvedUri = uri.deresolve(inputUri);
				if (!uri.equals(deresolvedUri)) {
					return true;
				}
			}
		}
		return false;
	}

}
