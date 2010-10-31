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
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.fail;

	import flash.errors.IllegalOperationError;

	public class ModuleConfigTest
	{
		private var moduleConfig:ModuleConfig;

		[Before]
		public function tearUp():void
		{
			moduleConfig = new ModuleConfig();
		}

		[After]
		public function tearDown():void
		{
			moduleConfig = null;
		}
		
		[Test]
		public function get_info_by_id():void
		{
			var moduleId:String = "test1";
			var moduleUrl:String = "test1.swf";
			moduleConfig.registerModule(moduleId, moduleUrl);
			
			var moduleInfo:IModuleInfo = moduleConfig.getInfoForId("test1");

			assertNotNull(moduleInfo);
			assertEquals(moduleId, moduleInfo.id);
			assertEquals(moduleUrl, moduleInfo.url);
		}
		
		[Test]
		public function get_info_by_id_which_has_not_been_registered_before():void
		{
			try
			{
				moduleConfig.getInfoForId("test");
			}
			catch (e:IllegalOperationError)
			{
				return;
			}
			
			fail("Error expected!");
		}
		
		[Test]
		public function get_info_by_trigger_message():void
		{
			var moduleId:String = "test2";
			var moduleUrl:String = "test2.swf";
			moduleConfig.registerModule(moduleId, moduleUrl, MockModuleMassage);

			var message:MockModuleMassage = new MockModuleMassage();
			var moduleInfo:IModuleInfo = moduleConfig.getInfoForMessage(message);

			assertNotNull(moduleInfo);
			assertEquals(moduleId, moduleInfo.id);
			assertEquals(moduleUrl, moduleInfo.url);
		}

		[Test]
		public function get_info_by_trigger_message_which_has_not_been_registered_before():void
		{
			try
			{
				var message:MockModuleMassage = new MockModuleMassage();
				moduleConfig.getInfoForMessage(message);
			}
			catch (e:IllegalOperationError)
			{
				return;
			}
			
			fail("exception expected");
		}
	}
}

import de.mattesgroeger.parsley.modules.message.ModuleMessage;

class MockModuleMassage implements ModuleMessage
{

}