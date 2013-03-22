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
	import de.mattesgroeger.parsley.modules.Module;
	import de.mattesgroeger.parsley.modules.config.ModuleConfig;

	import org.spicefactory.lib.task.SequentialTaskGroup;
	import org.spicefactory.lib.task.Task;
	import org.spicefactory.lib.task.events.TaskEvent;
	import org.spicefactory.parsley.core.context.Context;
	import org.spicefactory.parsley.core.messaging.MessageProcessor;

	import flash.events.ErrorEvent;
	import flash.utils.Dictionary;

	public class DefaultModuleLoader implements ModuleLoader
	{
		[Inject]
		public var context:Context;
		
		[Inject]
		public var moduleConfig:ModuleConfig;
		
		private var loadedModules:Dictionary = new Dictionary();
		private var loadingGroup:SequentialTaskGroup;

		public function DefaultModuleLoader()
		{
			loadingGroup = new SequentialTaskGroup();
			loadingGroup.autoStart = true;
			loadingGroup.ignoreChildErrors = true;
			
			loadingGroup.start();
		}
		
		public function isModuleLoaded(id:String):Boolean
		{
			return loadedModules[id] != null;
		}
		
		public function loadModule(id:String, processor:MessageProcessor = null):ModuleLoaderTask
		{
			var task : ModuleLoaderTask = getLoaderTaskForModuleId(id);
			
			if (task == null)
				task = startModuleLoading(id);	

			task.addProcessorForLoadingModule(processor);
			
			return task;
		}
		
		private function getLoaderTaskForModuleId(moduleId:String):ModuleLoaderTask
		{
			var loaderTask:ModuleLoaderTask;
			
			for (var i:int = 0; i < loadingGroup.size; i++) 
			{
				if (loadingGroup.getTask(i) is ModuleLoaderTask)
					loaderTask = ModuleLoaderTask(loadingGroup.getTask(i));
					
				if (loaderTask.moduleId == moduleId)
					break;
				else	
					loaderTask = null;
			}
			
			return loaderTask;
		}
		
		private function startModuleLoading(id:String):DefaultModuleLoaderTask
		{
			var moduleUrl:String = moduleConfig.getInfoForId(id).url;

			var task:DefaultModuleLoaderTask = new DefaultModuleLoaderTask(id, moduleUrl);
			task.addEventListener(TaskEvent.COMPLETE, handleTaskComplete);
			task.addEventListener(ErrorEvent.ERROR, handleTaskError);
			loadingGroup.addTask(task);
			
			return task;
		}

		private function handleTaskError(event:ErrorEvent):void
		{
			var task:DefaultModuleLoaderTask = DefaultModuleLoaderTask(event.target);
			cleanupTask(task);
			
			trace("Could not load module, for the following reason: " + event.text);
		}
		
		private function handleTaskComplete(event:TaskEvent):void
		{
			var task:DefaultModuleLoaderTask = DefaultModuleLoaderTask(event.target);
			
			initializeModule(task.moduleId, task.module);
			proceedMessages(task);
			cleanupTask(task);
		}

		private function initializeModule(id:String, module:Module):void
		{
			loadedModules[id] = module;
			module.initializeWithParentContext(context);
		}
		
		private function proceedMessages( loaderTask : ModuleLoaderTask ) : void
		{
			for(var i:int = 0; i < loaderTask.processorCount; i++) 
				proceedMessage(loaderTask.getProcessorAtIndex(i));
		}

		private function proceedMessage(processor:MessageProcessor):void
		{
			if (processor == null)
				return;
			
			processor.rewind();
			processor.proceed();
		}

		
		private function cleanupTask(task:ModuleLoaderTask):void
		{
			task.removeEventListener(TaskEvent.COMPLETE, handleTaskComplete);
			task.removeEventListener(ErrorEvent.ERROR, handleTaskError);
			
			while (task.processorCount > 0) 
				task.removeProcessorAtIndex(0);
			
			loadingGroup.removeTask(Task(task));
		}
	}
}