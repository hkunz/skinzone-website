class BubbleMenuButton extends GenericButton
{
   var oEmission:ParticleEmission;
   var cGlow:GlowHighlight;
   var cColorTransform:ColorTransformer;
   var m_pfFocusEvent:Function;
   var m_pfUnfocusEvent:Function;

   public function BubbleMenuButton(mcButton:MovieClip, fEnabled:Boolean)
   {
      super(mcButton, fEnabled);
	  //trace("BubbleMenuButton::BubbleMenuButton(" + mcButton + "," + fEnabled + ")");
	  var nDepth:Number = mcButton.getNextHighestDepth();
	  var mcClip:MovieClip = super.GetButtonClip();
	  cColorTransform = new ColorTransformer(mcClip);
	  cGlow = new GlowHighlight(mcClip);
	  /*
	  var mcEmission:MovieClip = mcButton.createEmptyMovieClip("mcEmission", nDepth, 0, 0);
      oEmission = new ParticleEmission(mcEmission);
	  oEmission.SetLinkageIds(["Emission"]);
      oEmission.SetContinuumRate(50);
	  oEmission.SetCurrentAngle(0);
      oEmission.SetGraphicLifeSpan(500);
	  oEmission.SetEmissionDirection(0);
	  oEmission.SetEmissionRange(0);
      oEmission.SetScaleReduction(0);
	  oEmission.SetAlphaReduction(100);
      oEmission.SetPosition(0, 0);
      oEmission.SetRadialDistance(mcButton._width/2);
      oEmission.SetAngleIncrement(10);
      oEmission.SetTolerance(0,0);
	  oEmission.SetRotationIncrement(10);
	  */
   }

   private function OnButtonUp(Void):Void
   {
      //trace("BubbleMenuButton::OnButtonUp");
      super.OnButtonUp();
	  m_pfUnfocusEvent.call(this, [GetButtonClip()._parent]);
	  oEmission.StopContinuum();
	  cGlow.RemoveFilter();
	  cColorTransform.RemoveColorEffect();
   }

   private function OnButtonOver(Void):Void
   {
      trace("BubbleMenuButton::OnButtonOver");
      super.OnButtonOver();
	  m_pfFocusEvent.apply(this, [GetButtonClip()._parent]);
	  
	  cColorTransform.SetAdvanceGreen();
	  cColorTransform.SetAdvanceRed(40);
	  cColorTransform.SetColorEffect();
	  //cGlow.SetColor(0xFFFFFF);
	  //cGlow.SetBlur(10);
	  //cGlow.AddFilter();
	  //*/
	  oEmission.StartContinuum();
   }

   private function OnButtonDown(Void):Void
   {
      //trace("BubbleMenuButton::OnButtonDown");
	  cGlow.RemoveFilter();
	  cColorTransform.RemoveColorEffect();
      super.OnButtonDown();
   }

   private function OnButtonRelease(Void):Void
   {
      //trace("BubbleMenuButton::OnButtonRelease");
	  m_pfUnfocusEvent.call(this, [GetButtonClip()._parent]);
	  cGlow.RemoveFilter();
	  cColorTransform.RemoveColorEffect();
      super.OnButtonRelease();
   }

   public function EnableButton(fEnabled:Boolean):Void
   {
      if(fEnabled == false) oEmission.StopContinuum();
	  super.EnableButton(fEnabled);
   }

   public function SetSelected(fSelected:Boolean):Void
   {
      var mcButton:MovieClip = super.GetParentContainer();
	  
	  if(false == fSelected)
	  {
         //cGlow.RemoveFilter();
		 //cColorTransform.RemoveColorEffect();
	  }
	  else
	  {
         /*
		 cColorTransform.SetAdvanceGreen(0);
	     cColorTransform.SetAdvanceRed(0);
		 cColorTransform.SetAdvanceBlue(0);
	     cColorTransform.SetColorEffect();
	     cGlow.SetColor(0xFFFF00);
	     cGlow.SetBlur(10);
	     cGlow.AddFilter();
		 */
		 mcButton.onPress = Fxn.FunctionProxy(this, EmptyFunction);
	  }
   }

   public function EmptyFunction(Void):Void
   {
	  trace("BubbleMenuButton::EmptyFunction");
   }

   public function SetFocusEvent(pfFocusEvent:Function):Void {m_pfFocusEvent = pfFocusEvent;}
   public function SetUnfocusEvent(pfUnfocusEvent:Function):Void {m_pfUnfocusEvent = pfUnfocusEvent;}

   public function destroy(Void):Void
   {
      trace("BubbleMenuButton::destroy");
      oEmission.StopContinuum();
      oEmission.destroy();
	  cGlow.destroy();
	  cColorTransform.destroy();
	  delete cGlow;
	  delete oEmission;
	  delete cColorTransform;
	  super.destroy();
   }
}