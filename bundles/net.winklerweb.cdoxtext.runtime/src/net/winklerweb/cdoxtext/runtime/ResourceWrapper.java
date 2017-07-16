package net.winklerweb.cdoxtext.runtime;

import java.util.Collection;
import java.util.Optional;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;

public class ResourceWrapper<T extends Resource> {

	private final T r;
	private final Optional<IStateCalculationActivator> activator;

	public ResourceWrapper(T r) {
		this(r, Optional.of(r).filter(IStateCalculationActivator.class::isInstance)
				.map(IStateCalculationActivator.class::cast).orElse(null));
	}

	public ResourceWrapper(T r, IStateCalculationActivator activator) {
		this.r = r;
		this.activator = Optional.ofNullable(activator);
	}

	public static <T extends Resource> ResourceWrapper<T> create(T r) {
		return new ResourceWrapper<T>(r);
	}

	public Collection<EObject> getContents() {
		return r.getContents();
	}

	public T getWrappedResource() {
		return r;
	}

	public Runnable disableStateCalculation() {
		if (activator.isPresent()) {
			IStateCalculationActivator availableActivator = activator.get();
			return disableStateCalculation(availableActivator);
		} else {
			return () -> {};
		}
	}

	private Runnable disableStateCalculation(IStateCalculationActivator availableActivator) {
		boolean oldState = availableActivator.isStateCalculation();
		availableActivator.disableStateCalculation();
		return () -> {
			if (oldState) {
				availableActivator.enableStateCalculation();
			}
		};
	}
}
