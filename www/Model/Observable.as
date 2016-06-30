import mx.events.EventDispatcher

class Observable
{
   function addEventListener() {};
   function removeEventListener() {};
   function dispatchEvent() {};

   public function Observable()
   {
      mx.events.EventDispatcher.initialize(this);
   }

   public function notify():Void
   {
      var eventObject:Object = {target:this, type:'update'};	
      trace("'Notify' Event Dispatched");
      dispatchEvent(eventObject);
   }
	
   public function sendMsg(msg, oProps):Void
   {
      var eventObject:Object = {target:this, type:'Message', mesg:msg, oProps:oProps};
      trace("Message Sent: " + oEvent.type);
      dispatchEvent(oEvent);
   }
}



