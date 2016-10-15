package net.winklerweb.cdoxtext.runtime;

import org.eclipse.emf.cdo.eresource.CDOResource;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.formatting2.regionaccess.ITextRegionAccess;
import org.eclipse.xtext.formatting2.regionaccess.TextRegionAccessBuilder;
import org.eclipse.xtext.formatting2.regionaccess.internal.TextRegionAccessBuildingSequencer;
import org.eclipse.xtext.serializer.ISerializationContext;
import org.eclipse.xtext.serializer.acceptor.ISequenceAcceptor;

@SuppressWarnings("restriction")
public class CDOTextRegionAccessBuilder extends TextRegionAccessBuilder {

	private TextRegionAccessBuildingSequencer sequenceAcceptor;
	
	@Override
	public ISequenceAcceptor forSequence(ISerializationContext ctx, EObject root) {
		if (root.eResource() instanceof CDOResource) {
			sequenceAcceptor = new CDOTextRegionAccessBuildingSequencer().withRoot(ctx, root);
			return sequenceAcceptor;
		}
		return super.forSequence(ctx, root);
	}

	@Override
	public ITextRegionAccess create() {
		if (sequenceAcceptor != null) {
			return sequenceAcceptor.getRegionAccess();
		}
		return super.create();
	}
	
	
}
