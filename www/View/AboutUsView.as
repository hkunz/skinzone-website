import mx.transitions.*;
import mx.transitions.easing.*;

class AboutUsView extends MvcView
{
   private var m_cXmlParser:AboutUsDataXmlParser;
   private var m_cGlow:GlowHighlight;
   private var m_cLoadAnimation:LoadAnimation;
   private var m_cScroller:MovieClipScroller;
   private var m_mcMask:MovieClip;
   private var m_mcContent:MovieClip;
   private var m_nIndex:Number; //MovieClip Depth Index
   private var m_mcBox:MovieClip;
   private var m_aoAboutUsData:Object;

   static private var ABOUT_US_DATA_XML_PATH:String = "Library/Xml/AboutUsData.xml";

   public function AboutUsView(oController:MvcController, mcViewHolder:MovieClip, cProps:ViewProps)
   {
      super(oController, mcViewHolder, cProps);
      trace("AboutUsView::AboutUsView(" + oController + "," +  mcViewHolder + ")");
	  //About us - Services R
	  m_nIndex = 0;
	  CreateViewContainer(cProps.sViewName);
	  //Loading Animation
      m_mcBox = m_mcView.attachMovie("AboutUsTextBg_MC", "Box_MC", m_nIndex++);
	  m_mcBox._visible = false;
	  var mcLoadAnimation:MovieClip = m_mcView.createEmptyMovieClip("Loading_MC", 10);
      m_cLoadAnimation = new LoadAnimation(mcLoadAnimation);
	  m_cLoadAnimation.centerLoadClip();
	  m_cLoadAnimation.StartAnimation();
      m_aoAboutUsData = DataStore.getAboutUsXmlData();

      if(m_aoAboutUsData == null) LoadXmlData();
      else onXmlLoadCompleteRoutine();
   }

   private function LoadXmlData():Void
   {
      m_cXmlParser = new AboutUsDataXmlParser(ABOUT_US_DATA_XML_PATH);
      m_cXmlParser.addListener(Fxn.FunctionProxy(this, onXmlLoadComplete));
      m_cXmlParser.parseXmlData();
   }

   private function onXmlLoadComplete(fSuccess:Boolean):Void
   {
      if(true == fSuccess)
	  {
         m_aoAboutUsData = m_cXmlParser.getAboutUsData();
         DataStore.setAboutUsXmlData(m_aoAboutUsData);
         onXmlLoadCompleteRoutine();
	  }
      m_cLoadAnimation.StopAnimation();
   }

   private function onXmlLoadCompleteRoutine():Void
   {
      initBox();
      createContent();
      m_cLoadAnimation.StopAnimation();
   }

   private function initBox():Void
   {
	  m_mcBox._x = 235;
	  m_mcBox._y = 145;
	  m_mcContent._alpha = 0;
	  m_mcBox._alpha = 40;
	  m_cGlow = new GlowHighlight(m_mcBox);
	  m_cGlow.SetColor(0x000000);
	  m_cGlow.SetBlur(30);
      m_cGlow.AddFilter();
   }

   private function createContent():Void
   {
      var mcContainer:MovieClip = m_mcView.createEmptyMovieClip("Container_MC", m_nIndex++);
	  m_cScroller = new MovieClipScroller(mcContainer);
      m_mcContent = m_cScroller.setContentLinkage("AboutUsText_MC");
	  mcContainer._visible = false;
	  var txtAboutUs:TextField = m_mcContent["Text_TXT"];
	  var sAboutUsText:String = m_aoAboutUsData["sText"];
	  m_mcContent["Header_TXT"].text = m_aoAboutUsData["sHeader"];
	  var cTxtFmt:TextFormat = txtAboutUs.getTextFormat();
      var oExtent:Object = cTxtFmt.getTextExtent(sAboutUsText, txtAboutUs._width);
      txtAboutUs._height = oExtent["textFieldHeight"] + 25;
      txtAboutUs.text = sAboutUsText;
	  m_cScroller.setEaseInTweenTime(1);
	  //m_mcMask = m_cScroller.setGraphicMask("GenericSquare_MC");
	  m_mcMask = m_cScroller.setGraphicMask("AboutUsTextBg_MC");
	  var nAdjX:Number = 10;
	  var nAdjY:Number = 10;
	  m_mcMask._x -= nAdjX;
	  m_mcMask._y -= nAdjY;
	  //m_mcMask._width = 460;
	  //m_mcMask._height = 190;
	  //m_mcMask._x = 10;
	  //m_mcMask._y = 10;
	  mcContainer._x = m_mcBox._x + nAdjX;
	  mcContainer._y = m_mcBox._y + nAdjY;
      m_mcBox.onEnterFrame = Fxn.FunctionProxy(this, onBoxLoad); //function() {this.gotoAndPlay("start"); delete this.onEnterFrame;};
	  //m_mcMask.onEnterFrame = function() {this.gotoAndPlay("start"); delete this.onEnterFrame;};
   }

   private function onBoxLoad():Void
   {
      var nMaskW:Number = 460;
      //var nMaskH:Number = 190;
      //m_cScroller.setWidth(nMaskW);
	  //m_cScroller.setHeight(nMaskH);
	  var mcVeScroll:MovieClip = m_cScroller.setVeScroller("LilScroller_MC");
	  mcVeScroll._alpha = 70;
	  var mcContainer:MovieClip = m_cScroller.getContainer();
	  //m_cScroller.updateVeScrollerLength(true);
	  
      //m_cScroller.SetVeScrollEnabled(false);
      //m_cScroller.setVeScrollerPosition(m_mcBox._width - 50, 0);
      m_mcBox.gotoAndPlay("start");
      m_mcMask.gotoAndPlay("start");
      m_mcBox._visible = true;
	  m_cScroller.setVeContentProps(0, m_mcContent._height);
      m_cScroller.setVeScrollerPosition(nMaskW - 10, 0);
	  var mcScroll:MovieClip = m_cScroller.getVeScrollBar();
	  mcScroll._alpha = 0;
      mcContainer._visible = true;
	  delete m_mcBox.onEnterFrame;
   }

   public function EntryViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("AboutUsView::EntryViewAnimStart");
      super.EntryViewAnimStart(pfDoneEvent);
      m_mcBox["pfEntryAnimDone"] = Fxn.FunctionProxy(this, animBoxInComplete);
   }

   public function ExitViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("AboutUsView::ExitViewAnimStart");
      super.ExitViewAnimStart(pfDoneEvent);
      m_cXmlParser.destroy();
      m_cLoadAnimation.destroy();
      var mcVeScroll:MovieClip = m_cScroller.getVeScrollBar();
	  var nCurFrame:Number = m_mcBox._currentframe;
      //Start Animation for Entry Routine
      var nStartFrame:Number = 1;
      var nEndFrame:Number = 17;
      var nPercComplete:Number = (nCurFrame - nStartFrame) / (nEndFrame - nStartFrame);
      //Start Animation for Exit Routine
	  nStartFrame = 40;
      nEndFrame = 55;
      nCurFrame = nStartFrame + Fxn.RoundOff((nEndFrame - nStartFrame)*(1.00 - nPercComplete));
	  m_mcBox.gotoAndPlay(nCurFrame);
	  m_mcMask.gotoAndPlay(nCurFrame);
	  m_mcBox["pfExitAnimDone"] = Fxn.FunctionProxy(this, animBoxOutComplete);
	  var mcScroll:MovieClip = m_cScroller.getVeScrollBar();
	  var nTime:Number = 0.5;
      new Tween(mcScroll, "_xscale", Strong.easeOut, mcScroll._xscale, 5, nTime, true);
      new Tween(mcScroll, "_alpha", Strong.easeOut, mcScroll._alpha, 0, nTime, true);
	  new Tween(m_mcContent, "_alpha", Strong.easeOut, m_mcContent._alpha, 0, nTime, true);
   }

   private function animBoxOutComplete():Void
   {
      super.ExitViewAnimComplete();
   }

   private function animBoxInComplete():Void
   {
      super.EntryViewAnimComplete();
	  var mcScroll:MovieClip = m_cScroller.getVeScrollBar();
	  var nTime:Number = 0.5;
      new Tween(mcScroll, "_xscale", Strong.easeOut, 5, mcScroll._xscale, nTime, true);
      new Tween(mcScroll, "_alpha", Strong.easeOut, mcScroll._alpha, 80, nTime, true);
	  new Tween(m_mcContent, "_alpha", Strong.easeIn, m_mcContent._alpha, 100, nTime, true);
   }

   public function destroy(Void):Void
   {
      trace("AboutUsView::destroy");
      m_cXmlParser.destroy();
	  m_cGlow.destroy();
	  m_cScroller.destroy();
	  delete m_cScroller;
	  delete m_cGlow;
	  delete m_cXmlParser;
      super.destroy();
   }
}