package jbase.tests

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.typesystem.IBatchTypeResolver
import org.eclipse.xtext.xbase.typesystem.references.LightweightTypeReference
import org.junit.Test
import org.junit.runner.RunWith
import jbase.JbaseInjectorProvider
import jbase.tests.util.SimpleJvmModelTestInjectorProvider
import jbase.jbase.XJVariableDeclaration

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(JbaseInjectorProvider))
class JbaseTypeComputerTest extends JbaseAbstractTest {

	@Inject
	IBatchTypeResolver typeResolver;

	@Test
	def testStringLiteral() {
		'''"a"'''.assertActualType("java.lang.String")
	}

	@Test
	def testCharLiteral() {
		"'a'".assertActualType("char")
	}

	@Test
	def testCharLiteralWithCharExpectation() {
		"char c = 'a'".assertVarExpressionActualType("char")
	}

	@Test
	def testCharLiteralWithIntExpectation() {
		"int c = 'a'".assertVarExpressionActualType("int")
	}

	@Test
	def testCharLiteralWithStringExpectation() {
		"String c = 'a'".assertVarExpressionActualType("char")
	}

	@Test
	def testCharLiteralWithVoidExpectation() {
		"void c = 'a'".assertVarExpressionActualType("char")
	}

	@Test
	def testCharLiteralWithBooleanExpectation() {
		"boolean c = 'a'".assertVarExpressionActualType("char")
	}

	@Test
	def testNumberLiteral() {
		"0".assertActualType("int")
	}

	@Test
	def testNumberLiteralWithByteExpectation() {
		"byte b = 0".assertVarExpressionActualType("byte")
	}

	@Test
	def testNumberLiteralWithShortExpectation() {
		"short b = 0".assertVarExpressionActualType("short")
	}

	@Test
	def testNumberLiteralWithShortExpectationGreaterThanMaxShort() {
		"short b = 32768".assertVarExpressionActualType("int")
	}

	@Test
	def testNumberLiteralWithCharExpectation() {
		"char b = 0".assertVarExpressionActualType("char")
	}

	@Test
	def testNumberLiteralWithCharExpectationGreaterThanMaxChar() {
		"char b = 65536".assertVarExpressionActualType("int")
	}

	@Test
	def testNumberLiteralWithLongExpectation() {
		"long b = 65536".assertVarExpressionActualType("int")
	}

	@Test
	def testNumberLiteralWithString() {
		"String b = 65536".assertVarExpressionActualType("int")
	}

	@Test
	def testNumberLiteralInBinaryOperation() {
		"int i = 1 + 128".assertVarExpressionActualType("int")
	}

	@Test
	def void testAdditionalVars() {
		"int i, j, k;".assertLastExpression[
			val varDecl = variableDeclaration
			varDecl.additionalVariables.forEach[
				assertActualType("void")
			]
		]
	}

	@Test
	def void testAdditionalVarsAddedToScope() {
		'''
		int i, j, k;
		j;
		'''.assertActualType("int")
	}

	@Test
	def void testInstanceOfDoesNotImplyImplicitCast() {
		'''
		Object o;
		if (o instanceof java.util.Date)
			o
		'''.assertLastExpression[
			ifStatement.then.assertActualType("java.lang.Object")
		]
	}

	@Test
	def void testReassignTypeDelegatedToSuper() {
		'''
		Object o;
		if (o != null)
			o
		'''.assertLastExpression[
			ifStatement.then.assertActualType("java.lang.Object")
		]
	}

	@Test
	def void testXAssignment() {
		'''
		int i;
		i = "a"
		'''.assertActualType("int")
	}

	@Test
	def void testXJAssignment() {
		'''
		int[] i;
		i[0] = "a"
		'''.assertActualType("int[]") // the type of the declared variable
	}

	@Test
	def void testXJAssignment2() {
		'''
		int i;
		i[0] = "a"
		'''.assertActualType("int") // the type of the declared variable
	}

	@Test
	def void testXJAssignment3() {
		'''
		i[0] = "a"
		'''.assertActualType("Object") // the variable is not declared
	}

	@Test
	def void testSwitch() {
		'''
		switch (argsNum) {
			case 0 : System.out.println("0");
			default: System.out.println("default");
		}
		'''.assertExpression[
			assertReturnType("void")
		]
	}

	@Test
	def void testSwitchWithoutCase() {
		'''
		switch (argsNum) {
			case 
			default: System.out.println("default");
		}
		'''.assertExpression[
			assertReturnType("null")
		]
	}

	@Test
	def void testSwitchWithoutCaseThen() {
		'''
		switch (argsNum) {
			case 0 :
			default: System.out.println("default");
		}
		'''.assertExpression[
			assertReturnType("void")
		]
	}

	@Test
	def void testSwitchWithReturn() {
		'''
		switch (argsNum) {
			case 0 : return "0";
			default: return "1";
		}
		'''.assertExpression[
			assertReturnType("java.lang.String")
		]
	}

	@Test
	def void testSwitchWithCaseWithBreak() {
		'''
		switch (argsNum) {
			case 0 : System.out.println("0"); break;
			default: return "1";
		}
		'''.assertExpression[
			assertReturnType("java.lang.String")
		]
	}

	@Test
	def void testSwitchWithReturnAndExpectation() {
		new SimpleJvmModelTestInjectorProvider().injector.injectMembers(this)
		
		'''
		switch (argsNum) {
			case 0 : return "0";
			default: return "1";
		}
		'''.assertExpression[
			assertReturnType("java.lang.String")
		]
	}

	@Test
	def void testSwitchWithReturnAndExpectationWithoutDefault() {
		new SimpleJvmModelTestInjectorProvider().injector.injectMembers(this)

		// this is not valid since the default is missing, but there'll
		// be a specific error for that

		'''
		switch (argsNum) {
			case 0 : return "0";
		}
		'''.assertExpression[
			assertReturnType("java.lang.String")
		]
	}

	@Test
	def void testSwitchWithoutDefault() {
		'''
		switch (argsNum) {
			case 0 : System.out.println("0");
			case 1 : System.out.println("1");
		}
		'''.assertExpression[
			assertReturnType("null") // any type ref
		]
	}

	@Test
	def void testMemberFeatureCallOnArray() {
		'''
		i[0].toString();
		'''.assertLastExpression[
			assertActualType("Object")
		]
	}

	@Test
	def void testMemberFeatureCallOnArray2() {
		'''
		Integer[] i;
		i[0].toString();
		'''.assertLastExpression[
			assertActualType("java.lang.String")
		]
	}

	@Test
	def void testArrayConstructorCall() {
		'''
		new String[1];
		'''.assertLastExpression[
			assertActualType("java.lang.String[]")
		]
	}

	@Test
	def void testArrayConstructorCallWithArrayLiteral() {
		'''
		new String[1] { 0 };
		'''.assertLastExpression[
			assertActualType("java.lang.String[]")
		]
	}

	@Test
	def void testBranchingStatement() {
		'''
		continue;
		'''.assertLastExpression[
			assertActualType("void")
		]
	}

	@Test
	def void testClassObject() {
		'''
		String.class;
		'''.assertLastExpression[
			assertActualType("java.lang.Class<java.lang.String>")
		]
	}

	@Test
	def void testClassObjectWithArrayDimensions() {
		'''
		String[].class;
		'''.assertLastExpression[
			assertActualType("java.lang.Class<java.lang.String[]>")
		]
	}

	@Test
	def void testClassObjectWithWrongTypeExpression() {
		// this is not valid, but there will be an error for that
		'''
		String s;
		s.class;
		'''.assertLastExpression[
			assertActualType("java.lang.String")
		]
	}

	@Test
	def void testClassObjectWithWrongTypeExpression2() {
		// this is not valid, but there will be an error for that
		'''
		new String().class;
		'''.assertLastExpression[
			assertActualType("java.lang.String")
		]
	}

	@Test
	def void testTypeAsTypeLiteral() {
		// this is valid in Xbase
		// we'll have an error for that
		'''
		Class c = String;
		'''.assertLastExpression[
			variableDeclaration.right.
			assertActualType("java.lang.Class<java.lang.String>")
		]
	}

	def private void assertActualType(CharSequence input, String expectedTypeName) throws Exception {
		input.assertLastExpression[
			assertActualType(expectedTypeName)
		]
	}

	def private void assertVarExpressionActualType(CharSequence input, String expectedTypeName) throws Exception {
		input.assertLastExpression[
			assertActualType((it as XJVariableDeclaration).right, expectedTypeName)
		]
	}

	def private void assertActualType(XExpression e, String expectedTypeName) {
		val typeRef = e.getActualType
		assertType(e, typeRef, expectedTypeName)
	}

	def private void assertReturnType(XExpression e, String expectedTypeName) {
		val typeRef = e.getReturnType
		assertType(e, typeRef, expectedTypeName)
	}
	
	private def assertType(XExpression e, LightweightTypeReference typeRef, String expectedTypeName) {
		assertNotNull("type ref was null for " + e, typeRef)
		assertEquals("expression " + e.class.simpleName + ": " + e, expectedTypeName, toString(typeRef))
	}

	def private LightweightTypeReference getActualType(XExpression expression) {
		return typeResolver.resolveTypes(expression).getActualType(expression);
	}

	def private LightweightTypeReference getReturnType(XExpression expression) {
		return typeResolver.resolveTypes(expression).getReturnType(expression);
	}

	def private String toString(LightweightTypeReference typeref) {
		return typeref.getIdentifier();
	}
}