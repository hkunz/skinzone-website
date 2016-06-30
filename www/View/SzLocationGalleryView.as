import mx.transitions.*;
import mx.transitions.easing.*;

class SzLocationGalleryView extends MvcView
{
   private var m_mcMap:MovieClip;
   private var m_mcMapMask:MovieClip;
   private var m_mcImage:MovieClip; //Clip in controller
   private var m_cViewDisabler:ViewDisable;
   private var m_cPhotos:PhotoFilmStrip;
   private var m_cViewPhoto:ViewImage;
   private var m_cXmlParser:PhotoGalleryXmlParser;
   private var m_mcScrollContent:MovieClip;
   private var m_mcViewMapBtn:MovieClip;
   private var m_cLoadAnimation:LoadAnimation;
   private var m_aTweens:Array;
   private var m_nIndex:Number; //MovieClip Depth Index
   private var m_nImgIndex:Number;
   private var m_asImages:Array;
   private var m_asImgLabels:Array;
   private var m_cTween:Tween;

   static private var IMAGE_FOLDER_PATH:String; // = "Library/Graphics/Pictures/SzItParkPics/";
   static private var IMAGE_FOLDER_ORIG_PATH:String; // = IMAGE_FOLDER_PATH + "Originals/";
   static private var XML_FILE_PATH:String; // = "Library/Xml/SzItParkPics.xml";

   public function SzLocationGalleryView(oController:MvcController, mcViewHolder:MovieClip, cProps:ViewProps)
   {
      super(oController, mcViewHolder, cProps);
      trace("SzLocationGalleryView::SzLocationGalleryView(" + oController + "," +  mcViewHolder + ")");
	  m_aTweens = new Array();
	  m_nIndex = 0;
	  m_nImgIndex = 0;
	  CreateViewContainer(cProps.sViewName);
	  m_mcMap = m_mcView.createEmptyMovieClip("Map_MC", m_nIndex++);
	  m_mcMap.createEmptyMovieClip("Map_MC", 0);
	  m_mcMap.createEmptyMovieClip("Spot_MC", 1);
      m_mcMapMask = m_mcView.attachMovie("ViewDisable_MC", "MapMask_MC", m_nIndex++);
	  m_mcMapMask._alpha = 0;
	  m_mcMapMask._x = 51;
	  m_mcMapMask._y = 105;
	  m_mcMap._x = 51;
	  m_mcMap._y = 105;
	  m_mcMap._alpha = 0;
	  setGalleryName(DataStore.getGalleryName()); //"SzOsmenaBlvdPics" OR "SzItParkPics"
	  initView();
   }

   public function setGalleryName(sName:String):Void
   {
      IMAGE_FOLDER_PATH = "Library/Graphics/Pictures/" + sName + "/";
      IMAGE_FOLDER_ORIG_PATH = IMAGE_FOLDER_PATH + "Originals/";
      XML_FILE_PATH = "Library/Xml/" + sName + ".xml";
   }

   public function initView():Void
   {
      var mcLoadAnimation:MovieClip = m_mcView.createEmptyMovieClip("Loading_MC", 10);
      m_cLoadAnimation = new LoadAnimation(mcLoadAnimation);
	  m_cLoadAnimation.centerLoadClip();
	  m_cLoadAnimation.StartAnimation();
      loadMap();
   }

   public function onMapLoad(fSuccess:Boolean):Void
   {
      m_mcMap.setMask(m_mcMapMask);
      LoadImageXmlData();
   }

   public function loadMap():Void
   {
      var oMapData:Object = DataStore.getMapData();
      var cLoader:ContentLoader = new ContentLoader(m_mcMap["Map_MC"]);
	  cLoader.SetLoadEvent(Fxn.FunctionProxy(this, onMapLoad));
	  cLoader.LoadFile(oMapData["sPath"]);
   }

   public function showBiggerPhoto():Void
   {
      var sImgFolderPath:String = IMAGE_FOLDER_ORIG_PATH;
      var sImagePath:String = sImgFolderPath + m_asImages[m_nImgIndex];
      var oController:SystemController = SystemController(super.getController());
      m_mcImage = oController.createMcInTopClip("Pic_MC");
	  m_cViewPhoto = new ViewImage(this, m_mcImage);
	  m_cViewPhoto.addNextImageListener(Fxn.FunctionProxy(this, nextBigImage));
	  m_cViewPhoto.addPrevImageListener(Fxn.FunctionProxy(this, prevBigImage));
	  m_cViewPhoto.addExitViewListener(Fxn.FunctionProxy(this, onBigImageViewExit));
      m_cViewPhoto.loadImage(sImagePath, m_nImgIndex);
   }

   private function onBigImageViewExit(fQuick:Boolean):Void
   {
      m_cViewDisabler.enableView(fQuick);
   }

   private function nextBigImage():Void
   {
      m_cPhotos.nextPhoto(false);
      var sImgFolderPath:String = IMAGE_FOLDER_ORIG_PATH;
	  var nIndex:Number = m_cPhotos.getActiveIndex();
	  var sImagePath:String = sImgFolderPath + m_asImages[nIndex];
	  m_cViewPhoto.loadImage(sImagePath);
   }

   private function prevBigImage():Void
   {
      m_cPhotos.prevPhoto(false);
      var sImgFolderPath:String = IMAGE_FOLDER_ORIG_PATH;
	  var nIndex:Number = m_cPhotos.getActiveIndex();
	  var sImagePath:String = sImgFolderPath + m_asImages[nIndex];
	  m_cViewPhoto.loadImage(sImagePath);
   }

   public function EntryViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("SzLocationGalleryView::EntryViewAnimStart");
      super.EntryViewAnimStart(pfDoneEvent);
   }

   public function ExitViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("SzLocationGalleryView::ExitViewAnimStart");
      super.ExitViewAnimStart(pfDoneEvent);
      m_cViewDisabler.removeListener();
	  m_cViewDisabler.enableView(true);
      delete m_asImages; m_asImages = null;
      m_cViewPhoto.exitImageView(true);
	  m_cPhotos.shutDown(Fxn.FunctionProxy(this, shutDownAftermath));
	  new Tween(m_mcMap, "_alpha", null, m_mcMap._alpha, 0, 1, true);
	  new Tween(m_mcViewMapBtn._parent, "_alpha", null, m_mcViewMapBtn._parent._alpha, 0, 1, true);
	  //var cEventTimer:EventTimer = null;
	  //cEventTimer = new EventTimer(Fxn.FunctionProxy(this, super.ExitViewAnimComplete), 600);
      //cEventTimer.StartTimer();
   }

   public function shutDownAftermath():Void
   {
      super.ExitViewAnimComplete();
   }

   public function setViewEnabled(fEnabled:Boolean):Void
   {
      if(m_asImages == null) fEnabled = false;
      m_cPhotos.setEnabled(fEnabled);
	  m_mcViewMapBtn.enabled = fEnabled;
      super.setViewEnabled(fEnabled);
   }

   private function LoadImageXmlData(Void):Void
   {
      trace("SzLocationGalleryView::CreateContent");
      m_cXmlParser = new PhotoGalleryXmlParser(XML_FILE_PATH);
      m_cXmlParser.addListener(Fxn.FunctionProxy(this, onXmlLoadComplete));
	  m_cXmlParser.parseXmlData();
   }

   private function onXmlLoadComplete(fSuccess:Boolean):Void
   {
      if(fSuccess == true)
      {
         m_asImages = m_cXmlParser.getImageFileNames();
		 m_asImgLabels = m_cXmlParser.getImageFileLabels();
         var nImages:Number = m_asImages.length;
         if(nImages > 0)
		 {
            var mcPhotoGallery:MovieClip = m_mcView.createEmptyMovieClip("Photos_MC", m_nIndex++);
            m_cPhotos = new PhotoFilmStrip(mcPhotoGallery, nImages);
            m_cPhotos.addShutdownListener(Fxn.FunctionProxy(this, onPhotoFilmStripBackPress));
			m_cPhotos.setPhotoClickEvent(Fxn.FunctionProxy(this, onActivePhotoClicked));
			m_cPhotos.setFolderLoadPath(IMAGE_FOLDER_PATH);
            m_cPhotos.setImagesArray(m_asImages);
            m_cPhotos.createFlimStrip(Constant.STAGE_WIDTH_HALF - 140, 95, 840, 640);
            var nDepth:Number = m_mcView.getNextHighestDepth();
	        var mcViewDisable:MovieClip = m_mcView.createEmptyMovieClip("DisableView_MC", nDepth);
	        m_cViewDisabler = new ViewDisable(mcViewDisable, this);
	        m_cViewDisabler.addListener(Fxn.FunctionProxy(this, showBiggerPhoto), Fxn.FunctionProxy(this, destroyImageView));
			new Tween(m_mcMap, "_alpha", null, 0, 20, 1, true);
            m_mcViewMapBtn = m_mcView.attachMovie("ViewMapBtn_MC", "ViewMapBtn_MC", m_nIndex++, {_x:55, _y:110});
		    m_mcViewMapBtn = m_mcViewMapBtn["Btn_MC"];
			m_mcViewMapBtn.onPress = Fxn.FunctionProxy(this, onViewMapPress);
		 }
		 else trace("INFO: No photos available");
	  }
      else trace("ERROR: Corrupt XML Photos File");
	  m_cLoadAnimation.StopAnimation();
   }

   private function onViewMapPress():Void
   {
      if(true == m_cPhotos.isInTransition()) return;
      var mcHolder:MovieClip = m_cPhotos.getHolder();
      mcHolder.swapDepths(m_mcMap);
	  setViewEnabled(false);
	  m_mcViewMapBtn._parent["Label_TXT"].text = "Return";
	  m_mcViewMapBtn.onPress = Fxn.FunctionProxy(this, onReturnPress);
	  m_mcViewMapBtn.enabled = true;
      tweenZoomInMap();
   }

   private function tweenZoomInMap():Void
   {
      var oData:Object = DataStore.getMapData();
      var nTime:Number = 1;
	  var nScale:Number = 150;
	  var nPerc:Number = nScale/100;
	  var nLocX:Number = oData["nLocX"];
	  var nLocY:Number = oData["nLocY"];
	  var nX:Number = -nLocX*nPerc + Constant.STAGE_WIDTH_HALF;
	  var nY:Number = -nLocY*nPerc + Constant.STAGE_HEIGHT_HALF;
	  if(nX > 51) nX = 51;
	  if(nY > 105) nY = 105;
	  m_mcMap["Spot_MC"].attachMovie("Spot_MC", "Spot_MC", 10, {_x:nX, _y:nY});
	  m_mcMap["Spot_MC"]["Spot_MC"].onEnterFrame = function()
	  {
         this._x = nLocX;
		 this._y = nLocY;
		 delete this.onEnterFrame;
	  }

      new Tween(m_mcMap, "_alpha", Strong.easeOut, m_mcMap._alpha, 100, nTime, true);
	  new Tween(m_mcMap, "_x", Strong.easeOut, m_mcMap._x, nX, nTime, true);
	  new Tween(m_mcMap, "_y", Strong.easeOut, m_mcMap._y, nY, nTime, true);
	  new Tween(m_mcMap, "_xscale", Strong.easeOut, m_mcMap._xscale, nScale, nTime, true);
	  m_cTween = new Tween(m_mcMap, "_yscale", Strong.easeOut, m_mcMap._yscale, nScale, nTime, true);
      m_cTween.onMotionFinished = Fxn.FunctionProxy(this, tweenZoomOut);
   }

   private function tweenZoomOut():Void
   {
      var nTime:Number = 1;
	  var nScale:Number = 100;
	  new Tween(m_mcMap, "_x", Strong.easeIn, m_mcMap._x, 51, nTime, true);
	  new Tween(m_mcMap, "_y", Strong.easeIn, m_mcMap._y, 105, nTime, true);
	  new Tween(m_mcMap, "_xscale", Strong.easeIn, m_mcMap._xscale, nScale, nTime, true);
	  new Tween(m_mcMap, "_yscale", Strong.easeIn, m_mcMap._yscale, nScale, nTime, true);
   }

   private function onReturnPress():Void
   {
      m_mcViewMapBtn.enabled = false;
      var cTw:Tween = new Tween(m_mcMap, "_alpha", Strong.easeOut, m_mcMap._alpha, 0, 1, true);
      cTw.onMotionFinished = Fxn.FunctionProxy(this, onReturnAnimComplete);
	  m_mcViewMapBtn._parent["Label_TXT"].text = "View Map";
	  var mcSpot:MovieClip = m_mcMap["Spot_MC"]["Spot_MC"];
	  new Tween(mcSpot, "_alpha", Strong.easeOut, mcSpot._alpha, 0, 1, true);
   }

   private function onReturnAnimComplete():Void
   {
      //m_mcViewMapBtn.enabled = true;
      new Tween(m_mcMap, "_alpha", Strong.easeOut, m_mcMap._alpha, 20, 1, true);
      var mcHolder:MovieClip = m_cPhotos.getHolder();
      m_mcViewMapBtn.onPress = Fxn.FunctionProxy(this, onViewMapPress);
	  setViewEnabled(true);
	  m_mcMap["Spot_MC"]["Spot_MC"].removeMovieClip();
	  mcHolder.swapDepths(m_mcMap);
   }

   private function onPhotoFilmStripBackPress():Void
   {
      var oSysController:SystemController = SystemController(super.getController());
	  oSysController.TransitionToView(Enum.VIEW_LOCATION);
   }

   private function destroyImageView():Void
   {
      m_mcImage.removeMovieClip();
      m_cViewPhoto.destroy();
	  delete m_cViewPhoto;
   }

   public function onActivePhotoClicked(nIndex:Number):Void
   {
      if(true == m_cPhotos.isInTransition()) return;
	  m_nImgIndex = nIndex;
	  m_cViewDisabler.disableView();
   }

   public function getImageLabel():String
   {
      var nIndex:Number = m_cPhotos.getActiveIndex();
      return m_asImgLabels[nIndex];
   }

   public function destroy(Void):Void
   {
      trace("SzLocationGalleryView::destroy");
      m_cViewDisabler.destroy();
      m_cXmlParser.destroy();
	  m_cPhotos.destroy();
	  m_cLoadAnimation.destroy();
	  m_cViewPhoto.destroy();
      m_mcImage.removeMovieClip();
	  delete m_cViewPhoto;
	  delete m_cLoadAnimation;
	  delete m_cPhotos;
	  delete m_cViewDisabler;
      delete m_cXmlParser;
	  delete m_asImages;
      super.destroy();
   }
}