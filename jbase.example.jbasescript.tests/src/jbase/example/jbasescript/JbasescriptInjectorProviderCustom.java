package jbase.example.jbasescript;


import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.xtext.xbase.compiler.OnTheFlyJavaCompiler;
import org.eclipse.xtext.xbase.compiler.OnTheFlyJavaCompiler.EclipseRuntimeDependentJavaCompiler;
import org.eclipse.xtext.xbase.lib.Functions;

import com.google.common.base.Supplier;
import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.Provider;

/**
 * This is required to run tests based on Java compiler in Tycho, otherwise
 * when compiling generated Java code, external libraries like xbase.lib won't be found.
 * 
 * @author Lorenzo Bettini
 *
 */
public class JbasescriptInjectorProviderCustom extends JbasescriptInjectorProvider {

	public Injector internalCreateInjector() {
		return new JbasescriptStandaloneSetup() {
			@Override
			public Injector createInjector() {
				return Guice.createInjector(new JbasescriptRuntimeModule() {
					@Override
					public ClassLoader bindClassLoaderToInstance() {
						return JbasescriptInjectorProviderCustom.class.getClassLoader();
					}

					@SuppressWarnings("unused")
					public Class<? extends OnTheFlyJavaCompiler> bindOnTheFlyJavaCompiler() {
						try {
							if (ResourcesPlugin.getWorkspace() != null)
								return EclipseRuntimeDependentJavaCompiler.class;
						} catch (Exception e) {
							// ignore
						}
						return OnTheFlyJavaCompiler.class;
					}
					
					@SuppressWarnings("unused")
					public Class<? extends OnTheFlyJavaCompiler.ClassPathAssembler> bindClassPathAssembler() {
						return TestClassPathAssembler.class;
					}
				});
			}
		}.createInjectorAndDoEMFRegistration();
	}

	public static class TestClassPathAssembler extends
			OnTheFlyJavaCompiler.ClassPathAssembler {
		@Override
		public void assembleCompilerClassPath(OnTheFlyJavaCompiler compiler) {
			super.assembleCompilerClassPath(compiler);
			if (compiler instanceof EclipseRuntimeDependentJavaCompiler) {
				compiler.addClassPathOfClass(getClass());
				compiler.addClassPathOfClass(Functions.class);
				compiler.addClassPathOfClass(Provider.class);
				compiler.addClassPathOfClass(javax.inject.Provider.class);
				compiler.addClassPathOfClass(Supplier.class);
			}
		}
	}
}
