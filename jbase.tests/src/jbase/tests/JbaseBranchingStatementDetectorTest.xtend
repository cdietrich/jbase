package jbase.tests

import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.xbase.XExpression
import org.junit.Test
import org.junit.runner.RunWith
import jbase.JbaseInjectorProvider
import jbase.controlflow.JbaseBranchingStatementDetector

import static extension org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(JbaseInjectorProvider))
class JbaseBranchingStatementDetectorTest extends JbaseAbstractTest {
	
	static class JavammBranchingStatementDetectorCustom extends JbaseBranchingStatementDetector {
		
		// make it public to test it
		override sureBranch(XExpression e) {
			super.sureBranch(e)
		}
		
	}
	
	val detector = new JavammBranchingStatementDetectorCustom

	@Test(expected=IllegalArgumentException) 
	def void testNullInDispatchMethod() {
		detector.sureBranch(null)
	}

	@Test
	def void testNull() {
		detector.isSureBranchStatement(null).assertFalse
	}

	@Test
	def void testAnyStatement() {
		'''int i = 0;'''.assertIsSureBranchStatement(false)
	}

	@Test
	def void testContinue() {
		'''continue;'''.assertIsSureBranchStatement(true)
	}

	@Test
	def void testContinueInSingleThenBranch() {
		'''
		if (true)
			continue;
		'''.assertIsSureBranchStatement(true)
	}

	@Test
	def void testContinueInSingleElseBranch() {
		'''
		if (true) ;
		else
			continue;
		'''.assertIsSureBranchStatement(false)
	}

	@Test
	def void testContinueInThenBranch() {
		'''
		if (true)
			continue;
		else {
			
		}
		'''.assertIsSureBranchStatement(false)
	}

	@Test
	def void testContinueInElseBranch() {
		'''
		if (true) {
			
		} else {
			continue;
		}
		'''.assertIsSureBranchStatement(false)
	}

	@Test
	def void testContinueInBothBranches() {
		'''
		if (true)
			continue;
		else
			continue;
		'''.assertIsSureBranchStatement(true)
	}

	@Test
	def void testContinueInBothBranchesWithBlocks() {
		'''
		if (true) {
			continue;
		} else {
			continue;
		}
		'''.assertIsSureBranchStatement(true)
	}

	def private void assertIsSureBranchStatement(CharSequence input, boolean expected) {
		input.parse => [
			assertEquals(it.toString, expected, detector.isSureBranchStatement(it))			
		]
	}
}