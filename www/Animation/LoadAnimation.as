class LoadAnimation
{
   private var m_mcContainer:MovieClip;
   private var m_oEmission:ParticleEmission;
   private var m_nType:Number;

   public function LoadAnimation(mcContainer:MovieClip)
   {
      m_mcContainer = mcContainer;
   }

   public function StartAnimation(nType:Number):Void
   {
      /*switch(nType)
	  {

	  }*/
	  
	  m_oEmission = new ParticleEmission(m_mcContainer);
	  m_oEmission.SetLinkageIds(["LoadType2_MC"]);
      m_oEmission.SetContinuumRate(200);
	  m_oEmission.SetCurrentAngle(-90);
      m_oEmission.SetGraphicLifeSpan(2000);
	  m_oEmission.SetEmissionDirection(0);
	  m_oEmission.SetEmissionRange(0);
      m_oEmission.SetScaleReduction(100);
	  m_oEmission.SetAlphaReduction(60);
      m_oEmission.SetPosition(0, 0);
      m_oEmission.SetRadialDistance(20);
      m_oEmission.SetAngleIncrement(20);
      m_oEmission.SetTolerance(0,0);
	  m_oEmission.SetRotationIncrement(0);
	  m_oEmission.StartContinuum();
   }

   public function centerLoadClip():Void
   {
      var mcParent:MovieClip = m_mcContainer._parent;
	  m_mcContainer._x = Constant.STAGE_WIDTH_HALF;
	  m_mcContainer._y = Constant.STAGE_HEIGHT_HALF;
   }

   public function StopAnimation(Void):Void
   {
      m_oEmission.StopContinuum();
   }

   public function destroy(Void):Void
   {
      StopAnimation();
      m_oEmission.destroy();
	  delete m_oEmission;
	  m_mcContainer.removeMovieClip();
   }
}