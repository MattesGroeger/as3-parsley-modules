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
package de.mattesgroeger.parsley.modules.config
{
	import de.mattesgroeger.parsley.modules.message.ModuleMessage;

	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;

	public class ModuleConfig
	{
		private var moduleIdRegistry:Dictionary = new Dictionary();

		public function registerModule(moduleId:String, moduleUrl:String, triggerMessageType:Class = null):void
		{
			var moduleInfo:ModuleInfo = new ModuleInfo(moduleId, moduleUrl, triggerMessageType);
			
			moduleIdRegistry[moduleId] = moduleInfo;
		}

		public function getInfoForId(moduleId:String):IModuleInfo
		{
			var moduleInfo:IModuleInfo = moduleIdRegistry[moduleId];

			if (moduleInfo == null)
				throw new IllegalOperationError("No module registerd for id '" + moduleId + "'");

			return moduleInfo;
		}

		public function getInfoForMessage(message:ModuleMessage):IModuleInfo
		{
			var triggerMessageType:Class;
			
			for each (var moduleInfo : IModuleInfo in moduleIdRegistry)
			{
				triggerMessageType = moduleInfo.triggerMessageType;
				
				if (triggerMessageType != null && message is triggerMessageType)
					return moduleInfo;
			}

			throw new IllegalOperationError("No module registerd for message '" + message + "'");
		}
	}
}

import de.mattesgroeger.parsley.modules.config.IModuleInfo;

class ModuleInfo implements IModuleInfo
{
	private var _moduleId:String;
	private var _moduleUrl:String;
	private var _triggerMessageType:Class;

	public function ModuleInfo(moduleId:String, moduleUrl:String, triggerMessageClass:Class)
	{
		_moduleId = moduleId;
		_moduleUrl = moduleUrl;
		_triggerMessageType = triggerMessageClass;
	}

	public function get id():String
	{
		return _moduleId;
	}

	public function get url():String
	{
		return _moduleUrl;
	}

	public function get triggerMessageType():Class
	{
		return _triggerMessageType;
	}
}