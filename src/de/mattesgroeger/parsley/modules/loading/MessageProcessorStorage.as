package de.mattesgroeger.parsley.modules.loading
{
	import org.spicefactory.parsley.core.messaging.MessageProcessor;
	
	public interface MessageProcessorStorage
	{
		function get processorCount():uint;

		function getProcessorAtIndex(index:int):MessageProcessor;
		
		function removeProcessorAtIndex(index:int):void

		function addProcessorForLoadingModule(processor:MessageProcessor):void;
	}
}