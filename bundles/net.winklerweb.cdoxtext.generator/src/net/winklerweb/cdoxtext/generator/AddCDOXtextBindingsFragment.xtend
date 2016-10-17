package net.winklerweb.cdoxtext.generator

import org.eclipse.xtext.Grammar
import org.eclipse.xtext.generator.BindFactory
import org.eclipse.xtext.generator.Xtend2GeneratorFragment

class AddCDOXtextBindingsFragment extends Xtend2GeneratorFragment {

	override getGuiceBindingsUi(Grammar grammar) {
		new BindFactory().addTypeToType(
		      "org.eclipse.xtext.ui.editor.model.XtextDocumentProvider",
			  "net.winklerweb.cdoxtext.runtime.CDOXtextDocumentProvider")
			.addTypeToType(
			  "org.eclipse.xtext.ui.editor.model.IResourceForEditorInputFactory",
			  "net.winklerweb.cdoxtext.runtime.CDOResourceForEditorInputFactory")
			.addTypeToType(
			  "org.eclipse.xtext.ui.editor.XtextEditor",
			  "net.winklerweb.cdoxtext.runtime.CDOXtextEditor")
			.addTypeToType(
			  "org.eclipse.xtext.formatting2.regionaccess.TextRegionAccessBuilder",
			  "net.winklerweb.cdoxtext.runtime.CDOTextRegionAccessBuilder"
			)
			.addConfiguredBinding(
					"org.eclipse.xtext.ui.editor.LanguageSpecificURIEditorOpener",
					"if (org.eclipse.ui.PlatformUI.isWorkbenchRunning())" +
						"binder.bind(org.eclipse.xtext.ui.editor.IURIEditorOpener.class)"
							+ ".annotatedWith(org.eclipse.xtext.ui.LanguageSpecific.class)"
							+ ".to(net.winklerweb.cdoxtext.runtime.CDOLanguageSpecificURIEditorOpener.class)")
			.bindings
	}

	override getRequiredBundlesUi(Grammar grammar) {
		#["net.winklerweb.cdoxtext.runtime"]
	}
}
