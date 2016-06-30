import mx.transitions.*;

class ViewDisable
{
   private var m_mcHolder:MovieClip;
   private var m_mcMask:MovieClip;
   private var m_mcContent:MovieClip;
   private var m_pView:MvcView;
   private var m_pfAnimStartComplete:Function;
   private var m_pfAnimExitComplete:Function;
   private var m_fViewEnabled:Boolean;

   public function ViewDisable(mcHolder:MovieClip, pView:MvcView)
   {
      m_pView = pView;
	  m_mcHolder = mcHolder;
      m_mcContent = m_mcHolder.attachMovie("ViewDisable_MC", "Content_MC", 0);
      m_mcMask = m_mcHolder.createEmptyMovieClip("Mask_MC", 1);
      m_mcHolder._alpha = 40;
	  m_mcHolder._x = 50;
      m_mcHolder._y = 105;
      m_mcContent.setMask(m_mcMask);
      m_fViewEnabled = true;
   }

   public function disableView():Void
   {
      m_mcHolder._visible = false;
      var mcShapes:MovieClip = m_mcMask.attachMovie("ViewDisableTween_MC", "Tween_MC", 0, {_x:0,_y:-80});
      mcShapes.onEnterFrame = Fxn.FunctionProxy(this, startAnimation, [mcShapes, "start"]);
      m_pView.setViewEnabled(false);
      m_fViewEnabled = false;
   }

   public function enableView(fNoAnim:Boolean):Void
   {
      var cT:EventTimer = null;
      var nTime:Number = 1500;
	  var mcShapes:MovieClip = m_mcMask["Tween_MC"];
      if(true == fNoAnim)
      {
	     onAnimationComplete(mcShapes, "exit");
         nTime = 1; //1 milisecond
	  }
      else mcShapes.onEnterFrame = Fxn.FunctionProxy(this, startAnimation, [mcShapes, "exit"]);
	  cT = new EventTimer(Fxn.FunctionProxy(m_pView, m_pView.setViewEnabled, [true]), nTime);
      cT.StartTimer();
      m_fViewEnabled = true;
   }

   private function onAnimationComplete(mcShapes:MovieClip, sBegin:String):Void
   {
      if(sBegin == "exit")
      {
         mcShapes.removeMovieClip();
         m_pfAnimExitComplete.apply(this);
	  }
      else if(sBegin == "start")
      {
         m_pfAnimStartComplete.apply(this);
	  }
   }

   private function startAnimation(mcShapes:MovieClip, sBegin:String):Void
   {
      var cT:EventTimer = null;
      var nTime:Number = 0;
      for(var sMc:String in mcShapes)
      {
         var mcShape:MovieClip = mcShapes[sMc];
         mcShape._visible = false;
         cT = new EventTimer(Fxn.FunctionProxy(this, animateShape, [mcShape, sBegin]), nTime);
         cT.StartTimer();
         nTime += 40;
	  }
      cT = new EventTimer(Fxn.FunctionProxy(this, onAnimationComplete, [mcShape, sBegin]), nTime + 600);
      cT.StartTimer();
	  m_mcHolder._visible = true;
      delete m_mcMask["Tween_MC"].onEnterFrame;
   }

   public function addListener(pfStartComplete:Function, pfExitComplete:Function):Void
   {
      m_pfAnimStartComplete = pfStartComplete;
	  m_pfAnimExitComplete = pfExitComplete;
   }

   public function removeListener():Void
   {
      delete m_pfAnimStartComplete;
      delete m_pfAnimExitComplete;
   }

   private function animateShape(mcShape:MovieClip, sBegin:String):Void
   {
      mcShape.gotoAndPlay(sBegin);
   }

   public function isViewEnabled():Boolean {return m_fViewEnabled;}

   public function destroy():Void
   {
      m_mcHolder.removeMovieClip();
      delete m_pfAnimStartComplete;
	  delete m_pfAnimExitComplete;
	  delete m_pView;
   }
}