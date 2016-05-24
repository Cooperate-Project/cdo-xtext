package net.winklerweb.cdoxtext.generator

import java.util.List
import org.eclipse.emf.codegen.ecore.genmodel.GenDelegationKind
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xpand2.XpandExecutionContext
import org.eclipse.xtext.Grammar
import org.eclipse.xtext.generator.ecore.EMFGeneratorFragment
import com.google.common.collect.Sets

class EMFCDOGeneratorFragment extends EMFGeneratorFragment {

	override getRequiredBundlesUi(Grammar grammar) {
		val requiredBundles = Sets.newHashSet();
		val superRequiredBundles = super.getRequiredBundlesUi(grammar)?.toSet
		if (superRequiredBundles != null) {
			requiredBundles.addAll(superRequiredBundles);
		}
		requiredBundles.add("org.eclipse.emf.cdo;visibility:=reexport")
		return requiredBundles
	}

	protected override getGenModel(ResourceSet rs, Grammar grammar, XpandExecutionContext ctx, List<EPackage> packs) {
		val genModel = super.getGenModel(rs, grammar, ctx, packs)

		genModel.rootExtendsInterface = "org.eclipse.emf.cdo.CDOObject"
		genModel.rootExtendsClass = "org.eclipse.emf.internal.cdo.CDOObjectImpl"
		genModel.providerRootExtendsClass = "org.eclipse.emf.cdo.edit.CDOItemProviderAdapter"
		genModel.importerID = "org.eclipse.emf.importer.cdo"
		genModel.featureDelegation = GenDelegationKind.DYNAMIC_LITERAL
		genModel.operationReflection = true
		genModel.importOrganizing = true

		return genModel
	}

	protected override getTemplate() {
		return EMFGeneratorFragment.name.replaceAll("\\.", "::");
	}

}
