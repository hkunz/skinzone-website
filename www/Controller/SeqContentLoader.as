class SeqContentLoader
{
   private var m_cLoader:MovieClipLoader;
   private var m_oListener:Object;
   private var m_pfOnLoadEvent:Function;
   private var m_pfLoadSeqEvent:Function;
   private var m_aLoadItems:Array;
   private var m_nLoadIndex:Number;

   public function SeqContentLoader()
   {
      trace("SeqContentLoader::SeqContentLoader");
      m_nLoadIndex = 0;
      m_aLoadItems = new Array();
   }

   public function setItemLoadEvent(pfOnLoadFunction:Function):Void
   {
      //trace("SeqContentLoader::SetLoadEvent(" + pfOnLoadFunction + "," + aParams + ")");
      m_pfOnLoadEvent = pfOnLoadFunction;
   }

   public function setSeqLoadCompleteEvent(pfLoadSeqEvent:Function):Void
   {
      m_pfLoadSeqEvent = pfLoadSeqEvent;
   }

   public function addLoadItem(sPath:String, mcHolder:MovieClip, nIndex:Number):Void
   {
      if(sPath == "" || sPath == undefined) trace("ERROR: No Load Path: " + sPath);
      else if(mcHolder)
      {
         var oItem:Object = new Object();
         oItem["fLoaded"] = false;
         oItem["nIndex"] = nIndex;
         oItem["mc"] = mcHolder;
         oItem["sPath"] = sPath;
         m_aLoadItems.push(oItem);
	  }else trace("ERROR: Undefined Load Container added");
   }

   public function startLoad():Void
   {
      trace("SeqContentLoader::LoadFile");
      if(m_aLoadItems.length > 0) loadItemAtIndex(0);
      else trace("ERROR: Nothing to Load Sequentially");
   }

   public function getPercentLoaded():Number
   {
      var oItem:Object = m_aLoadItems[m_nLoadIndex];
      var mc:MovieClip = oItem["mc"];
      var nBytesLoaded:Number = mc.getBytesLoaded();
      var nBytesTotal:Number = mc.getBytesTotal();
      return (nBytesLoaded/nBytesTotal);
   }

   private function loadItemAtIndex(nIndex:Number):Void
   {
      trace("SeqContentLoader::loadItemAtIndex(" + nIndex + ")");
      var oItem:Object = m_aLoadItems[nIndex];
      m_cLoader = new MovieClipLoader();
	  m_oListener = {onLoadInit:Fxn.FunctionProxy(this, onFileLoadComplete, [true])};
      m_oListener.onLoadError = Fxn.FunctionProxy(this, onLoadError);
	  m_cLoader.addListener(m_oListener);
      m_cLoader.loadClip(oItem["sPath"], oItem["mc"]);
   }

   //.onLoadError = function(target_mc:MovieClip, errorCode:String, httpStatus:Number) {

   private function onLoadError(mcTarget:MovieClip, sErrorCode:String, nHttpStatus:Number):Void
   {
      //trace("ErrorCode: " + sErrorCode); //="URLNotFound"
      //trace("httpStatus: " + nHttpStatus); //=0
      var oItem:Object = m_aLoadItems[m_nLoadIndex];
      var sPath:String = oItem["sPath"];
      switch(sErrorCode)
      {
         case "URLNotFound": trace("ERROR: Load URL not found: \"" + sPath + "\""); break;
         default: trace("ERROR: Unknown load error");
	  }
      onFileLoadComplete(false);
   }

   private function onFileLoadComplete(fSuccess):Void
   {
      var oItem:Object = m_aLoadItems[m_nLoadIndex];
      oItem["fLoaded"] = true;
      m_pfOnLoadEvent.apply(this, [fSuccess, oItem["mc"], oItem["nIndex"]]);
	  m_cLoader.removeListener(m_oListener);
      delete m_oListener;
	  delete m_cLoader;
      m_nLoadIndex++;
      if(m_nLoadIndex >= m_aLoadItems.length) onSeqLoadComplete();
      else loadItemAtIndex(m_nLoadIndex);
   }

   private function onSeqLoadComplete():Void
   {
      m_nLoadIndex = 0;
      m_pfLoadSeqEvent.apply(this);
      delete m_pfOnLoadEvent;
   }

   public function getLoadItems():Array {return m_aLoadItems;}

   public function destroy(Void):Void
   {
      m_cLoader.removeListener(m_oListener);
      delete m_oListener;
	  delete m_cLoader;
	  delete m_pfOnLoadEvent;
      delete onSeqLoadComplete;
      delete m_aLoadItems;
   }
}