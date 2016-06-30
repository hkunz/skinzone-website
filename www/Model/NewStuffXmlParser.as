class NewStuffXmlParser extends XmlParser
{
   private var m_aData:Array;

   public function NewStuffXmlParser(sXmlPath:String)
   {
      super(sXmlPath);
	  //trace("NewStuffXmlParser::NewStuffXmlParser(" + sXmlPath + ")");
      m_sXmlPath = sXmlPath;
      setOnLoadParser(Fxn.FunctionProxy(this, parseNewStuffData));
   }

   private function parseNewStuffData():Void
   {
	  var xmlFirstChildNode:XMLNode = m_xmlData.firstChild;
	  var fPromo:Boolean = true; //1st Loop pass is promos
	  m_aData = new Array();
	  
      for(var nIndex:Number = 0; nIndex < m_nMainNodes; nIndex++)
      {
         var aData:Array = new Array();
         var xmlNode:XMLNode = xmlFirstChildNode.childNodes[nIndex];
		 var nChilds:Number = xmlNode.childNodes.length;
		 for(var nSub:Number = 0; nSub < nChilds; nSub++)
		 {
            var oData:Object = new Object();
            var xmlChildNode:XMLNode = xmlNode.childNodes[nSub];
            oData["sHeader"] = xmlChildNode.childNodes[0].firstChild.nodeValue;
            oData["sImgPath"] = xmlChildNode.childNodes[1].firstChild.nodeValue;
		    oData["sDesc"] = xmlChildNode.childNodes[2].firstChild.nodeValue;
            oData["fPromo"] = fPromo;
            aData.push(oData);
		 }
         fPromo = false; //2nd Loop pass is "What's New"
         m_aData.push(aData);
      }
   }

   public function getPromosData():Array {return m_aData[0];}
   public function getWhatsNewData():Array {return m_aData[1];}
   public function getEntireData():Array {return m_aData[0].concat(m_aData[1]);}

   public function destroy():Void
   {
      delete m_aData[0]; //Delete What's New Data
      delete m_aData[1]; //Delete Promos Data
      delete m_aData;
      super.destroy();
   }
}