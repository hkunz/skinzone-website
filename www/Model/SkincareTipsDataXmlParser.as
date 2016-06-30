class SkincareTipsDataXmlParser extends XmlParser
{
   private var m_aTipsData:Array;

   public function SkincareTipsDataXmlParser(sXmlPath:String)
   {
      super(sXmlPath);
	  //trace("SkincareTipsDataXmlParser::SkincareTipsDataXmlParser(" + sXmlPath + ")");
      m_sXmlPath = sXmlPath;
      setOnLoadParser(Fxn.FunctionProxy(this, parseLocationData));
   }

   private function parseLocationData():Void
   {
	  var xmlFirstChildNode:XMLNode = m_xmlData.firstChild;
	  m_aTipsData = new Array();
	  
      for(var nIndex:Number = 0; nIndex < m_nMainNodes; nIndex++)
      {
         var oData:Object = new Object();
         var xmlNode:XMLNode = xmlFirstChildNode.childNodes[nIndex];
         oData["sHeader"] = xmlNode.childNodes[0].firstChild.nodeValue;
         oData["sDesc"] = xmlNode.childNodes[2].firstChild.nodeValue;
		 oData["sImgPath"] = xmlNode.childNodes[1].firstChild.nodeValue;
         m_aTipsData.push(oData);
      }
   }

   public function getTipsData():Array {return m_aTipsData;}

   public function destroy():Void
   {
      delete m_aTipsData;
      super.destroy();
   }
}