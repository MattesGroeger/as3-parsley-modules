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
	import de.mattesgroeger.parsley.modules.config.ModuleConfig;
	import de.mattesgroeger.parsley.modules.loading.support.ModuleIds;

	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.spicefactory.lib.task.events.TaskEvent;

	public class DefaultModuleLoaderTest
	{
		private var moduleConfig:ModuleConfig;
		private var moduleLoader:DefaultModuleLoader;

		[Before]
		public function tearUp():void
		{
			moduleConfig = new ModuleConfig();
			moduleConfig.registerModule(ModuleIds.DEMO_MODULE_ID, "DemoModule.swf");
			moduleConfig.registerModule(ModuleIds.NO_MODULE_ID, "NoModule.swf");

			moduleLoader = new DefaultModuleLoader();
			moduleLoader.moduleConfig = moduleConfig;
		}

		[After]
		public function tearDown():void
		{
			moduleConfig = null;
			moduleLoader = null;
		}

		[Test]
		public function module_is_not_loaded():void
		{
			var loaded:Boolean = moduleLoader.isModuleLoaded(ModuleIds.DEMO_MODULE_ID);

			assertFalse(loaded);
		}
		
		[Test]
		public function module_loading_started():void
		{
			moduleLoader.loadModule(ModuleIds.DEMO_MODULE_ID);
			
			var loaded:Boolean = moduleLoader.isModuleLoaded(ModuleIds.DEMO_MODULE_ID);

			assertFalse(loaded);
		}

		[Test(async)]
		public function module_loaded():void
		{
			var moduleLoadingTask:ModuleLoaderTask = moduleLoader.loadModule(ModuleIds.DEMO_MODULE_ID);
			moduleLoadingTask.addEventListener(TaskEvent.COMPLETE, Async.asyncHandler(this, handleModuleLoaded, 1000));
		}

		private function handleModuleLoaded(event:TaskEvent, passThroughData:Object):void
		{
			var task:ModuleLoaderTask = ModuleLoaderTask(event.target);
			
			assertTrue(moduleLoader.isModuleLoaded(task.moduleId));
		}
	}
}