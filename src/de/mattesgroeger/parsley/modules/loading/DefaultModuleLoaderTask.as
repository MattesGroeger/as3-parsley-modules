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

	import org.spicefactory.lib.task.ResultTask;
	import org.spicefactory.parsley.core.messaging.MessageProcessor;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	public class DefaultModuleLoaderTask extends ResultTask implements ModuleLoaderTask
	{
		private static const LOADER_CONTEXT:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
		
		private var _moduleId:String;
		private var _moduleUrl:String;
		private var _module:Module;

		private var loader:Loader;
		private var processors : Vector.<MessageProcessor> = new Vector.<MessageProcessor>();

		public function DefaultModuleLoaderTask(moduleId:String, moduleUrl:String)
		{
			_moduleId = moduleId;
			_moduleUrl = moduleUrl;
			processors = new Vector.<MessageProcessor>();
		}

		public function get moduleId():String
		{
			return _moduleId;
		}

		public function get module():Module
		{
			return _module;
		}
		
		public function get processorCount() : uint
		{
			return processors.length;
		}
		
		public function getProcessorAtIndex( index : int ) : MessageProcessor
		{
			return processors[index];
		}
		
		public function removeProcessorAtIndex( index : int ) : void
		{
			processors.splice( index, 1 );
		}
	
		public function addProcessorForLoadingModule( processor : MessageProcessor ) : void
		{
			processors.push( processor );
		}

		protected override function doStart():void
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleComplete, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleError, false, 0, true);
			loader.load(new URLRequest(_moduleUrl), LOADER_CONTEXT);
			
			super.doStart();
		}
		
		protected override function doCancel():void
		{
			loader.close();
			
			super.doCancel();
		}

		private function handleError(event:IOErrorEvent):void
		{
			error(event.text);
		}

		private function handleComplete(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			
			_module = loaderInfo.content as Module;

			if (_module == null)
				error("Loaded module does not implement interface 'Module'!");
			else
				setResult(_module);
		}
	}
}