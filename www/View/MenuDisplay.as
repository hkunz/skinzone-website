import mx.transitions.*;
import mx.transitions.easing.*;

class MenuDisplay
{
   private var m_pView:SystemView;
   private var m_cDetailsPopup:CompleteDetailsPopup;
   private var m_cShortDescPopup:ShortDescriptionPopup;
   private var m_oWindow:MovieClipScroller;
   private var m_cViewDisable:ViewDisable;
   private var m_mcMenuItems:MovieClip;
   private var m_eCurrentMenu:Number;
   private var m_mcContent:MovieClip;
   private var m_mcContainer:MovieClip;
   private var m_mcMask:MovieClip;
   private var m_pfEvent:Function;
   private var m_oMenuProp:Object;
   private var m_mcHighlight:MovieClip;
   private var m_pfShutDownEvent:Function;
   private var m_fFirstMenuInitDone:Boolean;

   public function MenuDisplay(mcContainer:MovieClip, pView:SystemView, pfEvent:Function)
   {
      //trace("MenuDisplay::MenuDisplay");
      m_mcContainer = mcContainer;
	  m_pfEvent = pfEvent;
	  CreateScrollContent();
      m_pView = pView;
	  m_fFirstMenuInitDone = false;
   }

   public function initDisableViewClip(mcHolder:MovieClip):Void
   {
      m_cViewDisable = new ViewDisable(mcHolder, m_pView);
   }

   public function initShortDescPopup(mcHolder:MovieClip):Void
   {
      m_cShortDescPopup = new ShortDescriptionPopup(mcHolder);
   }

   public function initCompleteDetailsPopup(mcHolder:MovieClip):Void
   {
      m_cDetailsPopup = new CompleteDetailsPopup(mcHolder);
   }

   private function CreateScrollContent():Void
   {
      //trace("MenuDisplay::CreateScrollContent");
      m_oWindow = new MovieClipScroller(m_mcContainer);
	  var oListener:Object = new Object();
      oListener["onKnobPress"] = Fxn.FunctionProxy(this, onMenuStartScroll);
      oListener["onKnobRelease"] = Fxn.FunctionProxy(this, onMenuStopScroll);
      oListener["onVeScroll"] = null;
      m_oWindow.addListener(oListener);
      var mcHolder:MovieClip = m_oWindow.getContainer();
	  mcHolder._alpha = 0;
      m_mcContent = m_oWindow.setContentLinkage("ContentPlaceHolder_MC");
	  var cLoader:ContentLoader = new ContentLoader(m_mcContent["Holder_MC"]);
	  m_oWindow.setEaseInTweenTime(1);
	  cLoader.SetLoadEvent(Fxn.FunctionProxy(this, onWallMenuLoad, [m_mcContent]));
	  cLoader.LoadFile("Library/Graphics/MainMenu/WallMenu.jpg");
      m_mcContainer._x = 350;
	  m_mcContainer._y = 105;
	  m_mcMask = m_oWindow.setGraphicMask("ScrollContentMask_MC");
      //var mcCover:MovieClip = this.attachMovie("Cover_MC", "Cover_MC", 1);
      var mcVeScroll:MovieClip = m_oWindow.setVeScroller("CurvedVeScroller_MC");
      m_oWindow.SetVeScrollEnabled(false);
      m_oWindow.setVeScrollerPosition(m_mcMask._width - 90, 27);
      m_mcContent._x = -500*Fxn.RandomNumber();
      m_mcContent._y = -500*Fxn.RandomNumber();
   }

   public function goToMenu(eMenu:Number, fSkipAnim:Boolean):Void
   {
      //trace("MenuDisplay::goToMenu");
      var nTime:Number = 1.5;
      onMenuStartScroll();
      m_eCurrentMenu = eMenu;
	  enableMenu(false);
      if(fSkipAnim != true) animMask();
      switch(eMenu)
      {
         case Enum.MENU_SKINCARE_SERVICES: m_oMenuProp = {nX:-5,nY:-390,nH:0,nV:510}; break;
	     case Enum.MENU_SALON_SERVICES: m_oMenuProp = {nX:-355,nY:-10,nH:0,nV:670}; break;
	     case Enum.MENU_SPA_SERVICES: m_oMenuProp = {nX:-355,nY:-620,nH:0,nV:350}; break;
	     case Enum.MENU_DOCTOR_SERVICES: m_oMenuProp = {nX:-5,nY:-60,nH:0,nV:350}; break;
	     default: m_oMenuProp = null; trace("ERROR: Invalid Menu " + eMenu);
	  }
	  var cTw:Tween = new Tween(m_mcContent, "_x", Strong.easeOut, m_mcContent._x, m_oMenuProp["nX"], nTime, true);
      cTw = new Tween(m_mcContent, "_y", Strong.easeOut, m_mcContent._y, m_oMenuProp["nY"], nTime, true);
      cTw.onMotionFinished = Fxn.FunctionProxy(this, onMenuTransitionComplete, [eMenu, true]);
      m_oWindow.setVeContentProps(m_oMenuProp["nY"], m_oMenuProp["nV"]);
      m_oWindow.setHoContentProps(m_oMenuProp["nX"], m_oMenuProp["nH"]);
   }

   private function initMenuAnimation():Void
   {
      var cEventTimer:EventTimer = null;
      var mcItem:MovieClip;
      var nTime:Number = 0;
      for(var sMc:String in m_mcMenuItems)
      {
         mcItem = m_mcMenuItems[sMc];
         cEventTimer = new EventTimer(Fxn.FunctionProxy(this, animateMenuItem, [mcItem]), nTime);
         cEventTimer.StartTimer();
         nTime += 50;
      }
      cEventTimer = new EventTimer(Fxn.FunctionProxy(this, initMenuItems), nTime);
      cEventTimer.StartTimer();
   }

   private function onMenuTransitionComplete(eMenu:Number, fMenuInit:Boolean):Void
   {
      var oProperties:Object;
	  enableMenu(true);
	  var pfInit:Function;
      switch(eMenu)
      {
         case Enum.MENU_SKINCARE_SERVICES: oProperties = {nX:0,nY:518,sLinkage:"SkincareMenuItems_MC",pfInit:initSkincareItems}; break;
         case Enum.MENU_SALON_SERVICES: oProperties = {nX:345,nY:133,sLinkage:"SalonMenuItems_MC",pfInit:initSalonItems}; break;
         case Enum.MENU_SPA_SERVICES: oProperties = {nX:345,nY:770,sLinkage:"SpaMenuItems_MC",pfInit:initSpaItems}; break;
         case Enum.MENU_DOCTOR_SERVICES: oProperties = {nX:0,nY:203,sLinkage:"DoctorMenuItems_MC",pfInit:initDoctorItems}; break;
         default: oProperties = null; trace("ERROR: Invalid Menu " + eMenu);
	  }
      m_mcMenuItems = Fxn.AttachGraphic(m_mcContent, oProperties["sLinkage"], 0, oProperties["nX"], oProperties["nY"]);
	  m_mcMenuItems = m_mcMenuItems[oProperties["sLinkage"]];
	  if(fMenuInit == true) initMenuAnimation();
	  else initMenuItems();
	  oProperties["pfInit"].apply(this);
   }

   private function ShowSubMenu(mcItem:MovieClip):Void
   {
      var sLinkage:String = mcItem._name;
      m_mcHighlight._x = mcItem._x;
      m_mcHighlight._y = mcItem._y;
      animateMenuItem(mcItem)
      m_mcHighlight._visible = true;
	  m_cShortDescPopup.showSubMenu(sLinkage);
   }

   private function animateMenuItem(mcItem:MovieClip):Void
   {
      mcItem.play("start");
   }

   private function HideSubMenu():Void
   {
      m_mcHighlight._visible = false;
      m_cShortDescPopup.hideSubMenu();
   }

   private function initMenuItems():Void
   {
      m_oWindow.SetVeScrollEnabled(true);
      for(var sMc:String in m_mcMenuItems)
      {
         var mcItem:MovieClip = m_mcMenuItems[sMc];
         mcItem.onRollOver = Fxn.FunctionProxy(this, ShowSubMenu, [mcItem]);
         mcItem.onPress = Fxn.FunctionProxy(this, ShowCompleteDetails, [mcItem]);
         mcItem.onRollOut = Fxn.FunctionProxy(this, HideSubMenu);
         mcItem.onDragOut = Fxn.FunctionProxy(this, HideSubMenu);
	  }
      m_mcHighlight = m_mcMenuItems.attachMovie("MenuItemHighlight_MC", "MC", 0);
      m_mcHighlight._visible = false;
	  if(m_fFirstMenuInitDone == false)
      {
         m_pView.menuInitComplete();
         m_fFirstMenuInitDone = true;
      }
   }

   private function initSkincareItems():Void
   {

   }

   private function initSalonItems():Void
   {

   }

   private function initSpaItems():Void
   {

   }

   private function initDoctorItems():Void
   {

   }

   private function onMenuStartScroll():Void
   {
      m_mcMenuItems.removeMovieClip();
   }

   private function ShowCompleteDetails(mcItem:MovieClip):Void
   {
      setMenuDisplayEnabled(false);
      var sLinkage:String = mcItem._name + "2"; //..._MC2
      var fExists:Boolean = m_cDetailsPopup.createPopup(sLinkage);
      if(true == fExists)
      {
         m_cShortDescPopup.hideSubMenu();
         m_cViewDisable.addListener(Fxn.FunctionProxy(this, showDetailsPopup));
         //var cT:EventTimer = new EventTimer(Fxn.FunctionProxy(this, showDetailsPopup), 2000);
         //cT.StartTimer();
         m_cViewDisable.disableView();
         //m_cDetailsPopup.showPopup();
         m_mcHighlight.gotoAndPlay("exit");
	  }
      else setMenuDisplayEnabled(true);
   }

   private function showDetailsPopup():Void
   {
      var mcHolder:MovieClip = m_cDetailsPopup.getHolder();
      var nDepth:Number = mcHolder.getNextHighestDepth();
      var mcBackBtn:MovieClip = mcHolder.attachMovie("BackBtn_MC", "BackBtn_MC", nDepth);
      var cButton:GenericButton = new GenericButton(mcBackBtn);
      cButton.SetButtonReleaseEvent(Fxn.FunctionProxy(this, hideDetailsPopup, [mcBackBtn]));
      m_pView.adjustWoodBench(0);
	  mcBackBtn._x = 687;
      mcBackBtn._y = 430;
      m_cDetailsPopup.showPopup();
   }

   public function hideDetailsPopup(mcBackBtn:MovieClip):Void
   {
      mcBackBtn.enabled = false;
      m_cDetailsPopup.hidePopup();
      var cT:Tween = new Tween(mcBackBtn, "_alpha", null, mcBackBtn._alpha, 0, 0.5, true);
      cT.onMotionFinished = Fxn.FunctionProxy(this, revertToCurView, [mcBackBtn]);
   }

   private function revertToCurView(mcButton:MovieClip):Void
   {
      m_cViewDisable.enableView();
      m_pView.revertCurViewProps();
      mcButton.removeMovieClip();
   }

   public function setMenuDisplayEnabled(fEnabled:Boolean):Void
   {
      if(true == fEnabled)
      {
         //m_cViewDisable.enableView();
         initMenuItems();
      }
      for(var sMc:String in m_mcMenuItems) m_mcMenuItems[sMc].enabled = fEnabled;
      m_oWindow.SetVeScrollEnabled(fEnabled);
   }

   private function onMenuStopScroll():Void
   {
      onMenuTransitionComplete(m_eCurrentMenu);
   }

   private function onWallMenuLoad():Void
   {
      //trace("MenuDisplay::onWallMenuLoad");
      m_pfEvent.apply(this);
   }

   public function enableMenu(fEnable:Boolean):Void
   {

   }

   public function exitAnim():Void
   {
      var mcScroller:MovieClip = m_oWindow.getVeScrollBar();
      var nCurFrame:Number = m_mcMask._currentframe;
      //Start Animation for Entry Routine
      var nStartFrame:Number = 35;
      var nEndFrame:Number = 53;
      var nPercComplete:Number = (nCurFrame - nStartFrame) / (nEndFrame - nStartFrame);
      //Start Animation for Exit Routine
      onMenuStartScroll();
	  nStartFrame = 16;
      nEndFrame = 33;
	  if(nCurFrame <= nStartFrame) nPercComplete = 1.00;
      nCurFrame = nStartFrame + Fxn.RoundOff((nEndFrame - nStartFrame)*(1.00 - nPercComplete));
	  m_mcMask.gotoAndPlay(nCurFrame);
	  Fxn.AttachGraphic(m_mcContent, "SzLogoComplete_MC", 20, 225, 820); //Depth 20
      new Tween(m_mcContent, "_x", Strong.easeOut, m_mcContent._x, -130, 1, true);
	  new Tween(m_mcContent, "_y", Strong.easeOut, m_mcContent._y, -750, 1, true);
      new Tween(mcScroller, "_height", Strong.easeOut, mcScroller._height, 0, 1, true);
	  new Tween(mcScroller, "_alpha", Strong.easeOut, mcScroller._alpha, 0, 1, true);
   }

   public function startAnim():Void
   {
      var mcScroller:MovieClip = m_oWindow.getVeScrollBar();
      new Tween(mcScroller, "_alpha", Strong.easeOut, 0, 100, 1, true);
	  new Tween(mcScroller, "_yscale", Strong.easeOut, 5, 100, 1, true);
      m_mcMask.gotoAndPlay("entry");
      var mcHolder:MovieClip = m_oWindow.getContainer();
      mcHolder._alpha = 100;
   }

   public function animMask():Void {m_mcMask.play()};
   public function showMenu():Void {m_mcContainer._visible = true;}
   public function hideMenu():Void {m_mcContainer._visible = false;}
   //public function addScrollerHandler(oListener:Object):Void {}

   public function shutDown(pfAftermath:Function):Void
   {
      var fViewEnabled:Boolean = m_cViewDisable.isViewEnabled();
      var fPopupShown:Boolean = m_cDetailsPopup.isPopupShown();
      m_pfShutDownEvent = pfAftermath;
      if(false == fViewEnabled)
      {
         m_cViewDisable.removeListener();
         m_cViewDisable.enableView(true);
	  }
	  if(true == fPopupShown)
      {
         var mcHolder:MovieClip = m_cDetailsPopup.getHolder();
         mcHolder["BackBtn_MC"].removeMovieClip();
         m_cDetailsPopup.hidePopup(true);
	  }
      //var cT:EventTimer = new EventTimer(Fxn.FunctionProxy(this, shutDownComplete), 2000);
      //cT.StartTimer();
      shutDownComplete();
   }

   public function shutDownComplete():Void
   {
      m_pfShutDownEvent.apply(this);
   }

   public function destroy():Void
   {
      m_oWindow.destroy();
      m_cShortDescPopup.destroy();
      m_cDetailsPopup.destroy();
      m_cViewDisable.destroy();
      delete m_pfShutDownEvent;
      delete m_oWindow;
      delete m_pfEvent;
      delete m_oMenuProp;
	  delete m_cShortDescPopup;
      delete m_cDetailsPopup;
      delete m_cViewDisable;
      m_mcContainer.removeMovieClip();
      m_mcContainer = null;
   }
}