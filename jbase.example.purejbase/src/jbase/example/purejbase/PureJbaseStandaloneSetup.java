/*
 * generated by Xtext
 */
package jbase.example.purejbase;

/**
 * Initialization support for running Xtext languages without equinox extension
 * registry
 */
public class PureJbaseStandaloneSetup extends PureJbaseStandaloneSetupGenerated {

	public static void doSetup() {
		new PureJbaseStandaloneSetup().createInjectorAndDoEMFRegistration();
	}

}
