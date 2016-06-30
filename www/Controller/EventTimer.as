class EventTimer
{
   private var m_pfExpiryEvent:Function; //Function to be executed when Timer expires
   private var m_nTimerId:Number; //Timer ID returned by setInterval function
   private var m_nTimeDuration:Number; //Time in Milliseconds when Timer expires
   private var m_fTimerRepeat:Boolean; //Enable repeated Function Call after every m_nTimeDuration

   public function EventTimer(pfExpiryEvent:Function, nMilliSeconds:Number)
   {
      m_fTimerRepeat = false;
      m_nTimerId = null;
	  m_nTimeDuration = nMilliSeconds;
	  m_pfExpiryEvent = pfExpiryEvent;
	  if(m_nTimeDuration == null) m_nTimeDuration = 0;
   }

   public function SetEventFunction(pfExpiryEvent:Function):Void
   {
      m_pfExpiryEvent = pfExpiryEvent;
   }

   public function EnableTimerRepeat(fEnable:Boolean):Void
   {
      m_fTimerRepeat = fEnable;
   }

   public function SetExpiryTime(nMilliSeconds:Number):Void
   {
	  StopTimer();
      m_nTimeDuration = nMilliSeconds;
   }

   public function StartTimer(Void):Void
   {
      trace("EventTimer::StartTimer");
      StopTimer();
	  if(m_nTimeDuration > 0)
	  {
	     m_nTimerId = setInterval(Fxn.FunctionProxy(this, OnTimerExpired), m_nTimeDuration);
	  }
   }

   public function StopTimer(Void):Void
   {
      if(m_nTimerId != null)
      {
         clearInterval(m_nTimerId);
		 m_nTimerId = null;
      }
   }

   private function OnTimerExpired(Void):Void
   {
      trace("EventTimer::OnTimerExpired");
      if(m_fTimerRepeat == false)
	  {
	     StopTimer();
	  }
	  if(m_pfExpiryEvent!= null)
	  {
	     m_pfExpiryEvent.apply(this);
		 delete m_pfExpiryEvent;
	  }
   }

   public function destroy(Void):Void
   {
      trace("EventTimer::destroy");
      StopTimer();
	  delete m_pfExpiryEvent;
   }
}
