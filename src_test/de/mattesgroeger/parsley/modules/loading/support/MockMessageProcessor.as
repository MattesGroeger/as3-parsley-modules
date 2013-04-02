package de.mattesgroeger.parsley.modules.loading.support
{
	import org.spicefactory.parsley.core.messaging.MessageProcessor;
	 
	public class MockMessageProcessor implements MessageProcessor
	{
		private var _rewindCallCount:uint = 0;
		private var _proceedCallCount:uint = 0;
		
		public function get message():Object
		{
			return null;
		}
	
		public function get rewindCallCount() : uint
		{
			return _rewindCallCount;
		}
	
		public function get proceedCallCount() : uint
		{
			return _proceedCallCount;
		}
	
		public function rewind():void
		{
			_rewindCallCount++;
		}
	 
		public function proceed():void
		{
			_proceedCallCount++;
		}
	}
}