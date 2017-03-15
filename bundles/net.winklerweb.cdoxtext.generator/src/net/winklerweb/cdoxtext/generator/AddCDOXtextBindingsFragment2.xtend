package net.winklerweb.cdoxtext.generator

import net.winklerweb.cdoxtext.runtime.CDOLanguageSpecificURIEditorOpener
import net.winklerweb.cdoxtext.runtime.CDOResourceForEditorInputFactory
import net.winklerweb.cdoxtext.runtime.CDOXtextDocumentProvider
import net.winklerweb.cdoxtext.runtime.CDOXtextEditor
import org.eclipse.ui.PlatformUI
import org.eclipse.xtend2.lib.StringConcatenationClient
import org.eclipse.xtext.ui.LanguageSpecific
import org.eclipse.xtext.ui.editor.IURIEditorOpener
import org.eclipse.xtext.ui.editor.LanguageSpecificURIEditorOpener
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.xtext.generator.AbstractXtextGeneratorFragment
import org.eclipse.xtext.xtext.generator.model.GuiceModuleAccess

import static extension org.eclipse.xtext.xtext.generator.model.TypeReference.*
import org.eclipse.xtext.formatting2.regionaccess.TextRegionAccessBuilder
import net.winklerweb.cdoxtext.runtime.CDOTextRegionAccessBuilder

class AddCDOXtextBindingsFragment2 extends AbstractXtextGeneratorFragment {
	
	override generate() {
		registerguiceBindingsRt()
		registerGuiceBindingsUi()
		addRequiredBundles()

	}
	
	def registerguiceBindingsRt() {
		new GuiceModuleAccess.BindingFactory()
		.addTypeToType(TextRegionAccessBuilder.typeRef, CDOTextRegionAccessBuilder.typeRef)
		.contributeTo(language.runtimeGenModule)
	}
	
	private def addRequiredBundles() {
		projectConfig.runtime?.manifest?.requiredBundles += "net.winklerweb.cdoxtext.runtime;visibility:=reexport"
	}
	
	private def registerGuiceBindingsUi() {
		var StringConcatenationClient uriEditorOpenerStatement = '''
		if («PlatformUI.typeRef».isWorkbenchRunning())
			binder.bind(«IURIEditorOpener.typeRef».class)
				.annotatedWith(«LanguageSpecific.typeRef».class)
				.to(«CDOLanguageSpecificURIEditorOpener.typeRef».class);'''
		
		new GuiceModuleAccess.BindingFactory()
		.addTypeToType("org.eclipse.xtext.ui.editor.model.XtextDocumentProvider".typeRef, CDOXtextDocumentProvider.typeRef)
		.addTypeToType("org.eclipse.xtext.ui.editor.model.IResourceForEditorInputFactory".typeRef, CDOResourceForEditorInputFactory.typeRef)
		.addTypeToType(XtextEditor.typeRef, CDOXtextEditor.typeRef)
		.addConfiguredBinding(LanguageSpecificURIEditorOpener.simpleName, uriEditorOpenerStatement)
		.contributeTo(language.eclipsePluginGenModule)
	}
	
}