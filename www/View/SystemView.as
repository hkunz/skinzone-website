import mx.transitions.*;
import mx.transitions.easing.*;

class SystemView extends MvcView
{
   private static var MENU_DOCTOR_SERVICES:Number = 0;
   private static var MENU_SPA_SERVICES:Number = 1;
   private static var MENU_SALON_SERVICES:Number = 2;
   private static var MENU_SKINCARE_SERVICES:Number = 3;

   private static var MENU_ROTATION_PIVOT_X:Number = 365;
   private static var MENU_ROTATION_PIVOT_Y:Number = 260;
   private static var MENU_ROTATION_RADIUS_X:Number = 220;
   private static var MENU_ROTATION_RADIUS_Y:Number = 110;
   private static var MENU_ROTATION_ANGLE_START:Number = 235;
   private static var MENU_ROTATION_ANGLE_END:Number = 115;
   private static var MENU_MIN_SCALE:Number = 70;
   private static var MENU_TRANSITION_DURATION:Number = 2000;

   private var m_cMenuDisplay:MenuDisplay;
   private var m_cLoadAnimation:LoadAnimation;
   private var m_cViewDisabler:ViewDisable;
   private var m_mcSelection:MovieClip;
   private var m_mcParentBubbleHolder:MovieClip;
   private var m_mcBubbleMenus:MovieClip;
   private var m_aMenus:Array; //4 Bubble Menus
   private var m_nLoadedMenus:Number; //Counter for loaded JPGs in Bubble Menus
   private var m_nIndex:Number; //MovieClip Depth Index
   private var m_aTweens:Array; //Entry and Exit Animation Tweens
   private var m_fLoadComplete:Boolean;
   private var m_aBubbleFadeTweens:Array;
   private var m_cPromoPopup:PromoPopup;

   public function SystemView(oController:MvcController, mcViewHolder:MovieClip, cProps:ViewProps)
   {
      super(oController, mcViewHolder, cProps);
      //trace("SystemView::SystemView(" + oController + "," +  mcViewHolder + ")");
	  CreateViewContainer(cProps.sViewName);
	  m_nIndex = 0;
	  m_nLoadedMenus = 0;
	  m_fLoadComplete = false;
	  m_aTweens = new Array();
   }

   public function EntryViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("SystemView::EntryViewAnimStart");
      super.EntryViewAnimStart(pfDoneEvent);
	  m_aMenus = new Array();
	  var nTime:Number = 500;
	  var mcMainBgMask:MovieClip = Fxn.AttachGraphic(m_mcView, "MainMenuAreaMask_MC", m_nIndex++, 50, 105);
	  var mcMainBg:MovieClip = Fxn.AttachGraphic(m_mcView, "MainMenuArea_MC", m_nIndex++, 50, 105);
	  var cEventTimer:EventTimer = null;
	  mcMainBg._alpha = 0;
	  mcMainBg.setMask(mcMainBgMask);
	  //CreateBubbleMenus();
	  cEventTimer = new EventTimer(Fxn.FunctionProxy(this, CreateBubbleMenus), nTime);
	  cEventTimer.StartTimer();
	  //Loading Animation
	  var mcLoadAnimation:MovieClip = m_mcView.createEmptyMovieClip("LoadAnimation_MC", m_nIndex++);
	  m_cLoadAnimation = new LoadAnimation(mcLoadAnimation);
	  m_cLoadAnimation.centerLoadClip();
	  m_cLoadAnimation.StartAnimation();
   }

   public function ExitViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("SystemView::ExitViewAnimStart");
      super.ExitViewAnimStart(pfDoneEvent);
	  if(true == m_fLoadComplete)
	  {
         if(DataStore.isPromoShowing() == true)
		 {
            m_cViewDisabler.removeListener();
            m_cViewDisabler.enableView(true);
            m_cPromoPopup.exitPopup();
		 }
         m_cPromoPopup.stopLoadingClip();
         m_cMenuDisplay.shutDown(Fxn.FunctionProxy(this, MenuDisplayShutDownAftermath));
	  }
	  else BubbleMenuItemAnimComplete();
   }

   private function MenuDisplayShutDownAftermath():Void
   {
      var cTween:Tween = null;
	  var nTime:Number = 1.5;
	  var mcMainBg:MovieClip = m_mcView["MainMenuArea_MC"];
	  var mcBubbleMask:MovieClip = m_mcView["MainMenuOptBg_MC"];
	  var nX:Number = -mcMainBg._width;
      m_aTweens.push(new Tween(mcMainBg, "_x", Strong.easeOut, mcMainBg._x, nX, nTime, true));
      m_aTweens.push(cTween = new Tween(mcBubbleMask, "_x", Strong.easeOut, mcMainBg._x, nX, nTime, true));
      //cTween = new Tween(mcMainBg, "_alpha", Strong.easeOut, 100, 0, 2, true);
	  //m_aTweens.push(new Tween(mcBubbleHolder, "_x", Strong.easeOut, mcMainBg._x, nX, nTime, true));
      //m_aTweens.push(new Tween(mcMainBgMask, "_x", Strong.easeOut, mcMainBg._x, nX, nTime, true));
      cTween.onMotionFinished = Fxn.FunctionProxy(this, RemoveBubbleMenu);
      AnimateBubbleMenuExit();
      m_cMenuDisplay.exitAnim();
   }

   private function RemoveBubbleMenu(Void):Void
   {
      trace("SystemView::RemoveBubbleMenu");
	  m_mcView["MainMenuArea_MC"].removeMovieClip();
	  m_mcView["MainMenuOptBg_MC"].removeMovieClip();
	  m_mcView["BubbleMenusHolder_MC"].removeMovieClip();
	  m_mcView["MainMenuAreaMask_MC"].removeMovieClip();
   }

   private function SetDefaultSelection(mcPrevSelected:MovieClip):Void
   {
      //trace("SystemView::SetDefaultSelection");
	  var nMenus:Number = m_aMenus.length;
	  /*
	  var mcImg:MovieClip = mcPrevSelected["BubbleMenu_MC"];
	  //for(var mc in mcPrevSelected) trace("MC: " + mc);
	  trace("RELEASE: " + mcPrevSelected);
	  trace("RELEASE: " + mcPrevSelected["BubbleMenu_MC"]);
	  if(mcPrevSelected != undefined)
	  {
         new Tween(mcImg, "_xscale", Strong.easeOut, mcImg._xscale, 100, 0.5, true);
		 new Tween(mcImg, "_yscale", Strong.easeOut, mcImg._yscale, 100, 0.5, true);
	  }
	  */
	  DeleteBubbleFadeTween(true);
	  for(var i:Number = 0; i < nMenus; i++)
	  {
         var oMenu:BubbleMenu = m_aMenus[i];
		 var mcBubble:MovieClip = oMenu.mcBubble.Img_MC;
         var nAlpha:Number = oMenu.mcClip._alpha;
         m_aBubbleFadeTweens.push(new Tween(oMenu.mcClip, "_alpha", null, nAlpha, 100, 0.5, true));
		 if(oMenu.nPosition == 0) SetHoverSelectionTo(oMenu.mcClip);
      }
   }

   public function setViewEnabled(fEnabled:Boolean):Void
   {
      var nMenus:Number = m_aMenus.length;
      for(var i:Number = 0; i < nMenus; i++)
      {
         var oMenu:BubbleMenu = m_aMenus[i];
         var cButton:BubbleMenuButton = oMenu.cButton;
		 cButton.EnableButton(fEnabled);
         if(oMenu["nPosition"] == 0 && fEnabled == true) cButton.EnableButton(false);
	  }
      m_mcSelection._visible = fEnabled;
      if(fEnabled) m_mcSelection["BubbleOverAnim_MC"]["BubbleOverAnim_MC"]["Highlight_MC"].play();
      m_cMenuDisplay.setMenuDisplayEnabled(fEnabled);
	  
      super.setViewEnabled(fEnabled);
   }

   private function SetHoverSelectionTo(mcBubbleMenu:MovieClip):Void
   {
      //trace("SystemView::SetHoverSelectionTo(" + mcBubbleMenu + ")");
	  if(Enum.VIEW_STATE_EXIT_ANIMATION_START == super.GetViewState()) return;
	  m_mcSelection._alpha = 0;
	  var SelCircle:MovieClip = Fxn.AttachGraphic(m_mcSelection, "BubbleOverAnim_MC", 0, 0, 0);
	  //SelCircle.onEnterFrame = function() {SelCircle._rotation -= 5;}
	  var nScale:Number = mcBubbleMenu._xscale;
      m_mcSelection._xscale = nScale;
	  m_mcSelection._yscale = nScale;
	  m_mcSelection._x = mcBubbleMenu._x;
	  m_mcSelection._y = mcBubbleMenu._y;
	  m_mcSelection._alpha = 100;
   }

   private function FadeBubbleItemsExcept(mcBubbleMenu:MovieClip):Void
   {
	  var nMenus:Number = m_aMenus.length;
	  /*
	  var mcImg:MovieClip = mcBubbleMenu["BubbleMenu_MC"];
	  trace("OVER: " + mcBubbleMenu);
	  trace("OVER: " + mcBubbleMenu["BubbleMenu_MC"]);
      //var nTweens:Number = m_aBubbleFadeTweens.length;
      //for(var n:Number = 0; n < nTweens; n++) m_aBubbleFadeTweens[n].stopEnterFrame();
      //delete m_aBubbleFadeTweens; m_aBubbleFadeTweens = new Array();
	  new Tween(mcImg, "_xscale", Strong.easeOut, mcImg._xscale, 110, 0.5, true);
	  new Tween(mcImg, "_yscale", Strong.easeOut, mcImg._yscale, 110, 0.5, true);
	  */
      for(var i:Number = 0; i < nMenus; i++)
	  {
         var oMenu:BubbleMenu = m_aMenus[i];
		 if(oMenu.mcClip != mcBubbleMenu)
		 {
            var nAlpha:Number = m_aMenus[i].mcClip._alpha;
			m_aBubbleFadeTweens.push(new Tween(m_aMenus[i].mcClip, "_alpha", null, nAlpha, 10, 0.5, true));
		 }
		 else SetHoverSelectionTo(mcBubbleMenu);
      }
   }

   private function AnimateBubbleMenuExit(Void):Void
   {
      //trace("SystemView::AnimateBubbleMenuExit");
      var nMenus:Number = m_aMenus.length;
	  var oMenu:BubbleMenu = null;
      var nAngle:Number = MENU_ROTATION_ANGLE_START - 40;
	  var mcBubbleMenu:MovieClip;
	  for(var nItem:Number = 0; nItem < nMenus; nItem++)
	  {
         oMenu = m_aMenus[nItem];
		 mcBubbleMenu = oMenu.mcClip;
		 //var nStartAngle:Number = oMenu.nAngle;
		 var nDeltaX:Number = mcBubbleMenu._x - MENU_ROTATION_PIVOT_X;
		 var nDeltaY:Number = mcBubbleMenu._y - MENU_ROTATION_PIVOT_Y;
		 var nInitAngle:Number = Fxn.ArcTan(nDeltaY / nDeltaX);
		 if(nDeltaX < 0) nInitAngle += 180;
		 //trace("MENU: " + mcBubbleMenu._x + ": " + mcBubbleMenu._y + " {} " + nInitAngle + " => " + oMenu.nAngle);
         AnimateBubbleMenu(oMenu, nInitAngle, nInitAngle - nAngle);
	  }
   }

   private function AnimateBubbleMenuEntrance(Void):Void
   {
      //trace("SystemView::AnimateBubbleMenuEntrance");
      var cTween:Tween = null;
	  var nMenus:Number = m_aMenus.length;
	  var mcMainBg:MovieClip = m_mcView["MainMenuArea_MC"];
	  var mcBubbleMask:MovieClip = m_mcView["MainMenuOptBg_MC"];
	  m_cLoadAnimation.StopAnimation();
	  m_aTweens.push(new Tween(mcMainBg, "_alpha", Strong.easeOut, 0, 100, 2.1, true));
	  m_aTweens.push(new Tween(mcBubbleMask, "_x", Strong.easeOut, -mcMainBg._width, 0, 2.1, true));
	  m_aTweens.push(new Tween(mcMainBg, "_x", Strong.easeOut, -mcMainBg._width, 0, 2.1, true));
	  //cTween.onMotionFinished = Fxn.FunctionProxy(this, FixBug);
	  
	  for(var i:Number = 0; i < nMenus; i++)
	  {
         var oMenu:BubbleMenu = m_aMenus[i];
         var mcBubbleMenu:MovieClip = oMenu.mcClip;
		 mcBubbleMenu._xscale = MENU_MIN_SCALE;
		 mcBubbleMenu._yscale = MENU_MIN_SCALE;
		 var nAnglePos:Number = oMenu.nAngle;
		 AnimateBubbleMenu(oMenu, MENU_ROTATION_ANGLE_START + 50, nAnglePos);
	  }
	  //var mcCover:MovieClip = Fxn.AttachGraphic(m_mcParentBubbleHolder, "BubbleMenuTopCover_MC", m_nIndex++, 50, 105);
	  //mcCover._alpha = 0;
	  //m_aTweens.push(new Tween(mcCover, "_alpha", Strong.easeOut, 0, 100, 1.5, true));
   }

   private function ActivateBubbleButton(oMenu:BubbleMenu):Void
   {
      //trace("SystemView::ActivateBubbleButton");
      var mcBubbleMenu:MovieClip = oMenu.mcClip;
	  var cButton:BubbleMenuButton = oMenu.cButton;
	  var nPosition:Number = oMenu.nNxPosition;
	  oMenu.nPosition = nPosition;
      cButton.SetButtonReleaseEvent(Fxn.FunctionProxy(this, AnimateToMenu, [oMenu.nId]));
      if(DataStore.wasPromoShown() == true)
      {
         cButton.EnableButton(true);
		 if(nPosition == 0) {cButton.EnableButton(false); cButton.SetSelected(true); SetHoverSelectionTo(mcBubbleMenu);}
	     else cButton.SetSelected(false);
	  }
	  if(++m_nLoadedMenus == m_aMenus.length) BubbleMenuItemAnimComplete();
   }

   private function BubbleMenuItemAnimComplete(Void):Void
   {
      //trace("SystemView::BubbleMenuItemAnimComplete");
      var nViewState:Number = GetViewState();
      switch(nViewState)
      {
      case Enum.VIEW_STATE_ENTRY_ANIMATION_START:
         //m_cMenuDisplay.goToMenu(Enum.MENU_SKINCARE_SERVICES, true);
         //m_cMenuDisplay.startAnim();
         //m_cMenuDisplay.showMenu();
         super.EntryViewAnimComplete();
         break;
      case Enum.VIEW_STATE_EXIT_ANIMATION_START:
         super.ExitViewAnimComplete();
         break;
      case Enum.VIEW_STATE_ENTRY_ANIMATION_COMPLETE:
         //m_cMenuDisplay.enableMenu(true);
         break;
      default: trace("ERROR: Unhandled State: " + nViewState);
	  }
	  m_nLoadedMenus = 0;
   }

   private function AnimateBubbleMenu(oMenu:BubbleMenu, nInitAngle:Number, nFinalAngle:Number):Void
   {
      //trace("SystemView::AnimateBubbleMenu(" + oMenu + "," + nInitAngle + "," + nFinalAngle + ")");
      var cTween:ArcTween = null;
	  var nRev:Number = Constant.FULL_REVOLUTION;
	  var mcBubbleMenu:MovieClip = oMenu.mcClip;
	  var nAngleRange:Number = MENU_ROTATION_ANGLE_END - MENU_ROTATION_ANGLE_START;
	  var nSlope:Number = (100 - MENU_MIN_SCALE) / nAngleRange;
	  var nIntercept:Number = MENU_MIN_SCALE - (MENU_ROTATION_ANGLE_START  * nSlope);
	  var nFinalScale:Number = (nSlope * ((nFinalAngle + nRev)%nRev)) + nIntercept;
	  oMenu.cArcTween.destroy();
	  delete oMenu.cArcTween;
	  cTween = new ArcTween(mcBubbleMenu);
	  oMenu.cArcTween = cTween;
	  oMenu.cButton.SetSelected(false);
	  cTween.SetRotationPivot(MENU_ROTATION_PIVOT_X, MENU_ROTATION_PIVOT_Y);
	  cTween.SetAngleRoute(nInitAngle, nFinalAngle);
	  cTween.SetScale(mcBubbleMenu._xscale/*MENU_MIN_SCALE*/, nFinalScale);
	  cTween.SetRadius(MENU_ROTATION_RADIUS_X, MENU_ROTATION_RADIUS_Y);
	  cTween.SetDuration(MENU_TRANSITION_DURATION);
	  cTween.SetCompleteEvent(Fxn.FunctionProxy(this, ActivateBubbleButton, [oMenu]));
	  cTween.StartAnimation();
	  cTween.SetOnAnimationEvent(Fxn.FunctionProxy(this, OnArcAnimEnterFrame), [oMenu, nFinalScale]);
	  oMenu.cButton.EnableButton(false);
	  m_mcSelection["BubbleOverAnim_MC"].removeMovieClip();
   }

   private function OnArcAnimEnterFrame(aParameters:Array):Void
   {
      //trace("SystemView::OnArcAnimEnterFrame");
      var nPercComplete:Number = aParameters[0]; //Params from ArcTween
	  var aThisParams:Array = aParameters[1]; //Params passed from This class
	  var oMenu:BubbleMenu = aThisParams[0];
	  var mcText:MovieClip = oMenu.mcText;
      var nMin:Number = 70; var nMinPos:Number = 3;
	  var nMax:Number = -45; var nMaxPos:Number = 0; //Active Position
	  var nAngleRange:Number = nMin - nMax; //∆y (115)
	  var nPosition:Number = nMinPos - nMaxPos; //∆x (3)
	  var nSlope:Number = nAngleRange / nPosition; //∆y/∆x (38.3)
	  var nIntercept:Number = nMin - (nMinPos  * nSlope); //(-45)
	  var nCurAngle:Number = (nSlope * oMenu.nPosition) + nIntercept;
	  var nNxAngle:Number = (nSlope * oMenu.nNxPosition) + nIntercept;
	  mcText._rotation = nCurAngle - ((nCurAngle - nNxAngle)*nPercComplete);
   }

   private function CreateBubbleMenus(Void):Void
   {
      //trace("SystemView::CreateBubbleMenus");
	  var mcMenusMask:MovieClip = Fxn.AttachGraphic(m_mcView, "MainMenuOptBg_MC", m_nIndex++, 50, 105);
	  m_mcParentBubbleHolder = m_mcView.createEmptyMovieClip("BubbleMenusHolder_MC", m_nIndex++);
	  m_mcBubbleMenus = m_mcParentBubbleHolder.createEmptyMovieClip("BubbleMenus_MC", 0);
	  m_mcSelection = m_mcParentBubbleHolder.createEmptyMovieClip("Selection_MC", 1);
	  m_mcBubbleMenus.setMask(mcMenusMask);
	  m_aTweens.push(new Tween(mcMenusMask, "_x", Strong.easeOut, -mcMenusMask._width, 0, 0.5, true));
	  var oSkinCareMenu:BubbleMenu = new BubbleMenu(MENU_SKINCARE_SERVICES, "", 0); oSkinCareMenu.sName = "Skincare";
	  var oSalonMenu:BubbleMenu = new BubbleMenu(MENU_SALON_SERVICES, "", 1); oSalonMenu.sName = "Salon";
      var oSpaMenu:BubbleMenu = new BubbleMenu(MENU_SPA_SERVICES, "", 2); oSpaMenu.sName = "Spa";
      var oDoctorMenu:BubbleMenu = new BubbleMenu(MENU_DOCTOR_SERVICES, "", 3); oDoctorMenu.sName = "Doctor";
	  m_aMenus = [oDoctorMenu, oSpaMenu, oSalonMenu, oSkinCareMenu];
	  var nAngle:Number = MENU_ROTATION_ANGLE_START;
	  var nMenus:Number = m_aMenus.length;
	  var nAngleRange:Number = MENU_ROTATION_ANGLE_END - MENU_ROTATION_ANGLE_START;
	  var nAngleInc:Number = nAngleRange / (nMenus - 1);
	  var oMenu:BubbleMenu = null;
	  for(var i:Number = 0; i < nMenus; i++)
	  {
         var cButton:BubbleMenuButton = null;
		 oMenu = m_aMenus[i];
		 oMenu.nAngle = nAngle;
	     oMenu.mcClip= CreateMenu(oMenu);
		 cButton = new BubbleMenuButton(oMenu.mcBubble, false);
		 cButton.SetFocusEvent(Fxn.FunctionProxy(this, FadeBubbleItemsExcept));
		 cButton.SetUnfocusEvent(Fxn.FunctionProxy(this, SetDefaultSelection));
	     oMenu.cArcTween = null;
		 oMenu.cButton = cButton;
		 nAngle += nAngleInc;
	  }
   }

   private function CreateMenu(oMenu:BubbleMenu):MovieClip
   {
      //trace("SystemView::CreateMenu");
      var sFile:String = oMenu.sName;
      var sLinkage:String = "BubbleMenu_MC";
      var sBubblePrefix:String = "CurveText";
	  var sMcText:String = "_MC";
	  var sTextLinkage:String = sBubblePrefix + sFile + sMcText;
	  var mcMenu:MovieClip = m_mcBubbleMenus.createEmptyMovieClip(sFile + sMcText, m_nIndex++);
	  var mcBubble:MovieClip = mcMenu.attachMovie(sLinkage, sLinkage, 0);
	  var mcBubbleText:MovieClip = mcBubble.attachMovie(sTextLinkage, sTextLinkage, 0, {_x:0,_y:0});
	  var mcImg:MovieClip = mcBubble["Img_MC"];
	  var cLoader:ContentLoader = new ContentLoader(mcImg);
	  mcImg._alpha = 0;
	  mcBubbleText._rotation = 0;
	  oMenu.mcBubble = mcBubble;
	  oMenu.mcText = mcBubbleText;
	  cLoader.SetLoadEvent(Fxn.FunctionProxy(this, OnLoadMenuGraphic, [mcImg]));
	  cLoader.LoadFile("Library/Graphics/MainMenu/" + sFile + ".jpg");
	  //After All Menu Graphic JPGs are loaded AnimateBubbleMenuEntrance will be called in OnLoadMenuGraphic
	  return mcMenu;
   }

   private function AnimateToMenu(nMenuId:Number):Void
   {
      //trace("SystemView::AnimateToMenu");
      var nMenus:Number = m_aMenus.length;
	  var nAngleRange:Number = MENU_ROTATION_ANGLE_END - MENU_ROTATION_ANGLE_START;
      var nCounter:Number = nMenuId;
	  var oMenu:BubbleMenu = m_aMenus[nMenuId];
	  var nInitPosition:Number = oMenu.nPosition;
	  var nPosition:Number = nInitPosition;
	  var nAngleInc:Number = nAngleRange / (nMenus - 1);
	  var nAngleLeap:Number = (nAngleInc * nPosition);
	  var nRevolution:Number = 0;
	  var nAnglePos:Number = 0;
	  var mcClip:MovieClip = oMenu.mcClip;
	  m_cMenuDisplay.goToMenu(nMenuId);
	  //new Tween(mcClip, "_xscale", Strong.easeIn, mcClip._xscale - 10, 100, MENU_TRANSITION_DURATION, true); 
	  //new Tween(mcClip, "_yscale", Strong.easeIn, mcClip._yscale - 10, 100, MENU_TRANSITION_DURATION, true); 
	  
	  for(var i:Number = 0; i < nMenus; i++)
	  {
         nRevolution = 0;
		 oMenu.cButton.EnableButton(false);
		 oMenu = m_aMenus[nCounter++];
		 nAnglePos = oMenu.nAngle + nAngleLeap;
		 nPosition = oMenu.nPosition;
		 if(nCounter >= nMenus) nCounter = 0;
		 if(nPosition < nInitPosition)
		 {
            nAnglePos = MENU_ROTATION_ANGLE_START + nAngleLeap - (nPosition + 1)*nAngleInc;
			nRevolution = Constant.FULL_REVOLUTION;
		 }
		 AnimateBubbleMenu(oMenu, oMenu.nAngle, nAnglePos - nRevolution);
		 oMenu.nAngle = nAnglePos;
		 nPosition -= nInitPosition;
		 if(nPosition < 0) nPosition += nMenus;
		 oMenu.nNxPosition = nPosition;
	  }
	  UpdateBubbleMenuDepths(nInitPosition, nMenuId);
   }

   private function UpdateBubbleMenuDepths(nMenuSteps:Number, nMenuId:Number):Void
   {
      //trace("SystemView::UpdateBubbleMenuDepths");
      var nMenus:Number = m_aMenus.length;
	  var nCounter:Number = 0;
      for(var n:Number = 0; n < nMenuSteps; n++)
	  {
	     nCounter = nMenuId;
	     for(var i:Number = 0; i < (nMenus-1); i++)
         {
            nCounter++;
            var mcSwap1:MovieClip = m_aMenus[(nCounter + n)%nMenus].mcClip;
            var mcSwap2:MovieClip = m_aMenus[(nCounter + 1 + n)%nMenus].mcClip;
		    mcSwap1.swapDepths(mcSwap2);
		    if(nCounter >= nMenus) nCounter = 0;
	     }
	  }
   }

   private function OnLoadMenuGraphic(mcImg:MovieClip):Void
   {
      //trace("SystemView::OnLoadMenuGraphic");
      var cEventTimer:EventTimer = null;
	  Fxn.CenterClipToParent(mcImg);
	  m_nLoadedMenus++;
	  if(m_nLoadedMenus == m_aMenus.length)
	  {
		 var mcContent:MovieClip = m_mcView.createEmptyMovieClip("ScrollContent_MC", m_nIndex++);
         var mcDisableView:MovieClip = m_mcView.createEmptyMovieClip("DisableClip_MC", m_nIndex++);
         var mcSysViewDisabler:MovieClip = m_mcView.createEmptyMovieClip("SysViewDisabler_MC", m_nIndex++);
		 var mcShortDesc:MovieClip = m_mcView.createEmptyMovieClip("SubMenuHolder_MC", m_nIndex++);
         var mcDetails:MovieClip =  m_mcView.createEmptyMovieClip("CompleteDetailsHolder_MC", m_nIndex++);
		 //var oListener:Object = new Object();
         //oListener["onKnobPress"] = Fxn.FunctionProxy(this, onMenuStartScroll);
         //oListener["onKnobRelease"] = Fxn.FunctionProxy(this, onMenuStopScroll);
         //oListener["onVeScroll"] = null;
         m_cMenuDisplay = new MenuDisplay(mcContent, this, Fxn.FunctionProxy(this, onWallMenuLoad));
         m_cMenuDisplay.hideMenu();
         m_cMenuDisplay.initDisableViewClip(mcDisableView);
         m_cMenuDisplay.initShortDescPopup(mcShortDesc);
		 m_cMenuDisplay.initCompleteDetailsPopup(mcDetails);
         m_cViewDisabler = new ViewDisable(mcSysViewDisabler, this);
         //m_cMenuDisplay.addScrollerHandler(oListener);
         //cEventTimer = new EventTimer(Fxn.FunctionProxy(this, CreateScrollContent), nTime);
         //cEventTimer.StartTimer();
		 m_nLoadedMenus = 0;
	  }
   }

   //private function onMenuStartScroll():Void {}
   //private function onMenuStopScroll():Void {}

   private function onWallMenuLoad(mcContent:MovieClip):Void
   {
      //trace("SystemView::onWallMenuLoad");
	  m_fLoadComplete = true;
	  AnimateBubbleMenuEntrance();
      m_cMenuDisplay.goToMenu(Enum.MENU_SKINCARE_SERVICES, true);
      m_cMenuDisplay.startAnim();
      m_cMenuDisplay.showMenu();
   }

   public function menuInitComplete():Void
   {
      var fPromoShowing:Boolean = DataStore.isPromoShowing();
	  var fPromoShown:Boolean = DataStore.wasPromoShown();
      if(fPromoShowing == false || fPromoShown == false) InitViewForPromoPopup();
   }

   private function InitViewForPromoPopup():Void
   {
      DataStore.setPromoIsShowing(true);
      //m_cViewDisabler.addListener(Fxn.FunctionProxy(this, CreatePromoPopup));
	  if(GetViewState() != Enum.VIEW_STATE_EXIT_ANIMATION_START)
      {
         CreatePromoPopup();
	     m_cViewDisabler.disableView();
	  }
   }

   private function CreatePromoPopup():Void
   {
      var mcPromoHolder:MovieClip = m_mcView.createEmptyMovieClip("PromoHolder_MC", m_nIndex++);
      m_cPromoPopup = new PromoPopup(mcPromoHolder, Fxn.FunctionProxy(this, onPromoPicLoad));
      m_cPromoPopup.setLoadPath("Library/Graphics/Promos/Promo.jpg");
	  m_cPromoPopup.addExBtnPressHandler(Fxn.FunctionProxy(this, onPopupExPress));
	  m_cPromoPopup.createPopup();
      m_cPromoPopup.setPosition(115, 125);
      //onPromoPicLoad(false); //TEST
   }

   public function onPromoPicLoad(fSuccess:Boolean):Void
   {
      //fSuccess = false means that there is no Promo.jpg graphic in graphic library
      DataStore.setPromoShown(true); //true even if fSuccess = false
      if(fSuccess == true) adjustWoodBench(1);
      else
      {
         m_cViewDisabler.removeListener();
         m_cPromoPopup.removePopup();
         m_cViewDisabler.enableView(true);
         delete m_cPromoPopup;
	  }
   }

   public function onPopupExPress():Void
   {
      m_cViewDisabler.enableView();
      revertCurViewProps();
   }

   private function DeleteBubbleFadeTween(fReInit:Boolean):Void
   {
      var nTweens:Number = m_aBubbleFadeTweens.length;
      for(var i:Number = 0; i < nTweens; i++) m_aBubbleFadeTweens[i].stopEnterFrame();
      delete m_aBubbleFadeTweens;
	  if(true == fReInit) m_aBubbleFadeTweens = new Array();
   }

   public function adjustWoodBench(nId:Number):Void
   {
      var oProps:Object = null;
      switch(nId)
      {
         case 0: oProps = {nBenchX:125, nBenchT:1, nV1X:-20, nV1T: 2, nV2X:-10, nV2T:1}; break;
         case 1: oProps = {nBenchX:240, nBenchT:1.5}; break;
         default: break;
	  }
      var oSysController:SystemController = SystemController(super.getController());
      oSysController.AdjustWoodBench(oProps);
   }

   public function revertCurViewProps():Void
   {
      var oSysController:SystemController = SystemController(super.getController());
      oSysController.RevertCurViewProps();
   }

   public function destroy(Void):Void
   {
      //trace("SystemView::destroy");
	  var nTweens:Number = 0;
	  var nMenus:Number = m_aMenus.length;
	  //Destroy Bubble Menu Items
	  for(var nItem:Number = 0; nItem < nMenus; nItem++)
	  {
         m_aMenus[nItem].destroy();
		 delete m_aMenus[nItem];
	  }
	  //Destroy Tween Items
	  nTweens = m_aTweens.length;
	  for(var i:Number = 0; i < nTweens; i++)
	  {
         m_aTweens[i].stopEnterFrame();
         delete m_aTweens[i];
	  }
	  DeleteBubbleFadeTween(false);
	  m_cLoadAnimation.destroy();
	  m_cMenuDisplay.destroy();
	  m_cViewDisabler.destroy();
	  m_cPromoPopup.destroy();
	  delete m_cPromoPopup;
	  delete m_cViewDisabler;
	  delete m_aTweens;
	  delete m_cLoadAnimation;
	  delete m_aMenus;
	  m_mcBubbleMenus.removeMovieClip();
      super.destroy();
   }
}