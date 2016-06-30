import mx.transitions.*;
import mx.transitions.easing.*;

class ShortDescriptionPopup
{
   private var m_mcContainer:MovieClip;
   private var m_mcMask:MovieClip;
   private var m_mcPopup:MovieClip;
   private var m_mcText:MovieClip;
   static private var TRANSITION_TIME:Number = 0.5;

   public function ShortDescriptionPopup(mcContainer:MovieClip)
   {
      m_mcContainer = mcContainer;
      m_mcPopup = Fxn.AttachGraphic(m_mcContainer, "ShortDescriptionPopup_MC", 0, 50, -370);
      m_mcMask = Fxn.AttachGraphic(m_mcContainer, "ShortDescMask_MC", 1, 50, 105);
	  m_mcPopup._alpha = 85;
      m_mcPopup.setMask(m_mcMask);
      m_mcPopup = m_mcPopup["ShortDescriptionPopup_MC"];
      m_mcPopup.gotoAndStop(1);
   }

   public function showSubMenu(sLinkage:String):Void
   {
      var nCurFrame:Number = m_mcPopup._currentframe;
	  var nStartFrame:Number = 25;
      var nEndFrame:Number = 34;
      var nPercComplete:Number = (nCurFrame - nStartFrame) / (nEndFrame - nStartFrame);
      var nFullLenY:Number = 105;
      var nFullLen:Number = 370;
	  nStartFrame = 2;
      nEndFrame = 10;
	  if(nCurFrame <= nStartFrame) nPercComplete = 100;
      else nCurFrame = nStartFrame + Fxn.RoundOff((nEndFrame - nStartFrame)*(1.00 - nPercComplete));
	  m_mcPopup.gotoAndPlay(nCurFrame);
      AttachText(sLinkage);
      nFullLenY -= (nFullLen - m_mcText._height - 70);
      //nFullLenY = 105;
      new Tween(m_mcPopup, "_y", Strong.easeOut, m_mcPopup._y, nFullLenY, TRANSITION_TIME, true);
   }

   private function AttachText(sLinkage:String):Void
   {
      var nSubMenuHight:Number = 335;
      m_mcText.removeMovieClip();
      m_mcText = m_mcPopup.createEmptyMovieClip("Text_MC", 10);
	  m_mcText.attachMovie(sLinkage, sLinkage, 0);
	  m_mcText._x = 12;
	  m_mcText._y = nSubMenuHight - m_mcText._height - 30;
   }

   public function hideSubMenu():Void
   {
      var nCurFrame:Number = m_mcPopup._currentframe;
	  var nStartFrame:Number = 1;
      var nEndFrame:Number = 10;
      var nPercComplete:Number = (nCurFrame - nStartFrame) / (nEndFrame - nStartFrame);
	  nStartFrame = 25;
      nEndFrame = 34;
      nCurFrame = nStartFrame + Fxn.RoundOff((nEndFrame - nStartFrame)*(1.00 - nPercComplete));
	  m_mcPopup.gotoAndPlay(nCurFrame);
      new Tween(m_mcPopup, "_y", Strong.easeIn, m_mcPopup._y, -370, TRANSITION_TIME, true);
   }

   public function destroy():Void
   {
      m_mcContainer.removeMovieClip();

   }
}