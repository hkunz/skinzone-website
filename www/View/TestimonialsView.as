import mx.transitions.*;
import mx.transitions.easing.*;

class TestimonialsView extends MvcView
{
   private var m_mcImage:MovieClip; //Clip in controller
   private var m_cViewDisabler:ViewDisable;
   private var m_cPhotos:PhotoCircularStrip;
   private var m_cViewPhoto:ViewImage;
   private var m_cXmlParser:PeopleTestiDataXmlParser;
   private var m_mcScrollContent:MovieClip;
   private var m_cLoadAnimation:LoadAnimation;
   private var m_aTweens:Array;
   private var m_nIndex:Number; //MovieClip Depth Index
   private var m_nImgIndex:Number;
   private var m_aoTestiData:Array;
   private var m_cTween:Tween;
   private var m_mcSheet:MovieClip;

   static private var IMAGE_FOLDER_PATH:String; // = "Library/Graphics/Pictures/SzItParkPics/";
   static private var IMAGE_FOLDER_ORIG_PATH:String; // = IMAGE_FOLDER_PATH + "Originals/";
   static private var XML_FILE_PATH:String; // = "Library/Xml/SzItParkPics.xml";

   public function TestimonialsView(oController:MvcController, mcViewHolder:MovieClip, cProps:ViewProps)
   {
      super(oController, mcViewHolder, cProps);
      trace("TestimonialsView::TestimonialsView(" + oController + "," +  mcViewHolder + ")");
	  m_aTweens = new Array();
	  m_nIndex = 0;
	  m_nImgIndex = 0;
	  CreateViewContainer(cProps.sViewName);
	  setGalleryName("TestiPeoplePics"); //"SzOsmenaBlvdPics" OR "SzItParkPics"
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
      //Check if XML data was already loaded previously
      m_aoTestiData = DataStore.getTestiXmlData();
      if(m_aoTestiData == null) LoadImageXmlData();
      else onXmlLoadCompleteRoutine();
   }

   public function updateView(nIndex:Number):Void
   {
      m_mcSheet["TextLine_TXT"].text = m_aoTestiData[nIndex]["sTesti"];
   }

   public function showBiggerPhoto():Void
   {
      var sImgFolderPath:String = IMAGE_FOLDER_ORIG_PATH;
      var sImagePath:String = sImgFolderPath + m_aoTestiData[m_nImgIndex]["sImage"];
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
	  var sImagePath:String = sImgFolderPath + m_aoTestiData[nIndex]["sImage"];
	  m_cViewPhoto.loadImage(sImagePath);
   }

   private function prevBigImage():Void
   {
      m_cPhotos.prevPhoto(false);
      var sImgFolderPath:String = IMAGE_FOLDER_ORIG_PATH;
	  var nIndex:Number = m_cPhotos.getActiveIndex();
	  var sImagePath:String = sImgFolderPath + m_aoTestiData[nIndex]["sImage"];
	  m_cViewPhoto.loadImage(sImagePath);
   }

   public function EntryViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("TestimonialsView::EntryViewAnimStart");
      super.EntryViewAnimStart(pfDoneEvent);
   }

   public function ExitViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("TestimonialsView::ExitViewAnimStart");
      super.ExitViewAnimStart(pfDoneEvent);
      var cTw:Tween = new Tween(m_mcSheet, "_xscale", Strong.easeIn, m_mcSheet._xscale, 10, 0.5, true);
      new Tween(m_mcSheet, "_yscale", Strong.easeIn, m_mcSheet._yscale, 1, 0.5, true);
      cTw.onMotionFinished = Fxn.FunctionProxy(Fxn, Fxn.removeMovieClip, [m_mcSheet]);
      m_cLoadAnimation.StopAnimation();
      m_cViewDisabler.removeListener();
	  m_cViewDisabler.enableView(true);
      m_cXmlParser.destroy();
      delete m_aoTestiData; m_aoTestiData = null;
      m_cViewPhoto.exitImageView(true);
	  m_cPhotos.shutDown(Fxn.FunctionProxy(this, shutDownAftermath), 1);
   }

   public function shutDownAftermath():Void
   {
      super.ExitViewAnimComplete();
   }

   public function setViewEnabled(fEnabled:Boolean):Void
   {
      if(m_aoTestiData == null) fEnabled = false;
      m_cPhotos.setEnabled(fEnabled);
      super.setViewEnabled(fEnabled);
   }

   private function LoadImageXmlData(Void):Void
   {
      trace("TestimonialsView::CreateContent");
      m_cXmlParser = new PeopleTestiDataXmlParser(XML_FILE_PATH);
      m_cXmlParser.addListener(Fxn.FunctionProxy(this, onXmlLoadComplete));
	  m_cXmlParser.parseXmlData();
   }

   private function onXmlLoadComplete(fSuccess:Boolean):Void
   {
      if(fSuccess == true)
      {
         var aImages:Array = m_cXmlParser.getImages();
         m_aoTestiData = m_cXmlParser.getTestiData();
         DataStore.setTestiXmlData(m_aoTestiData);
         DataStore.setImgTestiXmlData(aImages);
         onXmlLoadCompleteRoutine();
	  }
      else trace("ERROR: Corrupt XML Photos File");
      m_cLoadAnimation.StopAnimation();
   }

   private function onXmlLoadCompleteRoutine():Void
   {
      var nTestis:Number = m_aoTestiData.length;
      if(nTestis > 0)
      {
         var mcPhotoGallery:MovieClip = m_mcView.createEmptyMovieClip("Photos_MC", m_nIndex++);
         var aImages:Array = DataStore.getImgTestiXmlData();
         m_cPhotos = new PhotoCircularStrip(mcPhotoGallery, nTestis);
         m_cPhotos.addUpdateHandler(Fxn.FunctionProxy(this, updateView));
         m_cPhotos.enableContentScaling(false);
         m_cPhotos.addShutdownListener(Fxn.FunctionProxy(this, onPhotoCircularStripBackPress));
         m_cPhotos.setPhotoClickEvent(Fxn.FunctionProxy(this, onActivePhotoClicked));
         m_cPhotos.setFolderLoadPath(IMAGE_FOLDER_PATH);
         m_cPhotos.setImagesArray(aImages);
         m_cPhotos.createCircularStrip(Constant.STAGE_WIDTH_HALF - 180, 280, 240, 240);
         var nDepth:Number = m_mcView.getNextHighestDepth();
         var mcViewDisable:MovieClip = m_mcView.createEmptyMovieClip("DisableView_MC", nDepth);
         m_cViewDisabler = new ViewDisable(mcViewDisable, this);
         m_cViewDisabler.addListener(Fxn.FunctionProxy(this, showBiggerPhoto), Fxn.FunctionProxy(this, destroyImageView));
         m_mcSheet = m_mcView.attachMovie("Sheet_MC", "Sheet_MC", m_nIndex++, {_x:450,_y:150,_rotation:-5});
         new Tween(m_mcSheet, "_xscale", Strong.easeOut, 1, m_mcSheet._xscale, 0.5, true);
         new Tween(m_mcSheet, "_yscale", Strong.easeOut, 1, m_mcSheet._yscale, 0.5, true);
         m_mcSheet._visible = true;
         updateView(m_cPhotos.getActiveIndex());
      }
      else trace("INFO: No photos available");
      m_cLoadAnimation.StopAnimation();
   }

   private function onPhotoCircularStripBackPress():Void
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
      var oTesti:Object = m_aoTestiData[nIndex];
      return oTesti["sLabel"];
   }

   public function destroy(Void):Void
   {
      trace("TestimonialsView::destroy");
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
	  delete m_aoTestiData;
      super.destroy();
   }
}