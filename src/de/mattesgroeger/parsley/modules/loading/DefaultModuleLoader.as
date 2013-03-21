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
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;

	public class DefaultModuleLoader implements ModuleLoader
	{
		[Inject]
		public var context:Context;
		
		[Inject]
		public var moduleConfig:ModuleConfig;
		
		private var loaderContext:LoaderContext;
		private var loadedModules:Dictionary = new Dictionary();
		private var processorsForLoadingModules:Dictionary = new Dictionary();
		private var loadingGroup:SequentialTaskGroup;

		public function DefaultModuleLoader()
		{
			loaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			
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
			var task:DefaultModuleLoaderTask;
			
			if (!isModuleLoading(id))
			{
				addProcessorForLoadingModule(id, processor);
				task = startModuleloading(id);	
			}
			else
			{
				addProcessorForLoadingModule(id, processor);
			}
			
			return task;
		}
		
		private function startModuleloading(id:String):DefaultModuleLoaderTask
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
			proceedMessages(task.moduleId);
			cleanupStoredMessageReferences(task.moduleId);
			cleanupTask(task);
		}

		private function initializeModule(id:String, module:Module):void
		{
			loadedModules[id] = module;
			module.initializeWithParentContext(context);
		}
		
		private function proceedMessages(id:String):void
		{
			var storedProcessors:Vector.<MessageProcessor> = Vector.<MessageProcessor>(processorsForLoadingModules[id]);
			
			for(var i:int = 0; i < storedProcessors.length; i++) 
				proceedMessage(storedProcessors[i]);
		}

		private function proceedMessage(processor:MessageProcessor):void
		{
			if (processor == null)
				return;
			
			processor.rewind();
			processor.proceed();
		}

		private function cleanupStoredMessageReferences(id:String):void
		{
			var storedProcessors:Vector.<MessageProcessor> = Vector.<MessageProcessor>(processorsForLoadingModules[id]);
			
			while(storedProcessors.length > 0) 
				storedProcessors.pop();
			
			delete processorsForLoadingModules[id];
		}
		
		private function cleanupTask(task:ModuleLoaderTask):void
		{
			task.removeEventListener(TaskEvent.COMPLETE, handleTaskComplete);
			task.removeEventListener(ErrorEvent.ERROR, handleTaskError);
			loadingGroup.removeTask(Task(task));
		}
		
		private function addProcessorForLoadingModule(id:String, processor:MessageProcessor):void
		{
			var storedProcessors:Vector.<MessageProcessor>;
			
			if (isModuleLoading(id))
			{
				storedProcessors = Vector.<MessageProcessor>(processorsForLoadingModules[id]);
			}
			else
			{
				storedProcessors = new Vector.<MessageProcessor>();
				processorsForLoadingModules[id] = storedProcessors;
			}
				
			storedProcessors.push(processor);
		}

		private function isModuleLoading(id:String):Boolean
		{
			return processorsForLoadingModules[id] != null;
		}
	}
}