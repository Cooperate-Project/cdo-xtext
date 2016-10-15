package net.winklerweb.cdoxtext.runtime;

import java.io.IOException;
import java.util.Map;

import org.eclipse.emf.common.notify.Adapter;
import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.resource.XtextResource;

// TODO At least throw exceptions when XtextResource operations are called
public class XtextResourceDummy extends XtextResource {

	private Resource r;

	public XtextResourceDummy(Resource r) {
		this.r = r;
	}

	public URI getURI() {
		return r.getURI();
	}

	public EList<EObject> getContents() {
		return r.getContents();
	}

	public EList<Adapter> eAdapters() {
		return r.eAdapters();
	}

	public boolean eDeliver() {
		return r.eDeliver();
	}

	public void eSetDeliver(boolean deliver) {
		r.eSetDeliver(deliver);
	}

	public void eNotify(Notification notification) {
		r.eNotify(notification);
	}

	public ResourceSet getResourceSet() {
		return r.getResourceSet();
	}

	public void setURI(URI uri) {
		r.setURI(uri);
	}

	public long getTimeStamp() {
		return r.getTimeStamp();
	}

	public void setTimeStamp(long timeStamp) {
		r.setTimeStamp(timeStamp);
	}

	public TreeIterator<EObject> getAllContents() {
		return r.getAllContents();
	}

	public String getURIFragment(EObject eObject) {
		return r.getURIFragment(eObject);
	}

	public EObject getEObject(String uriFragment) {
		return r.getEObject(uriFragment);
	}

	public void save(Map<?, ?> options) throws IOException {
		r.save(options);
	}

	public void load(Map<?, ?> options) throws IOException {
		r.load(options);
	}

	public boolean isTrackingModification() {
		return r.isTrackingModification();
	}

	public void setTrackingModification(boolean isTrackingModification) {
		r.setTrackingModification(isTrackingModification);
	}

	public boolean isModified() {
		return r.isModified();
	}

	public void setModified(boolean isModified) {
		r.setModified(isModified);
	}

	public boolean isLoaded() {
		return r.isLoaded();
	}

	public void delete(Map<?, ?> options) throws IOException {
		r.delete(options);
	}

	public EList<Diagnostic> getErrors() {
		return r.getErrors();
	}

	public EList<Diagnostic> getWarnings() {
		return r.getWarnings();
	}

}
