import flash.filters.GlowFilter;

class GlowHighlight
{
   private var m_cGlowFilter:GlowFilter;
   private var m_mcClip:MovieClip;
   private var m_nBlur:Number;
   private var m_nColor:Number;
   private static var FILTER_STRENGTH:Number = 1.6;
   private static var FILTER_QUALITY:Number = 3;

   public function GlowHighlight(mcClip:MovieClip)
   {
      //trace("GlowHighlight::GlowHighlight");
      m_mcClip = mcClip;
	  m_nBlur = 0;
	  m_nColor = 0xFFFFFF;
   }

   public function AddFilter(Void):Void
   {
      m_cGlowFilter = new GlowFilter();
	  m_cGlowFilter.blurX = m_nBlur;
	  m_cGlowFilter.blurY = m_nBlur;
	  m_cGlowFilter.strength = FILTER_STRENGTH;
	  m_cGlowFilter.quality = FILTER_QUALITY;
	  m_cGlowFilter.color = m_nColor;
	  m_mcClip.filters = [m_cGlowFilter];
   }

   public function RemoveFilter(Void):Void
   {
      m_mcClip.filters = null;
	  delete m_cGlowFilter;
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
      trace("GlowHighlight::destroy");
      RemoveFilter();
	  delete m_cGlowFilter;
	  m_mcClip = null;
   }
}