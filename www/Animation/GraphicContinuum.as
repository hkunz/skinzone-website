class GraphicContinuum
{
   public var m_mcContainer:MovieClip; //Parent Container of All Graphics
   private var m_mcCurGraphic:MovieClip; //Current Graphic Created
   private var m_aLinkageIds:Array; //Linkage Id or Ids for Graphics to be used
   private var m_nLinkageIdIndex:Number; //Next Linkage Id Index
   private var m_nMaxGraphics:Number; //Maximum Graphics that can co-exist at any instance
   private var m_nGraphicIndex:Number; //nTH Graphic depth where m_nMaxGraphics is highest depth
   private var m_nX:Number; //Reference X Point where Created Graphics are positioned
   private var m_nY:Number; //Reference Y Point where Created Graphics are positioned
   private var m_nRadius:Number; //Radial Distance from Reference Position
   private var m_nToleranceX:Number; //Horizontal Tolerance to Reference Position for created Graphics
   private var m_nToleranceY:Number; //Vertical Tolerance to Reference Position for created Graphics
   private var m_nGraphicLifeSpan:Number; //Time Span in Milliseconds a Graphic exists
   private var m_nGraphicCreateRate:Number; //Graphic Creation Rate (Min: 50MS per Graphic)
   private var m_nGraphicCreateDelay:Number; //Graphic Creation Delay Counter for m_nGraphicCreateRate
   private var m_nCurrentAngle:Number; //Current Angle from Reference Point to Radial Point
   private var m_nAngleIncrement:Number; //Angle Increment for Graphics to appear around Circumference

   public function GraphicContinuum(mcContainer:MovieClip)
   {
      m_mcContainer = mcContainer;
	  m_nAngleIncrement = 0;
	  m_nLinkageIdIndex = 0;
	  m_nCurrentAngle = null; //Random Effect
	  m_nRadius = 0;
	  m_nGraphicCreateDelay = 0;
	  m_nGraphicIndex = 0;
	  m_nX = 0;
	  m_nY = 0;
	  m_nToleranceX = 0;
      m_nToleranceY = 0;
      m_nMaxGraphics = 100;
	  m_nGraphicLifeSpan = 1000;
	  m_nGraphicCreateRate = 100;
   }

   private function OnContainerEnterFrame(Void):Void
   {
	  //trace(m_nGraphicCreateDelay)
	  m_nGraphicCreateDelay += Constant.MILLISECONDS_PER_FRAME;
	  if(m_nGraphicCreateRate <= m_nGraphicCreateDelay)
	  {
         CreateGraphic({nAngle:GetCurrentAngle()});
		 m_nGraphicCreateDelay = 0;
	  }
   }

   public function CreateGraphic(oParameters:Object):Void //oParameters - Optional
   {
      var sLinkageId:String = m_aLinkageIds[m_nLinkageIdIndex];
	  var nAngle:Number = oParameters.nAngle;
      m_mcCurGraphic = m_mcContainer.attachMovie(sLinkageId, sLinkageId + m_nGraphicIndex, m_nGraphicIndex);
	  //_Position = Reference + RadialDistance + Tolerance
	  m_mcCurGraphic._x = m_nX + (m_nRadius*Fxn.Cos(nAngle)) + m_nToleranceX*(0.5 - Fxn.RandomNumber());
	  m_mcCurGraphic._y = m_nY + (m_nRadius*Fxn.Sin(nAngle)) + m_nToleranceY*(0.5 - Fxn.RandomNumber());
	  m_mcCurGraphic.nLifeSpan = m_nGraphicLifeSpan; //Append in order to save a timer
	  m_mcCurGraphic.onEnterFrame = Fxn.FunctionProxy(this, OnGraphicEnterFrame, [m_mcCurGraphic, oParameters]);
	  m_nGraphicIndex = (++m_nGraphicIndex) % (m_nMaxGraphics);
	  m_nLinkageIdIndex = (++m_nLinkageIdIndex) % (m_aLinkageIds.length);
   }

   private function OnGraphicEnterFrame(mcGraphic:MovieClip):Void
   {
      mcGraphic.nLifeSpan -= Constant.MILLISECONDS_PER_FRAME;
      if(mcGraphic.nLifeSpan <= 0)
      {
	      delete mcGraphic.onEnterFrame;
	      mcGraphic.removeMovieClip();
      }
   }

   public function GetCurrentAngle(Void):Number
   {
	  if(m_nCurrentAngle == null) return Fxn.RandomAngle();
	  else return (m_nCurrentAngle += m_nAngleIncrement);
   }

   public function SetLinkageIds(aLinkageIds:Array):Void {m_aLinkageIds = aLinkageIds;}
   public function SetContinuumRate(nTimeRate:Number):Void {m_nGraphicCreateRate = nTimeRate;} //Only can process intervals of 50MS to save processor resource 0-50;51-100;101-150
   public function SetGraphicLifeSpan(nTimeSpan:Number):Void {m_nGraphicLifeSpan = nTimeSpan;}
   public function SetPosition(nPosX:Number, nPosY:Number):Void {m_nX = nPosX; m_nY = nPosY;}
   public function SetRadialDistance(nRadius:Number):Void {m_nRadius = nRadius;}
   public function SetTolerance(nToleranceX:Number, nToleranceY:Number):Void {m_nToleranceX = nToleranceX; m_nToleranceY = nToleranceY;}
   public function SetCurrentAngle(nAngle:Number):Void {m_nCurrentAngle = nAngle;}
   public function SetAngleIncrement(nAngleIncrement:Number):Void {m_nAngleIncrement = nAngleIncrement;}
   public function StartContinuum(nType:Number):Void {m_mcContainer.onEnterFrame = Fxn.FunctionProxy(this, OnContainerEnterFrame);}
   public function StopContinuum(Void):Void {delete m_mcContainer.onEnterFrame;}
   public function GetParentContainer(Void):MovieClip {return m_mcContainer;}
   public function GetCurrentGraphic(Void):MovieClip {return m_mcCurGraphic;}
   public function GetMaxGraphics(Void):Number {return m_nMaxGraphics;}
   public function GetPosition(Void):Object {return {_x:m_nX, _y: m_nY};}

   public function destroy(Void):Void
   {
      trace("GraphicContinuum::destroy");
	  for(var sMc:String in m_mcContainer)
	  {
         var mcGraphic:MovieClip = m_mcContainer[sMc];
         delete mcGraphic.onEnterFrame;
		 mcGraphic.removeMovieClip();
	  }
	  delete m_aLinkageIds;
      delete m_mcContainer.onEnterFrame;
	  m_mcCurGraphic = null;
	  m_mcContainer.removeMovieClip();
   }
}