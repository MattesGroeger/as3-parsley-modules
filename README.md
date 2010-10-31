AS3 Parsley Modules
===================

The project provides an AS3-only module framework based on the [Parsley application framework](http://www.spicefactory.org/parsley/). Parsley supports Flex Modules by default but provides no alternative for AS3-only projects.

The project is currently in it's early stages. Further implementations, examples and documentation will follow.

Usage
-----

The first step is to initialise the context. Therefore, pass the provided `DefaultModuleContext` class to the `ActionScriptContextBuilder`.

	ActionScriptContextBuilder.buildAll([DefaultModuleContext, 
		YourOwnContext]);

This should happen in your main application, which then loads the other modules.

To define a module, the base class has to implement the `Module` interface. Compile these module then to its own SWF file (e.g. `DemoModule.swf`).

All modules then have to be registered in the `ModuleConfig` (you can inject the config, because it is in the context).

	moduleConfig.registerModule("demo_module", "DemoModule.swf");

To trigger the loading, a module can either directly access the `ModuleLoader` (inject it), or better use the [Parsley message system](http://www.spicefactory.org/parsley/docs/2.3/manual/messaging.php#injected_dispatchers). This way you can send a message which your target module should receive. If the module is not loaded yet, the event will be intercepted by the framework until the module has been loaded and initialised. This happens automatically, so the sender side does not have to take care of the module loading. Afterwards the event will be proceeded to the corresponding module. 

To receive this behaviour you have to follow these two steps.

1) Create a abstract message class that your module should receive/listen for:

	class AbstractDemoMessage implements ModuleMessage
	{
		// All messages that the corresponding module should 
		// receive have to extend this class.
	}

Note, that the message has to implement `ModuleMessage`. 

A concrete message can than look like this:

	class ShowItemMessage extends AbstractDemoMessage
	{
		public var item:Item;
		
		function ShowItemMessage(item:Item)
		{
			this.item = item;
		}
	}

2) Register your abstract message type to a specific module:

	moduleConfig.registerModule("demo_module", 
		"DemoModule.swf", AbstractDemoMessage);

Now, each time you dispatch an `ShowItemMessage` (either from the main application or another module) the corresponding module will be loaded (if not yet). All message handlers for this event will be called afterwards.

Upcoming features
-----------------

* Support of multiple triggers while a module currently loads
* Support of module unloading
* More sophisticated module initialisation (scopes, contexts)
* More sophisticated module loading (ApplicationDomains)
* Provide access to the loading progress