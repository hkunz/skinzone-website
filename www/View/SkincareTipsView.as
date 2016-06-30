import mx.transitions.*;
import mx.transitions.easing.*;

class SkincareTipsView extends MvcView
{
   private var m_cLoadAnimation:LoadAnimation;
   private var m_cXmlParser:SkincareTipsDataXmlParser;
   private var m_cPad:YellowPad;
   private var m_nIndex:Number; //MovieClip Depth Index
   private var m_aoTipsData:Array;

   static private var SKINCARE_TIPS_DATA_XML_PATH:String = "Library/Xml/SkincareTipsData.xml";

   public function SkincareTipsView(oController:MvcController, mcViewHolder:MovieClip, cProps:ViewProps)
   {
      super(oController, mcViewHolder, cProps);
      trace("SkincareTipsView::SkincareTipsView(" + oController + "," +  mcViewHolder + ")");
	  m_nIndex = 10;
	  CreateViewContainer(cProps.sViewName);
	  var mcLoad:MovieClip = m_mcView.createEmptyMovieClip("Load_MC", 100);
	  m_cLoadAnimation = new LoadAnimation(mcLoad);
	  m_cLoadAnimation.centerLoadClip();
	  m_cLoadAnimation.StartAnimation();
      //Check if XML data was already loaded previously
      m_aoTipsData = DataStore.getTipsXmlData();
      if(m_aoTipsData == null) LoadXmlData();
      else onXmlLoadCompleteRoutine();
   }

   private function LoadXmlData():Void
   {
      m_cXmlParser = new SkincareTipsDataXmlParser(SKINCARE_TIPS_DATA_XML_PATH);
      m_cXmlParser.addListener(Fxn.FunctionProxy(this, onXmlLoadComplete));
      m_cXmlParser.parseXmlData();
   }

   public function onXmlLoadComplete(fSuccess:Boolean):Void
   {
      if(fSuccess == true)
      {
         m_aoTipsData = m_cXmlParser.getTipsData();
         DataStore.setTipsXmlData(m_aoTipsData);
         onXmlLoadCompleteRoutine();
	  }
      else trace("ERROR: Corrupt XML File");
      m_cLoadAnimation.StopAnimation();
   }

   private function onXmlLoadCompleteRoutine():Void
   {
      createYellowPad();
      m_cPad.setPageData(m_aoTipsData);
      m_cLoadAnimation.StopAnimation();
      delete m_aoTipsData; //No more need this reference
   }

   public function EntryViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("AboutUsView::EntryViewAnimStart");
      super.EntryViewAnimStart(pfDoneEvent);

   }

   public function ExitViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("AboutUsView::ExitViewAnimStart");
      super.ExitViewAnimStart(pfDoneEvent);
      m_cXmlParser.destroy();
      m_cLoadAnimation.destroy();
	  var mcPad:MovieClip = m_cPad.getHolder();
      var cTw:Tween = new Tween(m_mcView["Next_MC"], "_alpha", null, m_mcView["Next_MC"]._alpha, 0, 1, true);
	  new Tween(m_mcView["Prev_MC"], "_alpha", null, m_mcView["Prev_MC"]._alpha, 0, 1, true);
      //new Tween(mcPad, "_alpha", Strong.easeOut, mcPad._alpha, 0, 0.5, true);
      //new Tween(mcPad, "_xscale", Strong.easeOut, mcPad._xscale, 120, 0.5, true);
	  //new Tween(mcPad, "_y", Strong.easeOut, mcPad._y, -mcPad._height, 0.5, true);
	  m_mcView["Mask_MC"].removeMovieClip();
	  m_cPad.destroy();
	  cTw.onMotionFinished = Fxn.FunctionProxy(this, exitAnimComplete);
   }

   private function exitAnimComplete():Void
   {
      super.ExitViewAnimComplete();
   }

   private function createYellowPad():Void
   {
      var mcPad:MovieClip = m_mcView.createEmptyMovieClip("YellowPad_MC", m_nIndex++);
      var mcMask:MovieClip = m_mcView.attachMovie("ViewDisable_MC", "Mask_MC", m_nIndex++, {_x:50, _y:105});
	  mcPad.setMask(mcMask);
	  //m_mcItemsHolder.setMask(m_mcMask);
      m_cPad = new YellowPad(mcPad);
	  m_cPad.createPad();
      //new Tween(mcPad, "_y", Strong.easeOut, -mcPad._height, mcPad._y, 0.5, true);
      //new Tween(mcPad, "_xscale", Strong.easeOut, 120, 100, 0.5, true);
	  mcPad._x = Constant.STAGE_WIDTH_HALF - mcPad._width*0.5;
	  mcPad._y = Constant.STAGE_HEIGHT_HALF - mcPad._height*0.5;
	  mcPad._rotation = -3;
      var mcPage:MovieClip = m_cPad.createBlankPage();
	  m_cPad.createTitlePage();
      var cEventTimer = new EventTimer(Fxn.FunctionProxy(m_cPad, m_cPad.doFlipNext, [mcPage]), 100);
      cEventTimer.StartTimer();
      var mcNextBtn:MovieClip = m_mcView.attachMovie("NextPhotoBtn_MC", "Next_MC", m_nIndex++);
	  var mcPrevBtn:MovieClip = m_mcView.attachMovie("PrevPhotoBtn_MC", "Prev_MC", m_nIndex++);
	  new Tween(mcNextBtn, "_alpha", Strong.easeOut, 0, 100, 1, true);
	  new Tween(mcPrevBtn, "_alpha", Strong.easeOut, 0, 100, 1, true);
	  mcNextBtn._x = 745;
	  mcNextBtn._y = 445;
      mcPrevBtn._x = 690;
	  mcPrevBtn._y = 445;
      mcNextBtn.onPress = Fxn.FunctionProxy(this, flipNextPage);
      mcPrevBtn.onPress = Fxn.FunctionProxy(this, flipPrevPage);
	  mcPad._x = 180;
	  mcPad._y = 115;
   }

   private function flipNextPage():Void
   {
      m_cPad.flipNextPage();
   }

   private function flipPrevPage():Void
   {
      m_cPad.flipPrevPage();
   }

   public function destroy(Void):Void
   {
      trace("SkincareTipsView::destroy");
      m_cLoadAnimation.destroy();
	  m_cPad.destroy();
      m_cXmlParser.destroy();
      delete m_aoTipsData;
	  delete m_cLoadAnimation;
	  delete m_cXmlParser;
	  delete m_cPad;
      super.destroy();
   }
}