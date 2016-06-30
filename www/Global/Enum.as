class Enum
{
   static public var STATE_INIT_ERROR:Number = -1;
   static public var STATE_INIT_CONTAINERS:Number = 0;
   static public var STATE_INIT_SYSTEM_FONT:Number = 1;
   static public var STATE_INIT_GRAPHICS:Number = 2;
   static public var STATE_INIT_MODEL_DATA:Number = 3;
   static public var STATE_INIT_SYSTEM_CONTROLLER:Number = 4;
   static public var STATE_INIT_COMPLETE:Number = 5;

   static public var VIEW_STATE_INITIALIZE:Number = 0;
   static public var VIEW_STATE_ENTRY_ANIMATION_START:Number = 1;
   static public var VIEW_STATE_EXIT_ANIMATION_START:Number = 2;
   static public var VIEW_STATE_ENTRY_ANIMATION_COMPLETE:Number = 3;
   static public var VIEW_STATE_EXIT_ANIMATION_COMPLETE:Number = 4;
   static public var VIEW_STATE_UP_RUNNING:Number = 5;
   static public var VIEW_STATE_READY_TO_DESTROY:Number = 6;

   //Main Views
   static public var VIEW_SYSTEM_HOME:Number = 0;
   static public var VIEW_ABOUT_US:Number = 1;
   static public var VIEW_LOCATION:Number = 2;
   static public var VIEW_SKINCARE_TIPS:Number = 3;
   static public var VIEW_TESTIMONIALS:Number = 4;
   static public var VIEW_WHATS_NEW:Number = 5;
   static public var VIEW_ABOUT_KUNZ:Number = 6;

   //Sub Views
   static public var VIEW_SZ_LOCATION_GALLERY:Number = 7;

   static public var MENU_DOCTOR_SERVICES:Number = 0;
   static public var MENU_SPA_SERVICES:Number = 1;
   static public var MENU_SALON_SERVICES:Number = 2;
   static public var MENU_SKINCARE_SERVICES:Number = 3;

   //FUNCTIONS FOR DEBUGGING PURPOSES ONLY
   /*
   static public function GetViewStateString(nViewState:Number):String
   {
      var sState:String = null;
      switch(nViewState)
	  {
         case VIEW_STATE_INITIALIZE: sState = "VIEW_STATE_INITIALIZE"; break;
	     case VIEW_STATE_ENTRY_ANIMATION_START: sState = "VIEW_STATE_ENTRY_ANIMATION_START"; break;
	     case VIEW_STATE_EXIT_ANIMATION_START: sState = "VIEW_STATE_EXIT_ANIMATION_START"; break;
	     case VIEW_STATE_ENTRY_ANIMATION_COMPLETE: sState = "VIEW_STATE_ENTRY_ANIMATION_COMPLETE"; break;
	     case VIEW_STATE_EXIT_ANIMATION_COMPLETE: sState = "VIEW_STATE_EXIT_ANIMATION_COMPLETE"; break;
	     case VIEW_STATE_UP_RUNNING: sState = "VIEW_STATE_UP_RUNNING"; break;
	     case VIEW_STATE_READY_TO_DESTROY: sState = "VIEW_STATE_READY_TO_DESTROY"; break;
		 default: sState = "UNDEFINED VIEW STATE"; break;
	  }
	  return sState;
   }
   */
   /*
   static public function GetMenuString(nMenu:Number):String
   {
      var sMenu:String = null;
      switch(nMenu)
	  {
         case MENU_SKINCARE_SERVICES: sMenu = "MENU_SKINCARE_SERVICES"; break;
	     case MENU_SALON_SERVICES: sMenu = "MENU_SALON_SERVICES"; break;
	     case MENU_SPA_SERVICES: sMenu = "MENU_SPA_SERVICES"; break;
	     case MENU_DOCTOR_SERVICES: sMenu = "MENU_DOCTOR_SERVICES"; break;
		 default: sMenu = "UNDEFINED MENU"; break;
	  }
	  return sMenu;
   }
   */
}