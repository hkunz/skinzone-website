class LocationDataXmlParser extends XmlParser
{
   private var m_aLocationData:Array;

   public function LocationDataXmlParser(sXmlPath:String)
   {
      super(sXmlPath);
	  //trace("LocationDataXmlParser::LocationDataXmlParser(" + sXmlPath + ")");
      m_sXmlPath = sXmlPath;
      setOnLoadParser(Fxn.FunctionProxy(this, parseLocationData));
   }

   private function parseLocationData():Void
   {
	  var xmlFirstChildNode:XMLNode = m_xmlData.firstChild;
	  m_aLocationData = new Array();
	  
      for(var nIndex:Number = 0; nIndex < m_nMainNodes; nIndex++)
      {
         var oLocData:Object = new Object();
         var xmlNode:XMLNode = xmlFirstChildNode.childNodes[nIndex];
         oLocData["sHeader"] = xmlNode.childNodes[0].firstChild.nodeValue;
         oLocData["sAddress1"] = xmlNode.childNodes[1].firstChild.nodeValue;
		 oLocData["sAddress2"] = xmlNode.childNodes[2].firstChild.nodeValue;
		 oLocData["sTel"] = xmlNode.childNodes[3].firstChild.nodeValue;
         oLocData["sCel"] = xmlNode.childNodes[4].firstChild.nodeValue;
		 oLocData["sOpen"] = xmlNode.childNodes[5].firstChild.nodeValue;
         var oMapData:Object = new Object();
		 var xmlMapNode:XMLNode = xmlNode.childNodes[6];
		 oMapData["sPath"] = xmlMapNode.firstChild.nodeValue;
		 oMapData["nLocX"] = parseInt(xmlMapNode.attributes["LocX"]);
		 oMapData["nLocY"] = parseInt(xmlMapNode.attributes["LocY"]);
		 oLocData["oMapData"] = oMapData;
		 oLocData["sPreview"] = xmlNode.childNodes[7].firstChild.nodeValue;
         oLocData["sEmail"] = xmlNode.childNodes[8].firstChild.nodeValue;
         oLocData["sGallery"] = xmlNode.childNodes[9].firstChild.nodeValue;
         m_aLocationData.push(oLocData);
      }
   }

   public function getLocationData():Array {return m_aLocationData;}

   public function destroy():Void
   {
      delete m_aLocationData;
      super.destroy();
   }
}