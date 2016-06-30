class PeopleTestiDataXmlParser extends XmlParser
{
   private var m_aoTestiData:Array;
   private var m_asImages:Array;

   public function PeopleTestiDataXmlParser(sXmlPath:String)
   {
      //trace("PeopleTestiDataXmlParser::PeopleTestiDataXmlParser(" + sXmlPath + ")");
      m_sXmlPath = sXmlPath;
      setOnLoadParser(Fxn.FunctionProxy(this, parseImageFileNames));
   }

   private function parseImageFileNames():Void
   {
	  var xmlFirstChildNode:XMLNode = m_xmlData.firstChild;
      var xmlNode:XMLNode = null;
      var sImageName:String = null;
      var sDescription:String = null;
      m_aoTestiData = new Array();
	  m_asImages = new Array();
	  
      for(var nIndex:Number = 0; nIndex < m_nMainNodes; nIndex++)
      {
         var oTestiData:Object = new Object();
         xmlNode = xmlFirstChildNode.childNodes[nIndex];
         oTestiData["sPerson"] = xmlNode.childNodes[0].firstChild.nodeValue;
         oTestiData["sTesti"] = xmlNode.childNodes[1].firstChild.nodeValue;
         var sThumb:String = xmlNode.childNodes[2].firstChild.nodeValue;
         oTestiData["sImage"] = xmlNode.childNodes[3].firstChild.nodeValue;
         oTestiData["sLabel"] = xmlNode.childNodes[4].firstChild.nodeValue;
         m_aoTestiData.push(oTestiData);
         m_asImages.push(sThumb);
         //trace("XML INFO: Image " + nIndex + ": " + sImageName);
      }
   }

   public function getTestiData():Array {return m_aoTestiData;}
   public function getImages():Array {return m_asImages;}

   public function destroy():Void
   {
      delete m_aoTestiData;
      super.destroy();
   }
}