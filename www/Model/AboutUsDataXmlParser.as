class AboutUsDataXmlParser extends XmlParser
{
   private var m_oAboutUsData:Object;

   public function AboutUsDataXmlParser(sXmlPath:String)
   {
      super(sXmlPath);
	  //trace("AboutUsDataXmlParser::AboutUsDataXmlParser(" + sXmlPath + ")");
      m_sXmlPath = sXmlPath;
      setOnLoadParser(Fxn.FunctionProxy(this, parseAboutUsData));
   }

   private function parseAboutUsData():Void
   {
	  var xmlFirstChildNode:XMLNode = m_xmlData.firstChild;
	  m_oAboutUsData = new Object();
      var xmlNode:XMLNode = xmlFirstChildNode.childNodes[0];
      m_oAboutUsData["sHeader"] = xmlNode.childNodes[0].firstChild.nodeValue;
	  m_oAboutUsData["sText"] = xmlNode.childNodes[1].firstChild.nodeValue;
   }

   public function getAboutUsData():Object {return m_oAboutUsData;}
   public function getAboutUsHeader():String {return m_oAboutUsData["sHeader"];}
   public function getAboutUsText():String {return m_oAboutUsData["sText"];}

   public function destroy():Void
   {
      delete m_oAboutUsData;
      super.destroy();
   }
}