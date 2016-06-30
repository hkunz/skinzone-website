import mx.transitions.*;
import mx.transitions.easing.*;

class SzLocationView extends MvcView
{
   private var m_cScroller:MovieClipScroller;
   private var m_mcMask:MovieClip;
   private var m_cLoadAnimation:LoadAnimation;
   private var m_cXmlParser:LocationDataXmlParser;
   private var m_aLocationData:Array;
   private var m_nIndex:Number; //MovieClip Depth Index
   private var m_amcLocData:Array;
   private var m_mcSelect:MovieClip;
   private var m_mcInstruction:MovieClip;

   static private var XML_FILE_PATH:String = "Library/Xml/SzLocation.xml";

   public function SzLocationView(oController:MvcController, mcViewHolder:MovieClip, cProps:ViewProps)
   {
      super(oController, mcViewHolder, cProps);
      trace("SzLocationView::SzLocationView(" + oController + "," +  mcViewHolder + ")");
      CreateViewContainer(cProps["sViewName"]);
	  m_nIndex = 0;
	  var mcLoadAnimation:MovieClip = m_mcView.createEmptyMovieClip("Loading_MC", 10);
      m_cLoadAnimation = new LoadAnimation(mcLoadAnimation);
	  m_cLoadAnimation.centerLoadClip();
	  m_cLoadAnimation.StartAnimation();

      m_aLocationData = DataStore.getLocationXmlData();
      if(m_aLocationData == null) LoadLocationXmlData();
      else onXmlLoadCompleteRoutine();
   }

   public function EntryViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("SzLocationView::EntryViewAnimStart");
      super.EntryViewAnimStart(pfDoneEvent);

   }

   public function ExitViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("SzLocationView::ExitViewAnimStart");
      super.ExitViewAnimStart(pfDoneEvent);
      var nIndex:Number = 0;
	  var nLocations:Number = m_aLocationData.length;
	  var cTw:Tween = null;
	  
	  new Tween(m_mcInstruction, "_alpha", Regular.easeOut, m_mcInstruction._alpha, 0, 1, true);
	  var mcVeScroll:MovieClip = m_cScroller.getVeScrollBar();
	  new Tween(mcVeScroll, "_yscale", Strong.easeOut, mcVeScroll._yscale, 10, 1, true);
	  new Tween(mcVeScroll, "_alpha", Strong.easeOut, mcVeScroll._alpha, 0, 1, true);
	  
	  m_cXmlParser.destroy();
      m_cLoadAnimation.destroy();
	  
	  for(nIndex = 0; nIndex < nLocations; nIndex++)
	  {
         var nTime:Number = 0.7;
         var oLocData:Object = m_amcLocData[nIndex];
         var mcMask:MovieClip = oLocData["mcMask"];
		 var mcData:MovieClip = oLocData["mcLocData"];
		 delete mcData.onRollOver;
		 delete mcData.onRollOut;
		 delete mcData.onPress;
		 delete mcData.onDragOut;
         if(mcMask["fAnimating"])
		 {
            cTw = new Tween(mcMask, "_x", Strong.easeIn, mcMask._x, mcMask._x - mcMask._width, nTime, true);
		    new Tween(mcData, "_alpha", Strong.easeOut, mcData._alpha, 0, nTime, true);
			new Tween(mcData, "_x", Strong.easeOut, mcData._x, mcData._x + 50, nTime, true);
		 }
		 else {mcMask.removeMovieClip(); mcData.removeMovieClip();}
	  }
	  cTw.onMotionFinished = Fxn.FunctionProxy(this, animDataLocMaskComplete);
   }

   private function animDataLocMaskComplete():Void
   {
      super.ExitViewAnimComplete();
   }

   private function LoadLocationXmlData(Void):Void
   {
      trace("SzLocationGalleryView::CreateContent");
      m_cXmlParser = new LocationDataXmlParser(XML_FILE_PATH);
      m_cXmlParser.addListener(Fxn.FunctionProxy(this, onXmlLoadComplete));
	  m_cXmlParser.parseXmlData();
   }

   private function onXmlLoadComplete(fSuccess:Boolean):Void
   {
      if(fSuccess == true)
      {
         m_aLocationData = m_cXmlParser.getLocationData();
         DataStore.setLocationXmlData(m_aLocationData);
         onXmlLoadCompleteRoutine();
	  }
      else trace("ERROR: Corrupt XML Location Data File");
	  m_cLoadAnimation.StopAnimation();
   }

   private function onXmlLoadCompleteRoutine():Void
   {
      var nLocations:Number = m_aLocationData.length;
      if(nLocations > 0)
      {
         m_mcInstruction = m_mcView.attachMovie("LocationInstruction_MC", "Inst_MC", m_nIndex++);
         m_mcInstruction._x = 55;
		 m_mcInstruction._y = 110;
		 new Tween(m_mcInstruction, "_alpha", Regular.easeOut, 0, 100, 1, true);
		 CreateContent();
      }
      else trace("INFO: No Locations available");
      m_cLoadAnimation.StopAnimation();
   }

   private function CreateContent():Void
   {
	  var cT:EventTimer = null;
	  var mcHolder:MovieClip = m_mcView.createEmptyMovieClip("Scroller_MC", m_nIndex++);
	  var mcContent:MovieClip = m_mcView.createEmptyMovieClip("Content_MC", m_nIndex++);
      var nLocations:Number = m_aLocationData.length;
	  var nX:Number = 140;
	  var nY:Number = 145;
	  var nLocIndex:Number = 0;
	  var nTime:Number = 50;
	  m_amcLocData = new Array();
	  m_mcSelect = mcContent.attachMovie("LocationSelect_MC", "Select_MC", 0);
	  //m_mcSelect._alpha = 30;
	  m_mcSelect._visible = false;
	  setCoords(m_mcSelect, 50, 105);
	  for(nLocIndex = 0; nLocIndex < nLocations; nLocIndex++)
	  {
         var oData:Object = m_aLocationData[nLocIndex];
		 var sLink:String = "LocationData_MC";
         var sMask:String = "LocationDatumMask_MC";
	     var mcLocData:MovieClip = mcContent.attachMovie(sLink, sLink + nLocIndex, nLocIndex + 1);
         var mcMask:MovieClip = mcContent.attachMovie(sMask, sMask + nLocIndex, nLocations + nLocIndex + 1);
		 var mcImgHolder:MovieClip = mcLocData["ImageHolder_MC"];
		 var mcImg:MovieClip = mcImgHolder["Img_MC"];
		 var mcLoad:MovieClip = mcImgHolder.attachMovie("BrowseItemLoad_MC", "Load_MC", 0);
		 var sPreview:String = oData["sPreview"];
		 mcImg._alpha = 0;
		 mcLocData.setMask(mcMask);
		 setCoords(mcLoad, 55, 50);
		 setCoords(mcLocData, nX, nY);
		 setCoords(mcMask, nX, nY);
         initLocationData(mcLocData, oData);
		 nY += 140 + 15; //mc._height;
         cT = new EventTimer(Fxn.FunctionProxy(this, animateLocData, [mcLocData,mcMask]), nTime);
         cT.StartTimer();
		 nTime += 300;
		 loadContent(sPreview, mcImg, mcLoad);
         mcMask["fAnimating"] = false;
		 m_amcLocData.push({mcMask:mcMask, mcLocData:mcLocData});
	  }
      m_cScroller = new MovieClipScroller(mcHolder);
	  m_cScroller.setContentMc(mcContent);
	  m_cScroller.setEaseInTweenTime(1);
	  m_mcMask = m_cScroller.setGraphicMask("LocationDataMask_MC");
	  var mcVeScroll:MovieClip = m_cScroller.setVeScroller("CurvedVeScroller_MC");
	  //mcVeScroll.swapDepths(m_mcSelect);
	  setCoords(m_mcMask, 50, 105);
	  m_cScroller.SetVeScrollEnabled(false);
      m_cScroller.setVeScrollerPosition(m_mcMask._width - 40, 130);
      m_cScroller.setVeContentProps(0, nY - 70);
      var cTw:Tween = new Tween(mcVeScroll, "_yscale", Strong.easeOut, 10, 100, 1, true);
	  cTw = new Tween(mcVeScroll, "_alpha", Strong.easeOut, 0, 100, 1, true);
      cTw.onMotionFinished = Fxn.FunctionProxy(this, onScrollerAnimDone);
   }

   private function setCoords(mc:MovieClip, nX:Number, nY:Number):Void
   {
      mc._x = nX;
	  mc._y = nY;
   }

   private function animateLocData(mcLocData:MovieClip, mcMask:MovieClip):Void
   {
      var nTime:Number = 1.2;
	  //var cTw:Tween = new Tween(mcLocData, "_y", Strong.easeOut, mcLocData._y + 30, mcLocData._y, nTime, true);
      var cTw:Tween = new Tween(mcLocData, "_x", Strong.easeOut, mcLocData._x + 200, mcLocData._x, nTime, true);
      var cTw:Tween = new Tween(mcMask, "_x", Strong.easeOut, mcMask._x, mcMask._x + mcMask._width, nTime, true);
      cTw.onMotionFinished = Fxn.FunctionProxy(this, removeLocDataMask, [mcMask]);
      mcMask["fAnimating"] = true;
   }

   private function removeLocDataMask(mcMask:MovieClip):Void
   {
      //mcMask.removeMovieClip();
   }

   private function loadContent(sPreview:String, mcImg:MovieClip, mcLoad:MovieClip):Void
   {
      var cLoader:ContentLoader = new ContentLoader(mcImg);
	  cLoader.SetLoadEvent(Fxn.FunctionProxy(this, onLocImageLoaded, [mcImg, mcLoad]));
	  cLoader.LoadFile(sPreview);
   }

   private function onScrollerAnimDone():Void
   {
      var mcVeScroll:MovieClip = m_cScroller.getVeScrollBar();
      m_cScroller.SetVeScrollEnabled(true);
   }

   private function initLocationData(mcLocData:MovieClip, oData:Object):Void
   {
	  var sGalleryName:String = oData["sGallery"];
      var oMapData:String = oData["oMapData"];
      mcLocData["Header_TXT"].text = oData["sHeader"];
	  mcLocData["Address1_TXT"].text = oData["sAddress1"];
	  mcLocData["Address2_TXT"].text = oData["sAddress2"];
	  mcLocData["Contact_TXT"].text = "Contact: " + oData["sTel"] + " or " + oData["sCel"];
	  mcLocData["Time_TXT"].text = oData["sOpen"];
	  mcLocData["Email_TXT"].text = oData["sEmail"];
      mcLocData.onPress = Fxn.FunctionProxy(this, onLocDataPress, [sGalleryName, oMapData]);
      mcLocData.onRollOver = Fxn.FunctionProxy(this, setSelected, [mcLocData, true]);
	  mcLocData.onRollOut = Fxn.FunctionProxy(this, setSelected, [false]);
	  mcLocData.onDragOut = Fxn.FunctionProxy(this, setSelected, [false]);
   }

   private function onLocDataPress(sGalleryName:String, oMapData:Object):Void
   {
      TransitionView(sGalleryName, oMapData);
      m_mcSelect.gotoAndPlay("select");
   }

   private function setSelected(mcLocData:MovieClip, fSelected:Boolean):Void
   {
      if(fSelected == true)
	  {
         m_mcSelect._y = mcLocData._y;
         m_mcSelect._visible = true;
		 m_mcSelect.gotoAndPlay("hover");
	  }
      else
	  {
         m_mcSelect._visible = false;
	  }
   }

   private function TransitionView(sGalleryName:String, oMapData:Object):Void
   {
      var oSysController:SystemController = SystemController(super.getController());
      DataStore.setGalleryName(sGalleryName);
	  DataStore.setMapData(oMapData);
      oSysController.TransitionToView(Enum.VIEW_SZ_LOCATION_GALLERY);
   }

   private function onLocImageLoaded(mcImg:MovieClip, mcLoad:MovieClip):Void
   {
      mcImg._parent["Blink_MC"].play();
	  mcLoad.removeMovieClip();
      mcImg._alpha = 100;
   }

   public function destroy(Void):Void
   {
      trace("SzLocationView::destroy");
	  m_cScroller.destroy();
	  m_cXmlParser.destroy();
	  m_cLoadAnimation.destroy();
	  delete m_amcLocData;
	  delete m_cScroller;
	  delete m_cLoadAnimation;
	  delete m_cXmlParser;
      super.destroy();
   }
}