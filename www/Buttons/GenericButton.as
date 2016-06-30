import mx.utils.Delegate;

class GenericButton
{
   private var m_mcButton:MovieClip;
   private var m_pfOnBtnUpEvent:Function;
   private var m_pfOnBtnOverEvent:Function;
   private var m_pfOnBtnDownEvent:Function;
   private var m_pfOnBtnReleaseEvent:Function;

   public function GenericButton(mcButton:MovieClip, fEnabled:Boolean)
   {
      //trace("GenericButton::GenericButton(" + mcButton + "," + fEnabled + ")");
      m_mcButton = mcButton;
	  EnableButton(fEnabled);
   }

   private function OnButtonUp(Void):Void
   {
      //trace("GenericButton::OnButtonUp");
	  m_mcButton.gotoAndStop("up");
	  m_pfOnBtnUpEvent.call(this);
   }

   private function OnButtonOver(Void):Void
   {
      //trace("GenericButton::OnButtonOver");
	  m_mcButton.gotoAndStop("over");
	  m_pfOnBtnOverEvent.call(this);
   }

   private function OnButtonDown(Void):Void
   {
      //trace("GenericButton::OnButtonDown");
      m_mcButton.gotoAndStop("down");
	  m_pfOnBtnDownEvent.call(this);
   }

   private function OnButtonRelease(Void):Void
   {
      //trace("GenericButton::OnButtonRelease");
      m_mcButton.gotoAndStop("over");
	  m_pfOnBtnReleaseEvent.call(this);
   }

   public function EnableButton(fEnabled:Boolean):Void
   {
      //trace("GenericButton::EnableButton(" + fEnabled + ")");
      if((true == fEnabled) || (undefined == fEnabled))
	  {
         m_mcButton.onPress = Delegate.create(this, OnButtonDown);
	     m_mcButton.onRollOut = Delegate.create(this, OnButtonUp);
		 m_mcButton.onReleaseOutside = Delegate.create(this, OnButtonUp);
	     m_mcButton.onRelease = Delegate.create(this, OnButtonRelease);
		 m_mcButton.onRollOver = Delegate.create(this, OnButtonOver);
		 m_mcButton.gotoAndStop("up");
	  }
	  else
	  {
         delete m_mcButton.onPress;
	     delete m_mcButton.onRollOut;
	     delete m_mcButton.onReleaseOutside;
	     delete m_mcButton.onRelease;
	     delete m_mcButton.onRollOver;
         m_mcButton.gotoAndStop("disabled");
	  }
   }

   public function GetParentContainer(Void):MovieClip
   {
      return m_mcButton;
   }

   public function SetButtonUpEvent(pfOnBtnUpEvent:Function)
   {
      //trace("GenericButton::SetButtonUpEvent(" + pfOnBtnUpEvent + ")");
      m_pfOnBtnUpEvent = pfOnBtnUpEvent;
   }

   public function SetButtonDownEvent(pfOnBtnDownEvent:Function)
   {
      //trace("GenericButton::SetButtonDownEvent(" + pfOnBtnDownEvent + ")");
      m_pfOnBtnDownEvent = pfOnBtnDownEvent;
   }

   public function SetButtonOverEvent(pfOnBtnOverEvent:Function)
   {
      //trace("GenericButton::SetButtonOverEvent(" + pfOnBtnOverEvent + ")");
      m_pfOnBtnOverEvent = pfOnBtnOverEvent;
   }

   public function SetButtonReleaseEvent(pfOnBtnReleaseEvent:Function)
   {
      //trace("GenericButton::SetButtonReleaseEvent(" + pfOnBtnReleaseEvent + ")");
      m_pfOnBtnReleaseEvent = pfOnBtnReleaseEvent;
   }

   public function GetButtonClip(Void) {return m_mcButton;}

   public function destroy(Void):Void
   {
      trace("GenericButton::destroy");
      delete m_pfOnBtnUpEvent;
      delete m_pfOnBtnOverEvent;
      delete m_pfOnBtnDownEvent;
      delete m_pfOnBtnReleaseEvent;
	  EnableButton(false);
      //m_mcButton.removeMovieClip();
	  m_mcButton = null;
   }
}