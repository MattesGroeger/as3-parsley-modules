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
	import de.mattesgroeger.parsley.modules.loading.support.MockMessageProcessor;
	import de.mattesgroeger.parsley.modules.loading.support.ModuleIds;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNull;

	public class DefaultModuleLoaderTaskTest
	{	
		[Test]
		public function task_creation():void
		{
			var moduleId:String = "test";
			var moduleUrl:String = "DemoModule.swf";

			var task:DefaultModuleLoaderTask = new DefaultModuleLoaderTask(moduleId, moduleUrl);

			assertEquals(moduleId, task.moduleId);
			assertNull(task.module);
			assertEquals("unexpected number of message processors", 0, task.processorCount);
		}
		
		[Test]
		public function test_add_and_get_message_processor() : void
		{
			var task:DefaultModuleLoaderTask = new DefaultModuleLoaderTask(ModuleIds.DEMO_MODULE_ID, "DemoModule.swf");
			var messageProcessor : MockMessageProcessor = new MockMessageProcessor();
			
			task.addProcessorForLoadingModule(messageProcessor);
			
			assertEquals("unexpected message processor", messageProcessor, task.getProcessorAtIndex(0));
		}
		
		[Test]
		public function test_remove_message_processor() : void
		{
			var task:DefaultModuleLoaderTask = new DefaultModuleLoaderTask(ModuleIds.DEMO_MODULE_ID, "DemoModule.swf");
			var messageProcessor : MockMessageProcessor = new MockMessageProcessor();
			
			task.addProcessorForLoadingModule(messageProcessor);
			task.removeProcessorAtIndex(0);
			
			assertEquals("unexpected number of message processors", 0, task.processorCount);
		}
	}
}