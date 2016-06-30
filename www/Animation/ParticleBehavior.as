//NOT COMPLETED
class ParticleBehavior
{
   private var m_oParticleEmission:GraphicContinuum;
   private var m_mcOnEnterFrame:MovieClip;
   private var m_aCoordinates:Array;
   private var m_nCoordinateIndex:Number;
   private var m_nPercDistancePerFrame:Number; //Distance based on Current Percent Graphic Width from one Graphic Center to Next
   private var m_nDistanceToNextPoint:Number;
   private var m_nDisplacementAngle:Number;
   private var m_nX:Number;
   private var m_nY:Number;
	
   public function ParticleBehavior(oParticleEmission:GraphicContinuum)
   {
      trace("ParticleBehavior::ParticleBehavior");
      m_oParticleEmission = oParticleEmission;
	  m_nX = 0;
	  m_nY = 0;
	  m_nCoordinateIndex = 0;
	  m_nDisplacementAngle = 0;
	  m_nDistanceToNextPoint = 0; //Cannot be determined until at least 1 coordinate is pushed
	  m_nPercDistancePerFrame = 1;
	  m_aCoordinates = new Array();
   }

   public function StartBehavior(Void):Void
   {
      var mcParticleEmission:MovieClip = m_oParticleEmission.GetParentContainer();
	  var nMaxGraphics:Number = m_oParticleEmission.GetMaxGraphics();
	  m_nDistanceToNextPoint = GetDistanceToNextCoordinate();
	  m_mcOnEnterFrame = mcParticleEmission.createEmptyMovieClip("mcBehavior", nMaxGraphics);
	  m_mcOnEnterFrame.onEnterFrame = Fxn.DelegateFunction(this, OnBehaviorEnterFrame);
	  m_oParticleEmission.StartContinuum();
   }

   private function GetDistanceToNextCoordinate(Void):Number
   {
      var oCoordinate:Object = m_aCoordinates[m_nCoordinateIndex];
	  var nX:Number = oCoordinate._x;
	  var nY:Number = oCoordinate._y;
	  m_nDisplacementAngle = Fxn.ArcTan((m_nY - nY)/(m_nX - nX));
	  return Fxn.Sqrt(Fxn.Pow(nX - m_nX, 2) + Fxn.Pow(nY - m_nY, 2));
   }

   private function OnBehaviorEnterFrame(Void):Void
   {
      var mcCurGraphic:MovieClip = m_oParticleEmission.GetCurrentGraphic();
      var oCoordinates:Object = m_aCoordinates[m_nCoordinateIndex];
	  var nX:Number = oCoordinates._x;
	  var nY:Number = oCoordinates._y;
	  //trace("nX: " + nX);
	  //trace("nY: " + nY);
	  
	  if(m_nDistanceToNextPoint == 0)
	  {
         m_nCoordinateIndex++;
	     m_nDistanceToNextPoint = GetDistanceToNextCoordinate();
	  }
	  else if((oCoordinates != null) && (mcCurGraphic != null))
	  {
         var nDiagonalDimension:Number = Fxn.Sqrt(Fxn.Pow(mcCurGraphic._width, 2) + Fxn.Pow(mcCurGraphic._height, 2))/2;
		 var nDiagonalStep:Number = nDiagonalDimension * m_nPercDistancePerFrame;
		 m_nX += nDiagonalStep * Fxn.Cos(m_nDisplacementAngle);
		 m_nY += nDiagonalStep * Fxn.Sin(m_nDisplacementAngle);
		 m_oParticleEmission.SetPosition(m_nX, m_nY);
		 if(m_nX > nX)
		 {
            m_nCoordinateIndex++;
			var oCoordinate:Object = m_aCoordinates[m_nCoordinateIndex];
	        var nX:Number = oCoordinate._x;
	        var nY:Number = oCoordinate._y;
			m_nX = nX;
			m_nY = nY;
			trace("NEXT: ");
			trace("m_nX: " + m_nX);
	        trace("m_nY: " + m_nY);
			m_nDisplacementAngle = GetDistanceToNextCoordinate();
         }
	  }
   }

   public function StopBehavior(Void):Void
   {
      delete m_mcOnEnterFrame.onEnterFrame;
	  m_mcOnEnterFrame.removeMovieClip();
      m_oParticleEmission.StopContinuum();
   }

   public function InitializeCoordinate(nX:Number, nY:Number):Void {m_nX = nX; m_nY = nY; m_oParticleEmission.SetPosition(nX, nY);}
   public function PushCoordinate(nX:Number, nY:Number):Void {m_aCoordinates.push({_x:nX, _y:nY});}
   public function PopCoordinate(Void):Object {return m_aCoordinates.pop();}

   public function destroy(Void):Void
   {
      StopBehavior();
      delete m_aCoordinates;
	  delete m_oParticleEmission;
	  delete m_mcOnEnterFrame.onEnterFrame;
	  m_mcOnEnterFrame.removeMovieClip();
   }
}