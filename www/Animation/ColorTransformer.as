class ColorTransformer
{
   private var m_mcClip:MovieClip;
   private var m_oTransform:Object;
   private var m_cColor:Color;
   private var m_nPercRed:Number;
   private var m_nPercGreen:Number;
   private var m_nPercBlue:Number;
   private var m_nAdvRed:Number;
   private var m_nAdvGreen:Number;
   private var m_nAdvBlue:Number;

   public function ColorTransformer(mcClip:MovieClip)
   {
      //trace("ColorTransformer::ColorTransformer(" + mcClip + ")");
      m_mcClip = mcClip;
	  m_nPercRed = 100;
	  m_nPercGreen = 100;
	  m_nPercBlue = 100;
	  m_nAdvRed = 0;
	  m_nAdvGreen = 0;
	  m_nAdvBlue = 0;
   }

   public function SetColorEffect(Void):Void
   {
      //trace("ColorTransformer::SetColorEffect");
      m_cColor = new Color(m_mcClip);
      m_oTransform = new Object();
	  m_oTransform.ra = m_nPercRed;
	  m_oTransform.rb = m_nAdvRed;
	  m_oTransform.ga = m_nPercGreen;
	  m_oTransform.gb = m_nAdvGreen;
	  m_oTransform.ba = m_nPercBlue;
	  m_oTransform.bb = m_nAdvBlue;
	  m_oTransform.aa = 100;
	  m_oTransform.ab = 0;
	  m_cColor.setTransform(m_oTransform);
   }

   public function RemoveColorEffect(Void):Void
   {
      //trace("ColorTransformer::RemoveColorEffect");
      delete m_oTransform;
      m_oTransform = {ra:100, rb:0, ga:100, gb:0, ba:100, bb:0, aa:100, ab:0};
	  m_cColor.setTransform(m_oTransform);
      delete m_cColor;
      delete m_oTransform;
   }

   public function SetPercentRed(nRa:Number):Void {m_nPercRed = nRa;}
   public function SetPercentGreen(nGa:Number):Void {m_nPercGreen = nGa;}
   public function SetPercentBlue(nBa:Number):Void {m_nPercBlue = nBa;}
   public function SetAdvanceRed(nRb:Number):Void {m_nAdvRed = nRb;}
   public function SetAdvanceGreen(nGb:Number):Void {m_nAdvGreen = nGb;}
   public function SetAdvanceBlue(nBb:Number):Void {m_nAdvBlue = nBb;}

   public function destroy(Void):Void
   {
      trace("ColorTransformer::destroy");
      RemoveColorEffect();
	  m_mcClip = null;
   }
}