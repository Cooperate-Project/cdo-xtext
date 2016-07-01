package net.winklerweb.cdoxtext.runtime

import java.util.concurrent.Executors
import net.winklerweb.cdoxtext.runtime.CDOResourceState.CDORootClosable
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.SubMonitor
import org.eclipse.emf.cdo.CDOObject
import org.eclipse.emf.cdo.common.branch.CDOBranchPoint
import org.eclipse.emf.cdo.common.revision.CDORevision
import org.eclipse.emf.cdo.view.CDOView
import org.eclipse.emf.cdo.view.CDOViewInvalidationEvent
import org.eclipse.emf.common.util.BasicMonitor
import org.eclipse.emf.compare.DifferenceSource
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.merge.BatchMerger
import org.eclipse.emf.compare.rcp.EMFCompareRCPPlugin
import org.eclipse.emf.compare.scope.DefaultComparisonScope
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.net4j.util.event.IEvent
import org.eclipse.net4j.util.event.IListener
import org.eclipse.net4j.util.io.IOUtil
import org.eclipse.swt.widgets.Display
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.util.concurrent.IUnitOfWork
import org.eclipse.emf.cdo.view.CDOAdapterPolicy
import org.eclipse.emf.cdo.eresource.CDOResource

class CDOHistoryHandler {

	@FunctionalInterface
	public interface DocumentGetter {
		public def IXtextDocument get();
	}

	val viewListener = new IListener() {

		val executor = Executors.newFixedThreadPool(1)

		/*
		 * TODO Implementation not complete
		 * Not only the resource itself can change but also the referenced resources. 
		 */
		override notifyEvent(IEvent arg0) {
			if (arg0 instanceof CDOViewInvalidationEvent) {
				val event = (arg0 as CDOViewInvalidationEvent)
				val changedResources = arg0.dirtyObjects.filter(EObject).map[root].filter(o|o != null).map[eResource].filter(CDOResource).toSet
				if (changedResources.contains(targetObject.cdoDirectResource)) {
					executor.submit(new Runnable() {
						override run() {
							applyRemoteResourceChanges(event.timeStamp)
						}
					})
				}
			}
		}

	}

	private def <T extends EObject> getRoot(T o) {
		return EcoreUtil.getRootContainer(o, true) as T;
	}

	val CDOView cdoView
	val CDOObject targetObject;
	val DocumentGetter documentGetter;
	var long previousTimestamp;

	new(DocumentGetter documentGetter, CDOView cdoView, CDOObject cdoObject) {
		this.cdoView = cdoView
		previousTimestamp = CDORevision::INVALID_DATE
		this.targetObject = cdoObject
		this.documentGetter = documentGetter
	}

	def start() {
		previousTimestamp = cdoView.getObject(targetObject.cdoID).cdoHistory?.lastElement?.timeStamp
		if (previousTimestamp == 0) {
			previousTimestamp = CDOBranchPoint.UNSPECIFIED_DATE
		}
		cdoView.addListener(viewListener);
	}

	def stop() {
		cdoView.removeListener(viewListener);
	}

	private def applyRemoteResourceChanges(long newTimeStamp) {
		val cdoResource = cdoView.getObject(targetObject.cdoID).cdoDirectResource
		val oldResourceState = new CDOResourceState(cdoResource, targetObject.cdoID, previousTimestamp);
		val newResourceState = new CDOResourceState(cdoResource, targetObject.cdoID, newTimeStamp);
		if (documentGetter.get() != null) {
			documentGetter.get().merge(oldResourceState, newResourceState)
			previousTimestamp = newTimeStamp
		}
	}

	def void merge(IXtextDocument targetDocument, CDOResourceState oldState, CDOResourceState newState) {
		Display.^default.syncExec(new Runnable() {
			override run() {
				targetDocument.modify(new IUnitOfWork.Void<XtextResource>() {
					override process(XtextResource state) throws Exception {
						val CDORootClosable oldRoot = oldState.root;
						val CDORootClosable newRoot = newState.root;
						try {
							state.contents.get(0).merge(oldRoot.CDOObject, newRoot.CDOObject)
						} finally {
							IOUtil.closeSilent(oldRoot)
							IOUtil.closeSilent(newRoot)
						}
					}
				})
			}
		});
	}

	def void merge(EObject targetRoot, EObject oldRoot, EObject newRoot) {
		val monitor = new NullProgressMonitor();
		val mon = SubMonitor::convert(monitor, 5)

		val scope = new DefaultComparisonScope(newRoot, targetRoot, oldRoot)

		val matcherRegistry = EMFCompareRCPPlugin::^default.matchEngineFactoryRegistry
		val compare = EMFCompare::builder().setMatchEngineFactoryRegistry(matcherRegistry).build()
		val result = compare.compare(scope, BasicMonitor::toMonitor(mon.newChild(1)))
		val merger = new BatchMerger(EMFCompareRCPPlugin::^default.mergerRegistry, [ diff |
			diff.source == DifferenceSource::LEFT
		])
		merger.copyAllLeftToRight(result.differences, BasicMonitor::toMonitor(mon.newChild(1)))
	}
}
