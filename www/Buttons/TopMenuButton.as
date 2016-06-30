class TopMenuButton extends GenericButton
{
   var oEmission:ParticleEmission;

   public function TopMenuButton(mcButton:MovieClip, fEnabled:Boolean)
   {
      super(mcButton, fEnabled);
	  mcButton.stop();
	  //trace("TopMenuButton::TopMenuButton(" + mcButton + "," + fEnabled + ")");
	  var mcEmission:MovieClip = mcButton.createEmptyMovieClip("mcEmission", 0, 0, 0);
      oEmission = new ParticleEmission(mcEmission);
	  oEmission.SetLinkageIds(["TopMenuAnimGraphic_MC"]);
      oEmission.SetContinuumRate(250);
	  oEmission.SetCurrentAngle(-90);
      oEmission.SetGraphicLifeSpan(2000);
	  oEmission.SetEmissionDirection(1);
	  oEmission.SetEmissionRange(50);
      oEmission.SetScaleReduction(0);
	  oEmission.SetAlphaReduction(100);
      oEmission.SetPosition(mcButton._width/2, 0);
      oEmission.SetRadialDistance(0);
      oEmission.SetAngleIncrement(0);
      oEmission.SetTolerance(50,0);
	  oEmission.SetRotationIncrement(0);
   }

   private function OnButtonUp(Void):Void
   {
      //trace("TopMenuButton::OnButtonUp");
      super.OnButtonUp();
	  oEmission.StopContinuum();
   }

   private function OnButtonOver(Void):Void
   {
      //trace("TopMenuButton::OnButtonOver");
      super.OnButtonOver();
	  oEmission.StartContinuum();
   }

   private function OnButtonDown(Void):Void
   {
      //trace("TopMenuButton::OnButtonDown");
      super.OnButtonDown();
	  oEmission.StopContinuum();
   }

   private function OnButtonRelease(Void):Void
   {
      //trace("TopMenuButton::OnButtonRelease");
      super.OnButtonRelease();
   }

   public function destroy(Void):Void
   {
      //trace("TopMenuButton::destroy");
      oEmission.StopContinuum();
      oEmission.destroy();
	  delete oEmission;
	  super.destroy();
   }
}