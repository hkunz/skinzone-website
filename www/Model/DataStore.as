class DataStore
{
   static private var m_fPromoWasShown:Boolean = false;
   static private var m_fPromoShowing:Boolean = false;
   static private var m_sGalleryName:String = null;
   static private var m_oMapData:Object = null;
   static private var m_aWhatsNewData:Array = null;
   static private var m_aTestiData:Array = null;
   static private var m_aTestiImages:Array = null;
   static private var m_aTipsData:Array = null;
   static private var m_oAboutUsData:Object = null;
   static private var m_aLocationData:Array = null;

   static public function wasPromoShown():Boolean {return m_fPromoWasShown;}
   static public function setPromoShown(fShown:Boolean) {m_fPromoWasShown = fShown;}
   static public function isPromoShowing():Boolean {return m_fPromoShowing;}
   static public function setPromoIsShowing(fShowing:Boolean):Void {m_fPromoShowing = fShowing;}

   static public function setGalleryName(sGalleryName:String) {m_sGalleryName = sGalleryName;}
   static public function getGalleryName():String {return m_sGalleryName;}

   static public function setMapData(oData:Object):Void {m_oMapData = oData;}
   static public function getMapData():Object {return m_oMapData;}

   static public function setWhatsNewXmlData(aXmlData:Array):Void {m_aWhatsNewData = aXmlData;}
   static public function getWhatsNewXmlData():Array {return m_aWhatsNewData;}

   static public function setTestiXmlData(aXmlData:Array):Void {m_aTestiData = aXmlData;}
   static public function getTestiXmlData():Array {return m_aTestiData;}

   static public function setImgTestiXmlData(aXmlData:Array):Void {m_aTestiImages = aXmlData;}
   static public function getImgTestiXmlData():Array {return m_aTestiImages;}

   static public function setTipsXmlData(aXmlData:Array):Void {m_aTipsData = aXmlData;}
   static public function getTipsXmlData():Array {return m_aTipsData;}

   static public function setLocationXmlData(aXmlData:Array):Void {m_aLocationData = aXmlData;}
   static public function getLocationXmlData():Array {return m_aLocationData;}

   static public function setAboutUsXmlData(oXmlData:Object):Void {m_oAboutUsData = oXmlData;}
   static public function getAboutUsXmlData():Object {return m_oAboutUsData;}
}