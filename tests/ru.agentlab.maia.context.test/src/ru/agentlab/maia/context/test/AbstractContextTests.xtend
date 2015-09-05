package ru.agentlab.maia.context.test

import ru.agentlab.maia.context.IMaiaContext

import static org.mockito.Mockito.*

abstract class AbstractContextTests {

	def protected <T> IMaiaContext addParentWithService(IMaiaContext child, T service) {
		val parent = mock(IMaiaContext)
		when(parent.get(service.class)).thenReturn(service)
		when(parent.get(service.class.name)).thenReturn(service)
		when(child.parent).thenReturn(parent)
		return parent
	}

	def IMaiaContext getContext()

}