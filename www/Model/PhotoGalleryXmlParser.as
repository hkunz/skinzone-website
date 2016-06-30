class PhotoGalleryXmlParser extends XmlParser
{
   private var m_asImageFileNames:Array;
   private var m_asImageFileLabels:Array;

   public function PhotoGalleryXmlParser(sXmlPath:String)
   {
      //trace("PhotoGalleryXmlParser::PhotoGalleryXmlParser(" + sXmlPath + ")");
      m_sXmlPath = sXmlPath;
      setOnLoadParser(Fxn.FunctionProxy(this, parseImageFileNames));
   }

   private function parseImageFileNames():Void
   {
	  var xmlFirstChildNode:XMLNode = m_xmlData.firstChild;
      var xmlNode:XMLNode = null;
      var sImageName:String = null;
      var sDescription:String = null;
      m_asImageFileNames = new Array();
	  m_asImageFileLabels = new Array();
	  
      for(var nIndex:Number = 0; nIndex < m_nMainNodes; nIndex++)
      {
         xmlNode = xmlFirstChildNode.childNodes[nIndex];
         //sImageName = xmlNode.firstChild.nodeValue;
		 sImageName = xmlNode.childNodes[0].firstChild.nodeValue;
		 sDescription = xmlNode.childNodes[1].firstChild.nodeValue;
         m_asImageFileNames.push(sImageName);
         m_asImageFileLabels.push(sDescription);
         //trace("XML INFO: Image " + nIndex + ": " + sImageName);
      }
   }

   public function getImageFileNames():Array {return m_asImageFileNames;}
   public function getImageFileLabels():Array {return m_asImageFileLabels;}

   public function destroy():Void
   {
      delete m_asImageFileNames;
	  delete m_asImageFileLabels;
      super.destroy();
   }
}