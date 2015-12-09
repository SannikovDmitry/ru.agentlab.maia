package ru.agentlab.maia.task.test.blackbox

import javax.inject.Provider
import org.jbehave.core.annotations.Given
import org.jbehave.core.annotations.Then
import org.jbehave.core.annotations.When
import ru.agentlab.maia.behaviour.BehaviourState
import ru.agentlab.maia.behaviour.IBehaviour
import ru.agentlab.maia.behaviour.IBehaviourScheduler

import static org.hamcrest.Matchers.*
import static org.junit.Assert.*
import static org.mockito.Mockito.*
import ru.agentlab.maia.behaviour.execution.ExecutionException

class AbstractTaskSchedulerExecuteSteps {

	val Provider<IBehaviourScheduler> provider

	new(Provider<IBehaviourScheduler> provider) {
		this.provider = provider
	}

	@Given("scheduler subtasks states are $states")
	def void givenSchedulerWithSubtasks(String statesString) {
		val String[] states = statesString.split(",")
		for (stateString : states) {
			val state = BehaviourState.valueOf(stateString.trim)
			val task = mock(IBehaviour) => [
				when(it.state).thenReturn(state)
				doAnswer[
					switch (state) {
						case WORKING: {
							provider.get.notifyChildWorking
						}
						case BLOCKED: {
							provider.get.notifyChildBlocked
						}
						case SUCCESS: {
							provider.get.notifyChildSuccess
						}
						case FAILED: {
							provider.get.notifyChildFailed(mock(ExecutionException))
						}
						default: {
							throw new IllegalArgumentException
						}
					}
					return null
				].when(it).execute
			]
			provider.get.addChild(task)
		}
	}

	@When("execute scheduler $times times")
	def void whenSchedulerExecuteSchedulerTimes(int times) {
		for (i : 0 ..< times) {
			provider.get.execute
		}
	}

	@Then("scheduler have $state state")
	def void thenSchedulerState(String state) {
		assertThat(provider.get.state, equalTo(BehaviourState.valueOf(state)))
	}

}