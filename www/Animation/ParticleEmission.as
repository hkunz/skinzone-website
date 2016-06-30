class ParticleEmission extends GraphicContinuum
{
   private var m_nEmissionRange:Number;
   private var m_nAlphaReduction:Number;
   private var m_nScaleReduction:Number;
   private var m_nEmissionDirection:Number;
   private var m_nRotationInc:Number;

   public function ParticleEmission(mcContainer:MovieClip)
   {
      super(mcContainer);
	  m_nEmissionRange = 0;
	  m_nScaleReduction = 0;
	  m_nAlphaReduction = 0;
	  m_nRotationInc = 0;
	  m_nEmissionDirection = 1; //-1 for Inward Direction
   }

   public function CreateGraphic(Void):Void
   {
      var oParameters:Object = new Object();
	  var nAngle:Number = super.GetCurrentAngle();
	  var fEmissionRange:Boolean = (m_nEmissionRange != 0);
	  oParameters.nAngle = nAngle;
	  if(true == fEmissionRange)
	  {
         var nEmission:Number = -m_nEmissionDirection/m_nEmissionDirection * m_nEmissionRange;
	     oParameters._x = nEmission * Fxn.Cos(nAngle);
	     oParameters._y = nEmission * Fxn.Sin(nAngle);
	  }
	  super.CreateGraphic(oParameters);
	  if((true == fEmissionRange) && (m_nEmissionDirection < 0))
	  {
         var mcCurGraphic:MovieClip = super.GetCurrentGraphic();
         mcCurGraphic._x += m_nEmissionRange * Fxn.Cos(nAngle);
	     mcCurGraphic._y += m_nEmissionRange * Fxn.Sin(nAngle);
	  }
   }

   private function OnGraphicEnterFrame(mcGraphic:MovieClip, oParameters:Object):Void
   {
      super.OnGraphicEnterFrame(mcGraphic);
	  var nPercDec:Number = Constant.MILLISECONDS_PER_FRAME / m_nGraphicLifeSpan;
	  var nIncX:Number = nPercDec * oParameters._x;
	  var nIncY:Number = nPercDec * oParameters._y;
	  mcGraphic._x += nIncX;
	  mcGraphic._y += nIncY;
	  mcGraphic._xscale -= m_nScaleReduction * nPercDec;
	  mcGraphic._yscale -= m_nScaleReduction * nPercDec;
      mcGraphic._alpha -= m_nAlphaReduction * nPercDec;
	  mcGraphic._rotation += m_nRotationInc;
   }

   public function SetScaleReduction(nPercReduction:Number):Void {m_nScaleReduction = nPercReduction;}
   public function SetAlphaReduction(nPercReduction:Number):Void {m_nAlphaReduction = nPercReduction;}
   public function SetEmissionRange(nRange:Number):Void {m_nEmissionRange = nRange;}
   public function SetEmissionDirection(nDirection:Number):Void {m_nEmissionDirection = nDirection;}
   public function SetRotationIncrement(nAngleInc:Number):Void {m_nRotationInc = nAngleInc;}
   public function destroy(Void):Void {super.destroy();}
}