class ContentLoader
{
   private var m_mcContainer:MovieClip;
   private var m_cLoader:MovieClipLoader;
   private var m_oListener:Object;
   private var m_pfOnLoadEvent:Function;
   private var m_sPath:String;
   private var m_aParams:Array;

   public function ContentLoader(mcContainer:MovieClip)
   {
      trace("ContentLoader::ContentLoader");
	  m_mcContainer = mcContainer;
   }

   public function SetLoadEvent(pfOnLoadFunction:Function, aParams:Array):Void
   {
      //trace("ContentLoader::SetLoadEvent(" + pfOnLoadFunction + "," + aParams + ")");
      m_pfOnLoadEvent = pfOnLoadFunction;
	  m_aParams = aParams;
   }

   public function LoadFile(sPath:String):Void
   {
      trace("ContentLoader::LoadFile(" + sPath + ")");
      m_sPath = sPath;
      m_cLoader = new MovieClipLoader();
	  m_oListener = {onLoadInit:Fxn.FunctionProxy(this, onFileLoadComplete, [true])};
      m_oListener.onLoadError = Fxn.FunctionProxy(this, onLoadError);
	  m_cLoader.addListener(m_oListener);
      m_cLoader.loadClip(m_sPath, m_mcContainer);
   }

   //.onLoadError = function(target_mc:MovieClip, errorCode:String, httpStatus:Number) {

   private function onLoadError(mcTarget:MovieClip, sErrorCode:String, nHttpStatus:Number):Void
   {
      //trace("ErrorCode: " + sErrorCode); //="URLNotFound"
      //trace("httpStatus: " + nHttpStatus); //=0
      switch(sErrorCode)
      {
         case "URLNotFound": trace("ERROR: Load URL not found: \"" + m_sPath + "\""); break;
         default: trace("ERROR: Unknown load error");
	  }
      onFileLoadComplete(false);
   }

   private function onFileLoadComplete(fSuccess):Void
   {
      m_pfOnLoadEvent.apply(this, [fSuccess, m_aParams]);
	  m_cLoader.removeListener(m_oListener);
      delete m_oListener;
	  delete m_cLoader;
	  delete m_pfOnLoadEvent;
	  m_mcContainer = null;
   }

   public function destroy(Void):Void
   {
      m_cLoader.removeListener(m_oListener);
      delete m_sPath;
      delete m_oListener;
	  delete m_cLoader;
	  delete m_pfOnLoadEvent;
	  m_mcContainer = null;
   }
}