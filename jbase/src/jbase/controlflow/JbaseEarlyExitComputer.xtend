package jbase.controlflow

import com.google.common.collect.Lists
import com.google.inject.Inject
import java.util.Collection
import java.util.Collections
import org.eclipse.xtext.xbase.XCasePart
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.XSwitchExpression
import org.eclipse.xtext.xbase.controlflow.DefaultEarlyExitComputer

/**
 * Customization to take into account that in Java, switch's cases automatically fall through
 * without an explicit break.
 * 
 * @author Lorenzo Bettini
 */
class JbaseEarlyExitComputer extends DefaultEarlyExitComputer {

	@Inject extension JbaseBranchingStatementDetector

	override protected Collection<ExitPoint> _exitPoints(XSwitchExpression expression) {
		var Collection<ExitPoint> result = Lists.newArrayList()
		for (XCasePart casePart : expression.getCases()) {
			var XExpression then = casePart.getThen()
			var Collection<ExitPoint> caseExit = getExitPoints(then)
			// if there is not a break then in Java it is an automatic fall through
			// so we must not consider this case
			if(then.isSureBranchStatement && !isNotEmpty(caseExit)) {
				return Collections.emptyList()
			} else {
				result.addAll(caseExit)
			}
		}
		var Collection<ExitPoint> defaultExit = getExitPoints(expression.getDefault())
		if(!isNotEmpty(defaultExit)) {
			return Collections.emptyList()
		} else {
			result.addAll(defaultExit)
		}
		return result
	}
}