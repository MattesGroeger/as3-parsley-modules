/*
 * Copyright (c) 2010 Mattes Groeger
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package de.mattesgroeger.parsley.modules.loading
{
	import de.mattesgroeger.parsley.modules.loading.support.ModuleIds;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.async.Async;
	import org.spicefactory.lib.task.events.TaskEvent;
	import org.spicefactory.parsley.core.messaging.MessageProcessor;

	import flash.events.ErrorEvent;

	public class DefaultModuleLoaderTaskTest
	{
		[Test]
		public function task_creation():void
		{
			var moduleId:String = "test";
			var moduleUrl:String = "DemoModule.swf";
			var processor:MessageProcessor = new MockMessageProcessor();

			var task:DefaultModuleLoaderTask = new DefaultModuleLoaderTask(moduleId, moduleUrl, processor);

			assertEquals(moduleId, task.moduleId);
			assertEquals(processor, task.processor);
			assertNull(task.module);
		}

		[Test(async)]
		public function module_loading():void
		{
			var moduleLoadingTask:ModuleLoaderTask = new DefaultModuleLoaderTask(ModuleIds.DEMO_MODULE_ID, "DemoModule.swf", null);
			moduleLoadingTask.addEventListener(TaskEvent.COMPLETE, Async.asyncHandler(this, handleModuleLoaded, 1000));
		}

		private function handleModuleLoaded(event:TaskEvent, passThroughData:Object):void
		{
			var task:ModuleLoaderTask = ModuleLoaderTask(event.target);

			assertEquals(ModuleIds.DEMO_MODULE_ID, task.moduleId);
			assertNotNull(task.module);
		}

		[Test(async)]
		public function module_loading_fails():void
		{
			var moduleLoadingTask:ModuleLoaderTask = new DefaultModuleLoaderTask(ModuleIds.NO_MODULE_ID, "NoModule.swf", null);
			moduleLoadingTask.addEventListener(ErrorEvent.ERROR, Async.asyncHandler(this, handleModuleLoadedError, 1000));
		}

		private function handleModuleLoadedError(event:ErrorEvent, passThroughData:Object):void
		{
			var task:ModuleLoaderTask = ModuleLoaderTask(event.target);

			assertEquals(ModuleIds.NO_MODULE_ID, task.moduleId);
			assertNull(task.module);
		}
	}
}

import org.spicefactory.parsley.core.messaging.MessageProcessor;

class MockMessageProcessor implements MessageProcessor
{
	public function rewind():void
	{
	}

	public function proceed():void
	{
	}

	public function get message():Object
	{
		return null;
	}
}