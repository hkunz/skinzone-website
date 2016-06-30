import mx.transitions.*;
import mx.transitions.easing.*;

class WhatsNewView extends MvcView
{
   private var m_cXmlParser:NewStuffXmlParser;
   private var m_cViewDisabler:ViewDisable;
   private var m_cLoadAnimation:LoadAnimation;
   private var m_mcLoading:MovieClip;
   private var m_mcBoard:MovieClip;
   private var m_nIndex:Number; //MovieClip Depth Index
   private var m_aoNewStuff:Array;
   private var m_mcStuffHolder:MovieClip;
   private var m_cSeqLoader:SeqContentLoader;
   private var m_aCurDisplayItems:Array;
   private var m_cPromoPopup:PromoPopup;

   static private var PROMOS_FOLDER:String = "Library/Graphics/Promos/";
   static private var WHATS_NEW_FOLDER:String = "Library/Graphics/WhatsNew/";
   static private var DATA_XML_PATH:String = "Library/Xml/NewStuffData.xml";
   static private var MAX_DISPLAY_ITEMS:Number = 6;

   public function WhatsNewView(oController:MvcController, mcViewHolder:MovieClip, cProps:ViewProps)
   {
      super(oController, mcViewHolder, cProps);
      trace("WhatsNewView::SystemView(" + oController + "," +  mcViewHolder + ")");
	  m_nIndex = 10;
	  //m_aMenus = new Array();
	  CreateViewContainer(cProps.sViewName);
      EntryViewAnimStart();
      var mcLoadAnimation:MovieClip = m_mcView.createEmptyMovieClip("Loading_MC", 100);
      var mcViewDisabler:MovieClip = m_mcView.createEmptyMovieClip("Loading_MC", 50);
      m_cLoadAnimation = new LoadAnimation(mcLoadAnimation);
	  m_cLoadAnimation.centerLoadClip();
	  m_cLoadAnimation.StartAnimation();
      m_cViewDisabler = new ViewDisable(mcViewDisabler, this);
      //Check if XML data was already loaded previously
      m_aoNewStuff = DataStore.getWhatsNewXmlData();
      if(m_aoNewStuff == null) LoadXmlData();
      else onXmlLoadCompleteRoutine();
   }

   public function setViewEnabled(fEnable:Boolean):Void
   {
      m_mcBoard["BtnNext_MC"].enabled = fEnable;
      EnableCurDisplayedItems(fEnable);
      super.setViewEnabled(fEnable);
   }

   private function EnableCurDisplayedItems(fEnable:Boolean):Void
   {
      var aItems:Array = m_cSeqLoader.getLoadItems();
      var nItems:Number = aItems.length;
      for(var n:Number = 0; n < nItems; n++)
      {
         aItems[n]["mc"]._parent.enabled = fEnable;
      }
   }

   private function LoadXmlData():Void
   {
      m_cXmlParser = new NewStuffXmlParser(DATA_XML_PATH);
      m_cXmlParser.parseXmlData();
	  m_cXmlParser.addListener(Fxn.FunctionProxy(this, onXmlLoadComplete));
   }

   private function onXmlLoadComplete(fSuccess:Boolean):Void
   {
      if(fSuccess == true);
      {
         m_aoNewStuff = m_cXmlParser.getEntireData(); //sDesc, sHeader, sImgPath
         DataStore.setWhatsNewXmlData(m_aoNewStuff);
         //m_aoNewStuff = m_cXmlParser.getWhatsNewData();
         //CreateCorkBoard();
         //m_cLoadAnimation.StopAnimation();
         //m_cLoadAnimation.destroy();
		 //delete m_cLoadAnimation;
         onXmlLoadCompleteRoutine();
	  }
   }

   private function onXmlLoadCompleteRoutine():Void
   {
      CreateCorkBoard();
      m_cLoadAnimation.StopAnimation();
   }

   private function CreateCorkBoard():Void
   {
      var nX:Number = 100;
      var nY:Number = 135;
      m_mcBoard = m_mcView.attachMovie("CorkBoard_MC", "Board_MC", m_nIndex++, {_x:nX,_y:nY});
      //m_mcBoard.onEnterFrame = Fxn.FunctionProxy(this, initCorkBoard);
	  m_mcBoard["FrameAid_MC"].onEnterFrame = function() {this.play(); delete this.onEnterFrame;}
      m_mcBoard["Mask_MC"].onEnterFrame = function() {this.play(); delete this.onEnterFrame;}
      m_mcBoard.onEnterFrame = Fxn.FunctionProxy(this, CorkBoardInit);
   }

   private function CreatePromoItems(nIndex:Number):Void
   {
      var nItems:Number = m_aoNewStuff.length;
      var nNextIndex:Number = nIndex + MAX_DISPLAY_ITEMS;
      if(nNextIndex >= nItems) nNextIndex = 0;
	  m_cSeqLoader = new SeqContentLoader();
      m_cSeqLoader.setItemLoadEvent(Fxn.FunctionProxy(this, onSinglePromoLoad));
      m_cSeqLoader.setSeqLoadCompleteEvent(Fxn.FunctionProxy(this, onPromosBatchLoadComplete));
							
      var nCount:Number = 0;
	  while(nCount++ < MAX_DISPLAY_ITEMS)
      {
         var nDepth:Number = m_mcStuffHolder.getNextHighestDepth();
         var mcPromoHolder:MovieClip = m_mcStuffHolder.createEmptyMovieClip("PromoHolder_MC" + nDepth, nDepth);
		 var mcPromoBg:MovieClip = mcPromoHolder.createEmptyMovieClip("PromoBg_MC", 0);
         var mcPromo:MovieClip = mcPromoHolder.createEmptyMovieClip("Promo_MC", 1);
		 var oData:Object = m_aoNewStuff[nIndex];
         var sFolder:String = PROMOS_FOLDER;
         if(oData["fPromo"] == false) sFolder = WHATS_NEW_FOLDER;
         mcPromoHolder._alpha = 0;
		 m_cSeqLoader.addLoadItem(sFolder + "Thumbnails/" + oData["sImgPath"], mcPromo, nIndex);
		 mcPromoHolder._x += nCount * 50;
		 mcPromoHolder._y = 50;
         if(++nIndex >= nItems) break;
      }
      m_cSeqLoader.startLoad();
	  
	  //_root.onEnterFrame = function() {trace("EXISTS: " + _global.ss._name + ":" + _global.ss._visible + ":" + _global.ss._alpha + ":" + _global.ss._x + "x" + _global.ss._y);}
      /*
      var nMaxCells:Number = 20;
      var aCellSpaces:Array = [1,2,4,6,9,12,16,nMaxCells];
      var nCells:Number = 4;
      var n:Number = 0;
      while(n <= nMaxCells) if(aCellSpaces[n++] >= nCells) break;
      nCells = aCellSpaces[n-1];
      if(nCells == undefined) nCells = nMaxCells;
      var oDim:Object = getCellDivision(nCells);
      */
	
	  m_mcBoard["BtnNext_MC"]._visible = false;
      if(nItems > MAX_DISPLAY_ITEMS) m_mcBoard["BtnNext_MC"]._visible = true;
      m_mcBoard["BtnNext_MC"].onPress = Fxn.FunctionProxy(this, onNextButtonPress, [nNextIndex]);
   }

   private function onNextButtonPress(nNextIndex:Number):Void
   {
      EnableCurDisplayedItems(false);
      var aItems:Array = m_cSeqLoader.getLoadItems();
      var nItems:Number = aItems.length;
      var nTime:Number = 1;
      for(var nIndex:Number = 0; nIndex < nItems; nIndex++)
      {
         var oItem:Object = aItems[nIndex];
         var mcHolder:MovieClip = oItem["mc"]._parent;
         if(false == oItem["fLoaded"]) mcHolder.removeMovieClip();
         else
		 {
            m_cSeqLoader.destroy();
            var cT:EventTimer = new EventTimer(Fxn.FunctionProxy(this, animateDisplayItemExit, [mcHolder, nIndex]), nTime);
	        cT.StartTimer();
		 }
         nTime += 30;
	  }
      CreatePromoItems(nNextIndex);
      CreateLoadProgress();
   }

   private function animateDisplayItemExit(mcHolder:MovieClip, nIndex:Number):Void
   {
      var nItemsPerRow:Number = MAX_DISPLAY_ITEMS * 0.5;
      var nRow:Number = int(nIndex%MAX_DISPLAY_ITEMS / nItemsPerRow);
      var nFiRot:Number = -25 + Fxn.RandomNumber() * 50;
      var mcPushPin:MovieClip = mcHolder["PushPin_MC"];
      var nDistance:Number = 450 - mcHolder._y;
      var nTime:Number = 0.4*(nDistance/250);
      new Tween(mcPushPin, "_y", Strong.easeOut, mcPushPin._y, mcPushPin._y-50, 0.3, true);
      new Tween(mcPushPin, "_x", Strong.easeOut, mcPushPin._x, mcPushPin._x-50, 0.3, true);
      new Tween(mcPushPin, "_alpha", Strong.easeOut, mcPushPin._alpha, 0, 0.3, true);
      var cTw:Tween = new Tween(mcHolder, "_y", Strong.easeIn, mcHolder._y, nDistance, nTime, true);
      cTw = new Tween(mcHolder, "_rotation", Strong.easeIn, mcHolder._rotation, nFiRot, nTime, true);
      cTw.onMotionFinished = Fxn.FunctionProxy(this, removeItem, [mcHolder]);
   }

   private function removeItem(mc:MovieClip):Void {mc.removeMovieClip();}

   private function onSinglePromoLoad(fSuccess:Boolean, mcPromo:MovieClip, nIndex:Number):Void
   {
      //trace("Load Index: " + nIndex + " -> Success: " + fSuccess);
      var oData:Object = m_aoNewStuff[nIndex];
      var fIsPromo:Boolean = oData["fPromo"];
      var sTagLink:String = "TagPromoThing_MC";
      if(false == fIsPromo) sTagLink = "TagNewThing_MC";
	  var mcHolder:MovieClip = mcPromo._parent;
      var nItemsPerRow:Number = MAX_DISPLAY_ITEMS * 0.5;
      var nItemsPerColumn:Number = 2;
      var nColumn:Number = nIndex % nItemsPerRow;
      var nRow:Number = int(nIndex%MAX_DISPLAY_ITEMS / nItemsPerRow);
      var nWidth:Number = 560; //600; //m_mcBoard._width - 2*20; //20 - frame width
      var nHeigh:Number = 260; //280; //m_mcBoard._height - 2*20; //20 - frame height
      var nItemW:Number = nWidth / nItemsPerRow;
      var nItemH:Number = nHeigh / nItemsPerColumn;
	  //var mcHolder:MovieClip = m_mcStuffHolder["PromoHolder_MC" + nIndex];
      var mcPromo:MovieClip = mcHolder["Promo_MC"];
      var nW:Number = 160;
      var nH:Number = 125;
      var nImgW:Number = mcPromo._width;
      var nImgH:Number = mcPromo._height;
      var oDim:Object = Fxn.getMinFitDimensions(nImgW, nImgH, nW, nH);
      //var nScale:Number = nW/nImgW * 100;
      var mcDot:MovieClip = mcHolder.attachMovie("Dot3Pix_MC", "Dot_MC", 3);
      var mcTag:MovieClip = mcHolder.attachMovie(sTagLink, "Tag_MC", 4, {_visible:false});
      var mcPushPin:MovieClip = mcHolder.attachMovie("PushPin_MC", "PushPin_MC", 5);
      var mcBg:MovieClip = mcHolder.attachMovie("WhitePhotoBg_MC","Bg_MC",0);
	  var nMargin:Number = 7;
	  if(mcPromo._width > oDim["nW"])
	  {
	     mcPromo._width = oDim["nW"];
	     mcPromo._height = oDim["nH"];
	  }
      mcPromo._x = nMargin;
	  mcPromo._y = nMargin;
	  
      

      if(mcPromo._width == 0 || mcPromo._height == 0)
	  {
         mcPromo = mcHolder.attachMovie("BlankImage2_MC", "Blank_MC", 2, {_x:nMargin,_y:nMargin});
         mcPromo._width = 160;
	     mcPromo._height = 100;
         mcTag.removeMovieClip();
	  }
      else
      {
         mcTag._x = 0;
         mcTag._y = 0;
         mcTag._visible = true;
	  }
	  if(mcPromo._width < nW) nW = mcPromo._width;
	  if(mcPromo._height < nH) nH = mcPromo._height;
	  mcBg._width = mcPromo._width + nMargin*2;
	  mcBg._height = mcPromo._height + nMargin*2;
	  
	  //setFitProps(mcPromo, mcBg._width, mcBg._height, mcBg._width, mcBg._height, nMargin);
	  
	  var cShadow:ShadowHighlight = new ShadowHighlight(mcBg);
	  cShadow.SetColor(0x000000);
	  cShadow.SetBlur(5);
      cShadow.AddFilter();
	  //oImgData["cGlow"] = cGlow;
	  
	  //PushPin
	  var nX:Number = Fxn.RandomNumber() * (mcPromo._width - mcPushPin._width/2 - 10);
	  var nY:Number = Fxn.RandomNumber() * (mcPromo._height - mcPushPin._height/2 - 10);
      //var nPinRot:Number = -7 + Fxn.RandomNumber() * 14;
      mcPushPin._x = -mcPushPin._width/2 + nX;
      mcPushPin._y = 5-mcPushPin._height/2 + nY;
      mcDot._x = mcPushPin._x + mcPushPin._width - 6;
      mcDot._y = mcPushPin._y + mcPushPin._height - 2;
      //mcPushPin._rotation = nPinRot;
	  //Promo Holder
      var nTime:Number = 0.7 + 0.3*(nRow + 1);
      var nInitRot:Number = -25 + Fxn.RandomNumber() * 50;
	  mcHolder._x = 50 + nItemW * nColumn /*; //*/ - 10 + Fxn.RandomNumber() * 10;
      mcHolder._y = 40 + nItemH * nRow /*; //*/ -10 + Fxn.RandomNumber() * 10;
	  mcHolder._rotation = -7 + Fxn.RandomNumber() * 14;
      var nInitY:Number = -mcHolder._height - 40;
	  
	  //var cT:EventTimer = new EventTimer(Fxn.FunctionProxy(this, pinThePromo, [mcPushPin]), 500*(nRow + 1));
	  //cT.StartTimer();

	  new Tween(mcHolder, "_y", Strong.easeIn, nInitY, mcHolder._y, nTime, true);
      new Tween(mcHolder, "_rotation", Strong.easeIn, nInitRot, mcHolder._rotation, nTime, true);
      mcHolder._alpha = 100;
      //var nTotal:Number = m_aoNewStuff.length;
      //var nDispTotal:Number = nTotal - nIndex;
      var nItem:Number = nIndex%MAX_DISPLAY_ITEMS + 1;
      var nDispTotal:Number = m_cSeqLoader.getLoadItems().length;
      //var nPercLoaded:Number = m_cSeqLoader.getPercentLoaded();
	  //m_mcLoading["LoadProgress_MC"]._xscale = nPercLoaded*100;
      m_mcLoading["Progress_TXT"].text = "Loading: " + nItem + "/" + nDispTotal;
	  mcHolder.onPress = Fxn.FunctionProxy(this, onPromoPress, [nIndex, mcHolder]);
      mcHolder.onRollOut = Fxn.FunctionProxy(this, onPromoItemRollOut, [nIndex, mcHolder]);
      mcHolder.onRollOver = Fxn.FunctionProxy(this, onPromoItemRollOver, [nIndex, mcHolder]);
   }

   private function onPromoItemRollOver(nIndex:Number, mcHolder:MovieClip):Void
   {
      mcHolder._alpha = 90;
	  var cGlow:GlowHighlight = new GlowHighlight(mcHolder);
	  cGlow.SetColor(0xFFFFFF);
	  cGlow.SetBlur(50);
      cGlow.AddFilter();
      mcHolder["cGlow"] = cGlow;
   }

   private function onPromoItemRollOut(nIndex:Number, mcHolder:MovieClip):Void
   {
      mcHolder._alpha = 100;
      mcHolder["cGlow"].destroy();
      delete mcHolder["cGlow"];
   }

   private function onPromoPress(nIndex:Number, mcHolder:MovieClip):Void
   {
      onPromoItemRollOut(nIndex, mcHolder);
      m_cLoadAnimation.StartAnimation();
      m_cViewDisabler.disableView();
      CreatePromoPopup(nIndex);
   }

   /*
   private function pinThePromo(mcPushPin:MovieClip):Void
   {
      new Tween(mcPushPin, "_y", Strong.easeIn, mcPushPin._y-50, mcPushPin._y, 0.3, true);
      new Tween(mcPushPin, "_x", Strong.easeIn, mcPushPin._x-50, mcPushPin._x, 0.3, true);
   }*/

   /*
   private function setFitProps(mc:MovieClip, nW:Number, nH:Number, nFitW:Number, nFitH:Number, nMargin:Number):Void
   {
      var oDim:Object = Fxn.getMinFitDimensions(nW, nH, nFitW-nMargin, nFitH-nMargin);
	  mc._width = oDim["nW"];
	  mc._height = oDim["nH"];
      mc._x = nMargin*0.5;
	  mc._y = nMargin*0.5;
   }*/

   private function CreatePromoPopup(nIndex:Number):Void
   {
      var oData:Object = m_aoNewStuff[nIndex];
      var sFolder:String = PROMOS_FOLDER;
      if(oData["fPromo"] == false) sFolder = WHATS_NEW_FOLDER;
      var mcPromoHolder:MovieClip = m_mcView.createEmptyMovieClip("PromoHolder_MC", 60);
      m_cPromoPopup = new PromoPopup(mcPromoHolder, Fxn.FunctionProxy(this, onBigPromoPicLoad));
      m_cPromoPopup.setLoadPath(sFolder + "Originals/" + oData["sImgPath"]);
      m_cPromoPopup.addExBtnPressHandler(Fxn.FunctionProxy(this, onPopupExPress));
	  m_cPromoPopup.createPopup();
      m_cPromoPopup.setPosition(115, 125);
   }

   private function onBigPromoPicLoad():Void
   {
      m_cLoadAnimation.StopAnimation();

   }

   private function onPopupExPress():Void
   {
      m_cViewDisabler.enableView();
   }

   private function onPromosBatchLoadComplete():Void
   {
      var nTime:Number = 1;
      var cTw:Tween = new Tween(m_mcLoading, "_alpha", Strong.easeIn, m_mcLoading._alpha, 0, nTime, true);
      cTw.onMotionFinished = Fxn.FunctionProxy(this, removeItem, [m_mcLoading]);
      m_cLoadAnimation.StopAnimation();
   }

   /*
   private function getCellDivision(nCells:Number):Object
   {
      var nRows:Number = 1;
      var nColumns:Number = 1;
      switch(nCells)
      {
         case 0:
         case 1: nRows = 1; nColumns = 1; break;
         case 2: nRows = 1; nColumns = 2; break;
         case 4: nRows = 2; nColumns = 2; break;
         case 6: nRows = 2; nColumns = 3; break;
         case 9: nRows = 2; nColumns = 3; break;
         case 12: nRows = 3; nColumns = 4; break;
         case 16: nRows = 4; nColumns = 4; break;
         default: nRows = 4; nColumns = 5; break;
      }
      return {nRows:nRows, nColumns:nColumns};
   }
   */

   private function CorkBoardInit():Void
   {
      delete m_mcBoard.onEnterFrame;
      m_mcStuffHolder = m_mcBoard["Cork_MC"].createEmptyMovieClip("Stuff_MC", 0);
	  CreatePromoItems(0);
      CreateLoadProgress();
      //new Tween(m_mcBoard, "_x", Strong.easeOut, -0, 0, 1, true);
   }

   private function CreateLoadProgress():Void
   {
      var nDepth:Number = m_mcBoard["Cork_MC"].getNextHighestDepth();
	  var nDispTotal:Number = m_cSeqLoader.getLoadItems().length;
	  //m_mcLoading["LoadProgress_MC"]._xscale = 0;
      m_mcLoading.removeMovieClip();
      m_mcLoading = m_mcBoard["Cork_MC"].attachMovie("WhatsNewLoadProgress_MC", "Load_MC" + nDepth, nDepth);
      m_mcLoading._x = (m_mcBoard["Frame_MC"]._width - m_mcLoading._width)*0.5;
      m_mcLoading._y = (m_mcBoard["Frame_MC"]._height - m_mcLoading._height)*0.5;
      m_mcLoading["Progress_TXT"].text = "Loading: " + "0/" + nDispTotal;
      //m_cLoadAnimation.StartAnimation();
   }

   public function EntryViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("WhatsNewView::EntryViewAnimStart");
      super.EntryViewAnimStart(pfDoneEvent);
	  //CreateCorkBoard();
   }

   public function ExitViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("WhatsNewView::ExitViewAnimStart");
      super.ExitViewAnimStart(pfDoneEvent);
      m_cXmlParser.destroy();
	  m_cViewDisabler.removeListener();
      m_cViewDisabler.enableView(true);
      m_cPromoPopup.exitPopup();
      m_cPromoPopup.stopLoadingClip();
      onPromosBatchLoadComplete();
      setViewEnabled(false);
      m_cSeqLoader.destroy();
      var nCurFrame:Number = m_mcBoard["FrameAid_MC"]._currentframe;
	  var nStartFrame:Number = 1;
      var nEndFrame:Number = 13;
      var nPercComplete:Number = (nCurFrame - nStartFrame) / (nEndFrame - nStartFrame);
      //Start Animation for Exit Routine
	  nStartFrame = 32;
      nEndFrame = 44;
      nCurFrame = nStartFrame + Fxn.RoundOff((nEndFrame - nStartFrame)*(1.00 - nPercComplete));
	  m_mcBoard["FrameAid_MC"].gotoAndPlay(nCurFrame + 1);
	  m_mcBoard["Mask_MC"].gotoAndPlay(nCurFrame + 1);
	  var cT:EventTimer = new EventTimer(Fxn.FunctionProxy(this, exitAnimComplete), 1200);
	  cT.StartTimer();
   }

   private function exitAnimComplete():Void
   {
      super.ExitViewAnimComplete();
   }

   public function destroy(Void):Void
   {
      trace("WhatsNewView::destroy");
      m_cLoadAnimation.destroy();
	  m_cXmlParser.destroy();
      m_cSeqLoader.destroy();
      m_cViewDisabler.destroy();
      delete m_aCurDisplayItems;
	  delete m_aoNewStuff;
	  delete m_aoNewStuff;
	  delete m_cXmlParser;
	  delete m_cLoadAnimation;
	  m_mcBoard.removeMovieClip();
      super.destroy();
   }
}