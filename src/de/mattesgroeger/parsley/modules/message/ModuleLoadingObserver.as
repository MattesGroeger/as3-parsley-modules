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
package de.mattesgroeger.parsley.modules.message
{
	import de.mattesgroeger.parsley.modules.config.IModuleInfo;
	import de.mattesgroeger.parsley.modules.config.ModuleConfig;
	import de.mattesgroeger.parsley.modules.loading.ModuleLoader;

	import org.spicefactory.parsley.core.messaging.MessageProcessor;

	public class ModuleLoadingObserver
	{
		[Inject]
		public var moduleLoader:ModuleLoader;
		
		[Inject]
		public var moduleConfig:ModuleConfig;
		
		[MessageInterceptor(type="de.mattesgroeger.parsley.modules.message.ModuleMessage")]
		public function interceptSharedMessage(processor:MessageProcessor):void
		{
			var message:ModuleMessage = ModuleMessage(processor.message);
			var moduleInfo:IModuleInfo = moduleConfig.getInfoForMessage(message);
			var moduleId:String = moduleInfo.id;
			
			if (moduleLoader.isModuleLoaded(moduleId))
			{
				processor.proceed();
			}
			else
			{
				moduleLoader.loadModule(moduleId, processor);
			}
		}
	}
}