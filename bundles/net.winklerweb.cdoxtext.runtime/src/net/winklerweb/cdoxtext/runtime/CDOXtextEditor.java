package net.winklerweb.cdoxtext.runtime;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.cdo.CDOObject;
import org.eclipse.emf.cdo.eresource.CDOResource;
import org.eclipse.emf.cdo.eresource.CDOResourceLeaf;
import org.eclipse.emf.cdo.internal.ui.CDOLobEditorInput;
import org.eclipse.ui.IEditorInput;
import org.eclipse.xtext.ui.editor.XtextEditor;

public class CDOXtextEditor extends XtextEditor {

	private CDOHistoryHandler historyHandler;

	@Override
	protected void doSetInput(IEditorInput input) throws CoreException {
		super.doSetInput(input);
		
		if (input instanceof CDOLobEditorInput) {
			CDOResourceLeaf resourceLeaf = ((CDOLobEditorInput)input).getResource();
			if (resourceLeaf instanceof CDOResource) {
				CDOResource resource = (CDOResource)resourceLeaf;
				historyHandler = new CDOHistoryHandler(this::getDocument, resource.cdoView(), (CDOObject)resource.eContents().get(0));
				historyHandler.start();
			}
		}
	}

	@Override
	public void dispose() {
		if (historyHandler != null) {
			historyHandler.stop();			
		}
		super.dispose();
	}

	@Override
	public void doSave(IProgressMonitor progressMonitor) {
		historyHandler.stop();
		try {
			super.doSave(progressMonitor);			
		} finally {
			if (historyHandler != null) {
				historyHandler.start();				
			}
		}
	}
	
	
}
