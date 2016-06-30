class YellowPad
{
   private var m_mcHolder:MovieClip;
   private var m_mcPad:MovieClip;
   private var m_mcPages:MovieClip;
   private var m_mcPassPage:MovieClip;
   private var m_mcPage:MovieClip;
   private var m_aActivePageData:Array; //Length 1 if flipping ends
   private var m_aPageData:Array;
   private var m_nPage:Number;

   static private var LOAD_FOLDER:String = "Library/Graphics/SkincareTips/Thumbnails/"
   static private var CLIP_DEPTH:Number = 5000000;
   static private var COEXIST_ACTIVE_PAGES:Number = 3;

   public function YellowPad(mcHolder:MovieClip)
   {
      m_mcHolder = mcHolder;
      m_aActivePageData = new Array();
      m_nPage = 0;
   }

   public function createPad():Void
   {
      m_mcPad = m_mcHolder.attachMovie("YellowPad_MC", "YellowPad_MC", 0);
	  m_mcPages = m_mcPad.createEmptyMovieClip("Pages_MC", 0);
   }

   public function createBlankPage():MovieClip
   {
      var mcPage:MovieClip = m_mcPages.attachMovie("FlipPage_MC", "FlipPage_MC", CLIP_DEPTH+1);
      var mcContent:MovieClip = mcPage["FlipContent_MC"];
	  mcPage.pfFlipDone = Fxn.FunctionProxy(this, removePage, [mcPage]);
	  return mcPage;
   }

   private function removePage(mcPage:MovieClip):Void
   {
      mcPage.removeMovieClip();
   }

   public function createTitlePage():Void
   {
      var mcPage:MovieClip = m_mcPages.attachMovie("FlipPage_MC", "FlipPage_MC", CLIP_DEPTH);
      var mcContent:MovieClip = mcPage["FlipContent_MC"];
      var oPage:Object = new Object();
	  var sLink:String = "SkincareTipsTitle_MC";
      var mcTipsTitle:MovieClip = mcContent.attachMovie(sLink, sLink, 0);
	  var txtPage:TextField = mcPage["Page_TXT"];
      txtPage.text = ""; //"" + m_nPage;
	  mcTipsTitle._x = 40;
	  mcTipsTitle._y = 140;
	  oPage["mcPage"] = mcPage;
      oPage["nPage"] = m_nPage; //Zero
	  m_aActivePageData[m_nPage + ""] = oPage;
   }

   public function createPrevPage():MovieClip
   {
      var nDepth:Number = m_mcPages.getNextHighestDepth();
      var oPage:Object = new Object();
      var nPage:Number = m_nPage;
	  var mcPage:MovieClip = m_mcPages.attachMovie("FlipPage_MC", "FlipPage_MC" + nPage, nDepth, {_visible:false});
	  oPage["mcPage"] = mcPage;
	  setPageContent(mcPage, nPage);
	  m_aActivePageData["" + nPage] = oPage; //m_aActivePageData.splice(0, 0, oPage); //Insert at start of array
      var nPageToRemove:Number = m_nPage + COEXIST_ACTIVE_PAGES;
	  var oPrevPageData:Object = m_aActivePageData["" + nPageToRemove];
	  var mcPageToRemove:MovieClip = oPrevPageData["mcPage"];
	  if(oPrevPageData != undefined)
	  {
	     mcPageToRemove.removeMovieClip();
         delete m_aActivePageData["" + nPageToRemove];
	  }
      return mcPage;
   }

   public function createNextPage():Void
   {
      var oLastActivePage:Object = m_aActivePageData[m_nPage + ""];
      var nDepth:Number = oLastActivePage["mcPage"].getDepth() - 1;
      var oPage:Object = new Object();
      var nPage:Number = ++m_nPage;
	  var mcPage:MovieClip = m_mcPages.attachMovie("FlipPage_MC", "FlipPage_MC" + nPage, nDepth);
	  setPageContent(mcPage, nPage);
      oPage["mcPage"] = mcPage;
	  m_aActivePageData["" + nPage] = oPage;
      var nPageToRemove:Number = m_nPage - COEXIST_ACTIVE_PAGES;
	  var oPrevPageData:Object = m_aActivePageData["" + nPageToRemove];
	  var mcPageToRemove:MovieClip = oPrevPageData["mcPage"];
	  if(oPrevPageData != undefined)
	  {
	     mcPageToRemove.removeMovieClip();
         delete m_aActivePageData["" + nPageToRemove];
	  }
   }

   private function setPageContent(mcPage:MovieClip, nPage:Number):Void
   {
      var mcContent:MovieClip = mcPage["FlipContent_MC"];
	  var txtPage:TextField = mcPage["Page_TXT"];
	  var sLink:String = "SkincareTipHolder_MC";
      var fTitle:Boolean = (nPage == 0);
      if(true == fTitle) sLink = "SkincareTipsTitle_MC";
	  var nPage:Number = nPage;
      var oData:Object = m_aPageData[nPage - 1];
	  var mcTipHolder:MovieClip = mcContent.attachMovie(sLink, sLink, 0);
      var mcImage:MovieClip = mcTipHolder["SkincareTip_MC"]["ImgHolder_MC"]["Img_MC"];
      var cLoader:ContentLoader = new ContentLoader(mcImage);
      var sText:String = oData["sDesc"];
      var mcTip:MovieClip = mcTipHolder["SkincareTip_MC"];
      trace("SET: " + mcTipHolder._name);
	  trace("SET: " + mcTipHolder["SkincareTip_MC"]["ImgHolder_MC"]._name);
	  trace("SET: " + mcTipHolder["SkincareTip_MC"]["ImgHolder_MC"]["Img_MC"]._name);
	  cLoader.SetLoadEvent(Fxn.FunctionProxy(this, onPicLoad));
	  cLoader.LoadFile(LOAD_FOLDER + oData["sImgPath"]);
	  if(true == fTitle) txtPage.text = "";
      else txtPage.text = nPage.toString();
      mcTip["Header_TXT"].text = oData["sHeader"];
      mcTip["DescPart1_TXT"].text = sText;
	  var oExtent:Object = Fxn.getTextExtent(mcTip["DescPart1_TXT"]);
	  mcTip["DescPart1_TXT"].text = sText.substr(0, oExtent["nIndex"]);
	  if(true == oExtent["fExceeded"])
	  {
         mcTip["DescPart1_TXT"].text += "_________________";
         mcTip["DescPart2_TXT"].text = sText.substr(oExtent["nIndex"]);
	  }
      mcTipHolder._x = 50;
	  mcTipHolder._y = 110;
	  //Extend Desc2 Field Height to reflect extended text
	  var cFmt:TextFormat = mcTip["DescPart2_TXT"].getTextFormat();
      var oExt:Object = cFmt.getTextExtent(mcTip["DescPart2_TXT"].text, mcTip["DescPart2_TXT"]._width);
      mcTip["DescPart2_TXT"]._height = oExt["textFieldHeight"];	  
   }

   private function onPicLoad(fSuccess:Boolean):Void
   {

   }

   public function flipNextPage():Void
   {
      if(m_nPage == m_aPageData.length) return;
      var oCurPageData:Object = m_aActivePageData["" + m_nPage];
      var mcCurPage:MovieClip = oCurPageData["mcPage"];
      doFlipNext(mcCurPage);
	  createNextPage();
	  //mcCurPage.pfFlipDone = Fxn.FunctionProxy(this, onFlipDone, [m_nPage]);
   }

   public function doFlipNext(mcCurPage:MovieClip):Void
   {
      var nCurFrame:Number = mcCurPage._currentframe;
      //Start Animation for Entry Routine
      var nStartFrame:Number = 41;
      var nEndFrame:Number = 69;
      var nPercComplete:Number = (nCurFrame - nStartFrame) / (nEndFrame - nStartFrame);
	  if(nCurFrame < nStartFrame) nPercComplete = 1.00;
      //Start Animation for Exit Routine
	  nStartFrame = 2;
      nEndFrame = 30;
      nCurFrame = nStartFrame + Fxn.RoundOff((nEndFrame - nStartFrame)*(1.00 - nPercComplete));
	  //m_mcPage["Mask_MC"].gotoAndStop(nCurFrame);
	  mcCurPage.gotoAndPlay(nCurFrame);
	  //m_mcPage.gotoAndPlay("nextpage");
   }

   public function flipPrevPage():Void
   {
      var nPage:Number = --m_nPage;
	  if(m_nPage < 0) {m_nPage = 0; return;}
      var oCurPageData:Object = m_aActivePageData["" + nPage];
      var mcCurPage:MovieClip = oCurPageData["mcPage"];
      if(mcCurPage == undefined)
	  {
	     mcCurPage = createPrevPage();
		 mcCurPage.onEnterFrame = Fxn.FunctionProxy(this, doFlipPrev, [mcCurPage]);
	  }else doFlipPrev(mcCurPage);
      //m_mcPage.gotoAndPlay("prevpage");
   }

   private function doFlipPrev(mcCurPage:MovieClip):Void
   {
      var nCurFrame:Number = mcCurPage._currentframe;
      //Start Animation for Entry Routine
      var nStartFrame:Number = 2;
      var nEndFrame:Number = 30;
      var nPercComplete:Number = (nCurFrame - nStartFrame) / (nEndFrame - nStartFrame);
      if(nCurFrame == 1) nPercComplete = 1.00;
      //Start Animation for Exit Routine
	  nStartFrame = 41;
      nEndFrame = 69;
      nCurFrame = nStartFrame + Fxn.RoundOff((nEndFrame - nStartFrame)*(1.00 - nPercComplete));
	  //m_mcPage["Mask_MC"].gotoAndStop(nCurFrame);
	  mcCurPage.gotoAndPlay(nCurFrame);
      //mcCurPage.pfFlipDone = Fxn.FunctionProxy(this, onFlipDone, [m_nPage]);
	  //mcCurPage._visible = true;
   }
   /*
   private function onFlipDone(nPage:Number):Void
   {
      var oPageData:Object = m_aActivePageData["" + nPage];
	  var mcPageToRemove:MovieClip = oPageData["mcPage"];
	  mcPageToRemove.removeMovieClip();
	  delete m_aActivePageData["" + nPage];
   }
   */

   public function setPageData(aData:Array):Void
   {
      m_aPageData = aData;
   }

   public function getHolder():MovieClip {return m_mcHolder;}

   public function destroy():Void
   {
      delete m_mcPage;
      delete m_aPageData;
      m_mcHolder.removeMovieClip();
   }
}