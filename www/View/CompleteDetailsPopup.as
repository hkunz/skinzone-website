import mx.transitions.*;
import mx.transitions.easing.*;

class CompleteDetailsPopup
{
   private var m_oWindow:MovieClipScroller;
   private var m_mcHolder:MovieClip;
   private var m_mcMask:MovieClip;
   private var m_mcScrollMask:MovieClip;
   private var m_mcPopup:MovieClip;
   private var m_mcDesc:MovieClip;
   private var m_sLinkage:String;
   private var m_cPopupTw:Tween;
   private var m_fIsPopupShown:Boolean;

   static private var TRANSITION_TIME:Number = 1.0;

   public function CompleteDetailsPopup(mcHolder:MovieClip)
   {
      m_mcHolder = mcHolder;
      m_fIsPopupShown = false;
   }

   public function createPopup(sLinkage:String):Boolean
   {
      var fExists:Boolean = false;
      m_mcHolder._visible = false;
      m_sLinkage = sLinkage;
	  m_mcDesc = m_mcHolder.attachMovie(sLinkage, sLinkage, 0);
      if(m_mcDesc != undefined)
      {
         fExists = true;
         m_mcPopup = m_mcHolder.attachMovie("CompleteDetailsPopup_MC", "Popup_MC", 0);
         m_mcMask = m_mcHolder.attachMovie("ShortDescMask_MC", "Mask_MC", 1);
         //m_mcDesc = m_mcPopup.attachMovie(sLinkage, m_sLinkage, 2);
         //m_mcDesc._x = 20;
         //m_mcDesc._y = 20;
         m_mcMask._width = m_mcPopup._width + 10;
         m_mcMask._height -= 15;
         m_mcPopup._alpha = 90;
         m_mcPopup._x = 51;
         m_mcPopup._y = 95;
         m_mcMask._x = 50;
         m_mcMask._y = 110;
         m_mcPopup.setMask(m_mcMask);
         /*m_mcPopup.onEnterFrame = function()
         {
            this.play();
            delete this.onEnterFrame;
		 }*/
	  }
      else trace("ERROR: Invalid Linkage: " + sLinkage);
      return fExists;
   }

   public function showPopup():Void
   {
      m_fIsPopupShown = true;
      createScrollContent();
      m_cPopupTw = new Tween(m_mcPopup, "_x", Strong.easeOut, -m_mcPopup._width/3, m_mcPopup._x, TRANSITION_TIME, true);
      m_cPopupTw.onMotionFinished = Fxn.FunctionProxy(this, attachScroller);
      //m_mcPopup._alpha = 90;
	  var cT:EventTimer = new EventTimer(Fxn.FunctionProxy(this, animateFold), 300);
      cT.StartTimer();
	  m_mcHolder._visible = true;
   }

   private function createScrollContent():Void
   {
      var nAdjust:Number = 20;
	  var mcContainer:MovieClip = m_mcPopup.createEmptyMovieClip("PopupScroller_MC", 1);
      m_oWindow = new MovieClipScroller(mcContainer);
      mcContainer._x += nAdjust;
      mcContainer._y += nAdjust;
	  //var oListener:Object = new Object();
      //oListener["onKnobPress"] = Fxn.FunctionProxy(this, onMenuStartScroll);
      //oListener["onKnobRelease"] = Fxn.FunctionProxy(this, onMenuStopScroll);
      //oListener["onVeScroll"] = null;
      //m_oWindow.addListener(oListener);
      var mcHolder:MovieClip = m_oWindow.getContainer();
      //mcHolder._alpha = 0;
      m_mcDesc = m_oWindow.setContentLinkage(m_sLinkage);
      m_mcScrollMask = m_oWindow.setGraphicMask("PopupScrollerMask_MC");
      m_oWindow.setEaseInTweenTime(0.5);
   }

   private function attachScroller():Void
   {
      var nAdjust:Number = 20;
	  var mcVeScroll:MovieClip = m_oWindow.setVeScroller("PopupScroller_MC");
      if(m_mcDesc._height <= m_mcScrollMask._height) m_oWindow.SetVeScrollEnabled(false);
      m_oWindow.setVeScrollerPosition(305.5 - nAdjust, 24.4 - nAdjust);
      new Tween(mcVeScroll, "_alpha", null, 0, 80, 0.5, true);
      //new Tween(m_mcDesc, "_alpha", null, 0, 100, 0.5, true);
   }

   private function animateFold():Void
   {
      m_mcPopup.play();
   }

   public function hidePopup(fFast:Boolean):Void
   {
      var nTime:Number = TRANSITION_TIME;
      if(true == fFast) nTime = 0.5;
      m_fIsPopupShown = false;
      m_cPopupTw.stopEnterFrame();
      new Tween(m_mcPopup, "_alpha", Strong.easeIn, m_mcPopup._alpha, 20, nTime, true);
	  m_cPopupTw = new Tween(m_mcPopup, "_x", Strong.easeIn, m_mcPopup._x, -m_mcPopup._width*0.7, nTime, true);
      m_cPopupTw.onMotionFinished = Fxn.FunctionProxy(this, removePopup);
      var mcVeScroll:MovieClip = m_oWindow.getVeScrollBar();
      mcVeScroll.removeMovieClip();
      m_mcPopup.gotoAndPlay("exit");
   }

   public function removePopup():Void
   {
      m_mcMask.removeMovieClip();
      m_mcPopup.removeMovieClip();
   }

   //public function getTween():Tween {return m_cPopupTw;}
   public function isPopupShown():Boolean {return m_fIsPopupShown;}
   public function getHolder():MovieClip {return m_mcHolder;}

   public function destroy():Void
   {
      m_mcHolder.removeMovieClip();
   }
}