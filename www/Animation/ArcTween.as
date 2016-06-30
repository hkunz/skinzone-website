import mx.transitions.*;
import mx.transitions.easing.*;

class ArcTween
{
   private var m_cTween:Tween;
   private var m_mcAngleTween:MovieClip;
   private var m_nCurAngle:Number;
   private var m_mcTween:MovieClip;
   private var m_nPivotX:Number;
   private var m_nPivotY:Number;
   private var m_nRadiusX:Number;
   private var m_nRadiusY:Number;
   private var m_nScaleStart:Number;
   private var m_nScaleEnd:Number;
   private var m_nAngleStart:Number;
   private var m_nAngleEnd:Number;
   private var m_nDuration:Number;
   private var m_pfEasing:Function;
   private var m_pfAnimationComplete:Function;
   private var m_pfOnAnimation:Function;
   private var m_aOnAnimParams:Array;
   private var m_fScaleModify:Boolean;

   public function ArcTween(mcTween:MovieClip)
   {
      //trace("ArcTween::ArcTween(" + mcTween + ")");
      m_mcTween = mcTween;
	  m_nRadiusX = 100;
	  m_nRadiusY = 100;
	  m_nScaleStart = 100;
	  m_nScaleEnd = 100;
	  m_nPivotX = 0;
	  m_nPivotY = 0;
	  m_nAngleStart = 0;
	  m_nAngleEnd = 0;
	  SetEasing(0);
      m_fScaleModify = true;
   }

   public function StartAnimation(Void):Void
   {
      //trace("ArcTween::StartAnimation");
	  m_mcAngleTween = new MovieClip();
      m_cTween.stopEnterFrame();
      m_cTween = new Tween(m_mcAngleTween, "_x", Strong.easeOut, m_nAngleStart, m_nAngleEnd, m_nDuration/1000, true);
	  m_cTween.onMotionChanged = Fxn.FunctionProxy(this, OnMotionChanged);
	  m_cTween.onMotionFinished = Fxn.FunctionProxy(this, OnMotionFinished);
   }

   private function OnMotionChanged(Void):Void
   {
      //trace("ArcTween::OnMotionChanged");
	  var nCurAngle:Number = m_mcAngleTween._x;
	  var nPercComplete:Number = 0;
      m_nCurAngle = nCurAngle;
	  //nCurAngle %= Constant.FULL_REVOLUTION;
	  if(m_pfOnAnimation != null)
	  {
         var nAngleRange:Number = m_nAngleStart - m_nAngleEnd;
         var nCoveredRange:Number = nCurAngle - m_nAngleEnd;
		 nPercComplete = (1 - (nCoveredRange / nAngleRange));
		 m_pfOnAnimation.call(this, [nPercComplete, m_aOnAnimParams]);
	  }
	  SetRatioScale(nCurAngle);
	  SetClipOnArc(nCurAngle);
   }

   private function OnMotionFinished(Void):Void
   {
      //trace("ArcTween::OnMotionFinished: End Angle: " + m_mcAngleTween._x);
      if(m_pfAnimationComplete != null) m_pfAnimationComplete.apply(this);
	  delete m_cTween.onMotionChanged;
	  delete m_cTween.onMotionFinished
      delete m_pfAnimationComplete;
      delete m_aOnAnimParams;
      delete m_pfOnAnimation;
      delete m_mcAngleTween;
	  //m_cTween.stopEnterFrame();
	  delete m_cTween;
	  m_mcAngleTween = null;
   }

   private function SetRatioScale(nCurAngle:Number):Void
   {
      //trace("ArcTween::SetRatioScale");
	  if(m_fScaleModify == true)
	  {
	     var nAngleRange:Number = m_nAngleEnd - m_nAngleStart;
	     var nSlope:Number = (m_nScaleEnd - m_nScaleStart) / nAngleRange;
	     var nIntercept:Number = m_nScaleStart - (m_nAngleStart  * nSlope);
	     var nScale:Number = (nSlope * nCurAngle) + nIntercept;
	     m_mcTween._xscale = nScale;
	     m_mcTween._yscale = nScale;
	  }
   }

   public function SetEasing(nEaseValue:Number):Void
   {
      //trace("ArcTween::SetRatioScale(" + nEaseValue + ")");
      switch(nEaseValue)
	  {
         case 0: m_pfEasing = Strong.easeOut; break;
		 case 1: m_pfEasing = Strong.easeIn; break;
         case 2: m_pfEasing = Strong.easeInOut; break;
		 default: m_pfEasing = null; break;
	  }
   }

   public function SetClipOnArc(nAngle:Number):Void
   {
      //trace("ArcTween::SetClipOnArc(" + nAngle + ")");
      m_nCurAngle = nAngle;
      m_mcTween._x = m_nPivotX + (m_nRadiusX * Fxn.Cos(nAngle));
      m_mcTween._y = m_nPivotY + (m_nRadiusY * Fxn.Sin(nAngle));
   }

   public function SetCompleteEvent(pfAnimationComplete:Function):Void {m_pfAnimationComplete = pfAnimationComplete;}
   public function SetOnAnimationEvent(pfOnAnimation:Function, aOnAnimParams:Array):Void {m_pfOnAnimation = pfOnAnimation; m_aOnAnimParams = aOnAnimParams;}
   public function removeOnAnimationEvent():Void {delete m_pfOnAnimation; delete m_aOnAnimParams;}
   public function SetDuration(nDuration:Number):Void {m_nDuration = nDuration;}
   public function SetRotationPivot(nX:Number, nY:Number):Void {m_nPivotX = nX; m_nPivotY = nY;}
   public function SetAngleRoute(nAngleStart:Number, nAngleEnd:Number):Void {m_nAngleStart = nAngleStart; m_nAngleEnd = nAngleEnd;}
   public function SetScale(nScaleStart:Number, nScaleEnd:Number):Void {m_nScaleStart = nScaleStart; m_nScaleEnd = nScaleEnd;}
   public function SetRadius(nRadiusX:Number, nRadiusY:Number):Void {m_nRadiusX = nRadiusX; m_nRadiusY = nRadiusY;}

   public function disableRatioScale():Void {m_fScaleModify = false;}
   public function getAngle():Number {return m_nCurAngle;}


   public function destroy(Void):Void
   {
      //trace("ArcTween::destroy");
	  m_cTween.stopEnterFrame();
	  delete m_pfEasing;
	  delete m_aOnAnimParams;
      delete m_pfOnAnimation;
	  delete m_pfAnimationComplete;
	  delete m_cTween.onMotionChanged;
	  delete m_cTween.onMotionFinished;
	  delete m_cTween;
	  delete m_mcAngleTween;
	  m_mcAngleTween = null;
	  m_mcTween = null;
   }
}