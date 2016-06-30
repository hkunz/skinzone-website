class XmlParser
{
   private var m_xmlData:XML;
   private var m_sXmlPath:String;
   private var m_nMainNodes:Number;
   private var m_pfLoadComplete:Function;
   private var m_pfOnLoadParser:Function;

   public function XmlParser(sXmlPath:String)
   {
      //trace("XmlParser::XmlParser(" + sXmlPath + ")");
      m_sXmlPath = sXmlPath;
   }

   public function parseXmlData():Void
   {
      m_xmlData = new XML();
      m_xmlData.ignoreWhite = true;
      //m_xmlData.onData = Fxn.FunctionProxy(this, this.onData);
      m_xmlData.onLoad = Fxn.FunctionProxy(this, onLoad); //gets called when no onData defined
      m_xmlData.onHTTPStatus = Fxn.FunctionProxy(this, onHTTPStatus);
      m_xmlData.load(m_sXmlPath);
	  //m_xmlData.ignoreWhitespace = true;
	  //m_xmlData.ignoreComments = true;
   }

   //Invoked by Flash Player when an XML document is received from the server.
   public function onLoad(fLoadSuccess:Boolean):Void
   {
      //trace("XmlParser::onLoad(" + fLoadSuccess + ")");
      //trace("XML onLoad Success: " + fLoadSuccess);
	  if(fLoadSuccess)
      {
         if(m_xmlData.status == 0)
         {
            var cNode:XMLNode = m_xmlData.firstChild;
            m_nMainNodes = cNode.childNodes.length;
            //trace("Total Main Nodes: " + m_nMainNodes);
			m_pfOnLoadParser.call(this);
         }
         else Fxn.ErrorTrace("ERROR: Loaded XML file is corrupt"); //Should never happen
      }
	  else Fxn.ErrorTrace("ERROR: XML Load Failed"); //Should never happen
      m_pfLoadComplete.apply(this, [fLoadSuccess]);
   }

   //Invoked when XML text has been completely downloaded from the server, or when an error occurs downloading XML text from a server.
   /*
   public function onData(sSrc:String):Void
   {
      trace("XML onData Src: " + sSrc);
      var fLoaded:Boolean = true;
      if(sSrc == undefined) fLoaded = false;
      m_pfLoadComplete.apply(this, [fLoaded]);
	  trace("NODES: " + m_xmlData);
	  //This code below only works for onLoad
	  var cNode:XMLNode = m_xmlData.firstChild;
      m_nImgTotal = cNode.childNodes.length;
      trace("Total Pictures: " + m_nImgTotal);
   }
   */

   //Invoked when Flash Player receives an HTTP status code from the server.
   public function onHTTPStatus(nHttpStatus:Number):Void
   {
      //trace("XML onHTTPStatus: " + nHttpStatus);
   }

   public function setOnLoadParser(pfOnLoadParser:Function) {m_pfOnLoadParser = pfOnLoadParser;}
   public function addListener(pfLoadComplete:Function):Void {m_pfLoadComplete = pfLoadComplete;}

   public function destroy():Void
   {
      delete m_pfLoadComplete;
      delete m_xmlData;
      delete m_pfOnLoadParser;
   }
}