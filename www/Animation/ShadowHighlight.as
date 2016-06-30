import flash.filters.DropShadowFilter;

class ShadowHighlight
{
   private var m_cShadow:DropShadowFilter;
   private var m_mcClip:MovieClip;
   private var m_nBlur:Number;
   private var m_nColor:Number;
   private static var FILTER_STRENGTH:Number = 1.6;
   private static var FILTER_QUALITY:Number = 3;

   public function ShadowHighlight(mcClip:MovieClip)
   {
      //trace("ShadowHighlight::ShadowHighlight");
      m_mcClip = mcClip;
	  m_nBlur = 0;
	  m_nColor = 0xFFFFFF;
   }

   public function AddFilter(Void):Void
   {
      m_cShadow = new DropShadowFilter();
	  m_cShadow.blurX = m_nBlur;
	  m_cShadow.blurY = m_nBlur;
	  m_cShadow.strength = FILTER_STRENGTH;
	  m_cShadow.quality = FILTER_QUALITY;
	  m_cShadow.color = m_nColor;
	  m_mcClip.filters = [m_cShadow];
   }

   public function RemoveFilter(Void):Void
   {
      m_mcClip.filters = null;
	  delete m_cShadow;
   }

   public function SetBlur(nBlur:Number):Void
   {
      m_nBlur = nBlur;
   }

   public function SetColor(nColor:Number):Void
   {
      m_nColor = nColor;
   }

   public function destroy(Void):Void
   {
      trace("ShadowHighlight::destroy");
      RemoveFilter();
	  delete m_cShadow;
	  m_mcClip = null;
   }
}