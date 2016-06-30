import mx.transitions.*;
import mx.transitions.easing.*;

class SystemController extends MvcController
{
   private var m_mcTopClip:MovieClip;
   private var m_mcBench:MovieClip;
   private var m_mcUpRightLeaves:MovieClip;
   private var m_aTopMenus:Array;
   private var m_aViewStack:Array;
   private var m_fConCurViewTrans:Boolean;
   private var m_aTweens:Array;
   private var m_mcAboutKunzBtn:MovieClip;

   private static var INIT_VIEW:Number = Enum.VIEW_SYSTEM_HOME;
   private static var TOP_MENU_Y:Number = 65;

   public function SystemController(oModel:MvcModel, mcSysContainer:MovieClip)
   {
      super(oModel);
	  trace("SystemController::SystemController(" + oModel + "," + mcSysContainer + ")");
	  var nDepth:Number = 0;
	  var mcMenusHolder:MovieClip;
	  var mcMenusMask:MovieClip;
	  var mcCover:MovieClip;
	  m_fConCurViewTrans = true; //Needs to be true for 1st View Entrance
	  m_aTopMenus = new Array(6);
	  m_aViewStack = new Array();
	  m_mcSysContainer = mcSysContainer;
	  m_mcViewHolder = m_mcSysContainer.createEmptyMovieClip("ViewHolder_MC", nDepth++);
	  mcMenusHolder = m_mcSysContainer.createEmptyMovieClip("MenusHolder_MC", nDepth++);
	  mcMenusMask = m_mcSysContainer.attachMovie("TopMenusMask_MC", "TopMenusMask_MC", nDepth++);
	  mcMenusHolder.setMask(mcMenusMask);
	  m_mcBench = Fxn.AttachGraphic(m_mcSysContainer, "BenchSet_MC", nDepth++, 10, 227);
	  //mcCover = Fxn.AttachGraphic(m_mcSysContainer, "MenuTopCover_MC", nDepth++, 50, 40);
	  //new Tween(mcCover, "_alpha", Strong.easeOut, 0, 100, 0.5, true);
	  //new Tween(mcCover, "_y", Strong.easeOut, 80, 0, 0.5, true);
	  Fxn.AttachGraphic(m_mcSysContainer, "MenuTopCover_MC", nDepth++, 50, 105);
	  m_mcBench = m_mcBench["BenchSet_MC"];
      m_mcUpRightLeaves = Fxn.AttachGraphic(m_mcSysContainer, "UpRightLeveas_MC", nDepth++, 473, 9);
      m_mcAboutKunzBtn = m_mcUpRightLeaves["UpRightLeveas_MC"]["MyLink_MC"];
	  m_mcTopClip = m_mcSysContainer.createEmptyMovieClip("TopClip_MC", nDepth++);
	  m_mcBench._alpha = 0;
	  m_mcBench["WoodBench_MC"]._x = -m_mcBench.WoodBench_MC._width;
	  m_mcBench["BowlingVaseLong_MC"]._x = -m_mcBench["BowlingVaseLong_MC"]._width;
	  m_mcBench["BowlingVasePlump_MC"]._x = -m_mcBench["BowlingVasePlump_MC"]._width;
	  //m_mcBench["Eggs_MC"]._x = -m_mcBench.Eggs_MC._width;
	  //m_mcBench.LowerLeftLeaves_MC
	  CreateTopMenuItems(mcMenusHolder, mcMenusMask);
	  TransitionToView(INIT_VIEW);
	  AnimateWoodBench(INIT_VIEW);
      m_mcAboutKunzBtn.onRollOver = function() {this.gotoAndStop(2);}
      m_mcAboutKunzBtn.onRollOut = function() {this.gotoAndStop(1);}
      m_mcAboutKunzBtn.onDragOut = function() {this.gotoAndStop(1);}
	  m_fConCurViewTrans = true; //Change this to true if Concurrent Transition
   }

   public function AdjustWoodBench(oProps:Object):Void
   {
      var mcBench:MovieClip = m_mcBench["WoodBench_MC"];
      var nV1:MovieClip = m_mcBench["WoodBench_MC"];
	  var mcV1:MovieClip = m_mcBench["BowlingVaseLong_MC"];
	  var mcV2:MovieClip = m_mcBench["BowlingVasePlump_MC"];
	  //nV1X:-25, nV1T: 2, nV2X:-50, nV2T:2
      new Tween(mcBench, "_x", Strong.easeOut, mcBench._x, oProps["nBenchX"], oProps["nBenchT"], true);
      new Tween(mcV1, "_x", Strong.easeOut, mcV1._x, oProps["nV1X"], oProps["nV1T"], true);
	  new Tween(mcV2, "_x", Strong.easeOut, mcV2._x, oProps["nV2X"], oProps["nV2T"], true);
   }

   public function RevertCurViewProps():Void
   {
      var nViewId:Number = m_cCurView.GetViewId();
      AnimateWoodBench(nViewId);
   }

   private function AnimateWoodBench(nViewId:Number):Void
   {
      var cTween:Tween = null;
	  var mcBench:MovieClip = m_mcBench["WoodBench_MC"];
	  //var mcEggs:MovieClip = m_mcBench["Eggs_MC"];
	  var mcV1:MovieClip = m_mcBench["BowlingVaseLong_MC"];
	  var mcV2:MovieClip = m_mcBench["BowlingVasePlump_MC"];
	  var oProps:Object = GetBenchItemsFinalProps(nViewId);
	  DeleteBenchTweens(true);
	  m_aTweens.push(new Tween(mcBench, "_x", Strong.easeOut, mcBench._x, oProps.nBenchX, oProps.nBenchT, true));
	  //cTween = new Tween(mcEggs, "_x", Strong.easeOut, mcEggs._x, oProps.nEggX, oProps.nEggT, true);
	  m_aTweens.push(new Tween(mcV1, "_x", Strong.easeOut, mcV1._x, oProps.nV1X, oProps.nV1T, true));
	  m_aTweens.push(new Tween(mcV2, "_x", Strong.easeOut, mcV2._x, oProps.nV2X, oProps.nV2T, true));
	  m_mcBench._alpha = 100;
   }

   private function DeleteBenchTweens(fReInit:Boolean):Void
   {
      var nTweens:Number = m_aTweens.length;
      for(var i:Number = 0; i < nTweens; i++) m_aTweens[i].stopEnterFrame();
      delete m_aTweens;
	  if(true == fReInit) m_aTweens = new Array();
   }

   private function GetBenchItemsFinalProps(nViewId:Number):Object
   {
      var oProps:Object = null;
	  switch(nViewId)
	  {
	     case Enum.VIEW_SYSTEM_HOME: oProps = {nBenchX:35, nBenchT:2, nEggX:100, nEggT:2, nV1X:5, nV1T: 2, nV2X:50, nV2T:2}; break;
		 case Enum.VIEW_ABOUT_US: oProps = {nBenchX:-150, nBenchT:2, nEggX:100, nEggT:2, nV1X:5, nV1T: 2, nV2X:50, nV2T:2}; break;
		 case Enum.VIEW_LOCATION: oProps = {nBenchX:240, nBenchT:2, nEggX:100, nEggT:2, nV1X:5, nV1T: 2, nV2X:50, nV2T:2}; break;
		 case Enum.VIEW_SKINCARE_TIPS: oProps = {nBenchX:-300, nBenchT:2, nEggX:100, nEggT:2, nV1X:5, nV1T: 2, nV2X:50, nV2T:2}; break;
		 case Enum.VIEW_SZ_LOCATION_GALLERY: oProps = {nBenchX:240, nBenchT:2, nEggX:100, nEggT:2, nV1X:5, nV1T: 2, nV2X:50, nV2T:2}; break;
		 case Enum.VIEW_TESTIMONIALS: oProps = {nBenchX:120, nBenchT:2, nEggX:100, nEggT:2, nV1X:5, nV1T: 2, nV2X:50, nV2T:2}; break;
		 case Enum.VIEW_WHATS_NEW: oProps = {nBenchX:240, nBenchT:2, nEggX:100, nEggT:2, nV1X:5, nV1T: 2, nV2X:50, nV2T:2}; break;
         case Enum.VIEW_ABOUT_KUNZ: oProps = {nBenchX:240, nBenchT:2, nEggX:100, nEggT:2, nV1X:5, nV1T: 2, nV2X:50, nV2T:2}; break;
		 default: break;
	  }
	  return oProps
   }

   public function TransitionToView(nViewId:Number):Void
   {
      trace("SystemController::TransitionToView(" + nViewId + ")");
      if(nViewId == Enum.VIEW_ABOUT_KUNZ) m_mcAboutKunzBtn.enabled = false;
      else m_mcAboutKunzBtn.enabled = true;
      var nCurViewId:Number = m_cCurView.GetViewId();
	  if(nViewId != nCurViewId)
	  {
         var nViews:Number = m_aViewStack.length;
		 m_cCurView = CreateView(nViewId);
		 if(nViews > 0) m_cPrevView = m_aViewStack[nViews - 1];
		 else m_cPrevView = null;
		 if(nViews > 1)
		 {
		    var cView:MvcView = m_aViewStack[0];
			cView.destroy();
			m_aViewStack.splice(0,1);
		 }
		 if(m_cPrevView != null) m_cPrevView.ExitViewAnimStart(Fxn.FunctionProxy(this, ExitViewAnimComplete, [m_cPrevView]));
		 if(true == m_fConCurViewTrans) m_cCurView.EntryViewAnimStart(Fxn.FunctionProxy(this, EntryViewAnimComplete));
		 m_aViewStack.push(m_cCurView);
	  }
	  else
	  {
	     trace("INFO: View is already displayed");
		 //Aditional Behavior for displayed view
	  }
   }

   public function CreateView(nViewId:Number):MvcView
   {
      trace("SystemController::CreateView(" + nViewId + ")");
      var cCurView:MvcView = null;
	  var cProps:ViewProps = new ViewProps(nViewId);
	  
	  switch(nViewId)
	  {
         case Enum.VIEW_SYSTEM_HOME:
            cProps.sViewName = "SystemView_MC";
            cCurView = new SystemView(this, m_mcViewHolder, cProps);
			//var mc:MovieClip = m_cCurView.GetViewClip();
		    break;
         case Enum.VIEW_ABOUT_US:
            cProps.sViewName = "AboutUsView_MC";
            cCurView = new AboutUsView(this, m_mcViewHolder, cProps);
		    break;
         case Enum.VIEW_LOCATION:
            cProps.sViewName = "SzLocationView_MC";
            cCurView = new SzLocationView(this, m_mcViewHolder, cProps);
		    break;
         case Enum.VIEW_SZ_LOCATION_GALLERY:
		    cProps.sViewName = "SzLocGalleryView_MC";
            cCurView = new SzLocationGalleryView(this, m_mcViewHolder, cProps);
            break;
         case Enum.VIEW_SKINCARE_TIPS:
            cProps.sViewName = "SkincareTipsView_MC";
		    cCurView = new SkincareTipsView(this, m_mcViewHolder, cProps);
		    break;
         case Enum.VIEW_TESTIMONIALS:
            cProps.sViewName = "TestimonialsView_MC";
		    cCurView = new TestimonialsView(this, m_mcViewHolder, cProps);
		    break;
         case Enum.VIEW_WHATS_NEW:
            cProps.sViewName = "WhatsNewView_MC";
		    cCurView = new WhatsNewView(this, m_mcViewHolder, cProps);
		    break;
         case Enum.VIEW_ABOUT_KUNZ:
            cProps.sViewName = "AboutKunzView_MC";
		    cCurView = new AboutKunzView(this, m_mcViewHolder, cProps);
            break;
         default:
            trace("INFO: Invalid View Id: " + nViewId);
            break;
	  }
	  super.DrawView(nViewId);
	  return cCurView;
   }

   private function EntryViewAnimComplete(Void):Void
   {
      trace("SystemController::EntryViewAnimComplete");
   }

   private function ExitViewAnimComplete(cPrevView:MvcView):Void
   {
      trace("SystemController::ExitViewAnimComplete");
	  //trace("DESTROY PREV VIEW: " + cPrevView.GetViewClip());
	  if(false == m_fConCurViewTrans) m_cCurView.EntryViewAnimStart(Fxn.FunctionProxy(this, EntryViewAnimComplete));
	  cPrevView.destroy();
	  cPrevView = null;
	  m_aViewStack.splice(0,1);
	  //trace(" ================================= ");
	  //trace(" ARRAY: " + m_aViewStack.length);
   }

   private function CreateTopMenuItems(mcMenusHolder:MovieClip, mcMenusMask:MovieClip):Void
   {
      trace("SystemController::CreateTopMenus");
	  var cButton:TopMenuButton = null;
	  var oHomeMnu:Object = {sLinkage:"MnuHome_MC", pfEvent:OnHomeMenuRelease};
	  var oAboutUsMnu:Object = {sLinkage:"MnuAboutUs_MC", pfEvent:OnAboutUsMenuRelease};
	  var oLocationMnu:Object = {sLinkage:"MnuLocation_MC", pfEvent:OnLocationMenuRelease};
	  var oSkincareTipsMnu:Object = {sLinkage:"MnuSkincareTips_MC", pfEvent:OnSkincareTipsMenuRelease};
	  var oTestimonialsMnu:Object = {sLinkage:"MnuTestimonials_MC", pfEvent:OnTestimonialsMenuRelease};
	  var oWhatsNewMnu:Object = {sLinkage:"MnuWhatsNew_MC", pfEvent:OnWhatsNewMenuRelease};
	  m_aTopMenus = [oHomeMnu,oAboutUsMnu,oLocationMnu,oSkincareTipsMnu,oTestimonialsMnu,oWhatsNewMnu];
	  var nMenus:Number = m_aTopMenus.length;
	  var nX:Number = 50;
	  mcMenusMask._x = nX;
	  mcMenusMask._y = TOP_MENU_Y;
	  for(var nIndex:Number = 0; nIndex < nMenus; nIndex++)
	  {
		 var oMenu:Object = m_aTopMenus[nIndex];
		 var sLinkage:String = oMenu.sLinkage;
         var mcMenu:MovieClip = mcMenusHolder.attachMovie(sLinkage, sLinkage, nIndex);
		 cButton = new TopMenuButton(mcMenu, true);
		 cButton.EnableButton(false);
		 cButton.SetButtonReleaseEvent(Fxn.FunctionProxy(this, oMenu.pfEvent, [nIndex]));
		 oMenu.cButton = cButton;
		 oMenu.mcButton = mcMenu;
		 mcMenu._alpha = 0;
		 mcMenu._x = nX;
		 mcMenu._y = TOP_MENU_Y;
		 nX += mcMenu._width - 2; //2 LineWidth
	  }
	  AnimateTopMenuEntrance();
   }

   private function AnimateTopMenuEntrance(Void):Void
   {
      var mcButton:MovieClip;
	  var nMenus:Number = m_aTopMenus.length;
	  var mcButton:MovieClip = null;
	  var cTimer:EventTimer = null;
	  var nInterval:Number = 50;
	  var nTimeOut:Number = 0; //(nMenus + 1) * nInterval;
	  for(var nIndex:Number = 0; nIndex < nMenus; nIndex++)
	  {
         mcButton = m_aTopMenus[nIndex].mcButton;
         nTimeOut += nInterval;
         cTimer = new EventTimer(Fxn.FunctionProxy(this, AnimateMenuItem, [nIndex, mcButton._x]), nTimeOut);
		 cTimer.StartTimer();
	  }
   }

   private function AnimateMenuItem(nIndex:Number, nX:Number):Void
   {
      var oMenu:Object = m_aTopMenus[nIndex];
      var mcButton:MovieClip = oMenu.mcButton;
	  var cTween:Tween = null;
	  var nTime:Number = 2; //seconds
	  mcButton._alpha = 100;
	  cTween = new Tween(mcButton, "_y", Strong.easeOut, -nX/2, TOP_MENU_Y, nTime, true);
      cTween = new Tween(mcButton, "_x", Strong.easeOut, -mcButton._width, nX, nTime, true);
      cTween.onMotionFinished = Fxn.FunctionProxy(this, MenuItemAnimDone, [nIndex]);
   }

   private function MenuItemAnimDone(nIndex:Number):Void
   {
      var nLastMenuIndex:Number = m_aTopMenus.length - 1;
      if(nIndex == nLastMenuIndex) SetTopButtonSelected(INIT_VIEW); //Set Home Selected
      m_mcAboutKunzBtn.onPress = Fxn.FunctionProxy(this, OnAboutKunzMenuRelease);
   }

   private function OnHomeMenuRelease(nIndex:Number):Void
   {
      trace("SystemController::OnHomeMenuRelease");
	  var nViewId:Number = Enum.VIEW_SYSTEM_HOME;
	  SetTopButtonSelected(nIndex);
	  AnimateWoodBench(nViewId);
      TransitionToView(nViewId);
	  /*
	  trace("========================================");
	  for(var i = 0; i < 500; i++)
	  {
	     m_cCurView.destroy();
         m_cCurView = new SystemView(this, m_mcViewHolder);
		 for(var mc in m_mcViewHolder) trace("m_mcViewHolder: " + mc);
		 for(var mc in m_mcSysContainer) trace("m_mcSysContainer: " + mc);
	  }
	  trace("========================================");
	  */
   }

   private function OnAboutUsMenuRelease(nIndex:Number):Void
   {
      trace("SystemController::OnAboutUsMenuRelease");
	  var nViewId:Number = Enum.VIEW_ABOUT_US;
	  SetTopButtonSelected(nIndex);
	  AnimateWoodBench(nViewId);
      TransitionToView(nViewId);
   }

   private function OnAboutKunzMenuRelease():Void
   {
      trace("SystemController::OnAboutKunzMenuRelease");
	  var nViewId:Number = Enum.VIEW_ABOUT_KUNZ;
	  SetTopButtonSelected(50);
	  AnimateWoodBench(nViewId);
      TransitionToView(nViewId);
      m_mcAboutKunzBtn.gotoAndStop(1);
   }

   private function OnLocationMenuRelease(nIndex:Number):Void
   {
      trace("SystemController::OnLocationMenuRelease");
	  var nViewId:Number = Enum.VIEW_LOCATION;
	  SetTopButtonSelected(nIndex);
	  AnimateWoodBench(nViewId);
      TransitionToView(nViewId);
   }

   private function OnSkincareTipsMenuRelease(nIndex:Number):Void
   {
      trace("SystemController::OnSkincareTipsMenuRelease");
	  var nViewId:Number = Enum.VIEW_SKINCARE_TIPS;
	  SetTopButtonSelected(nIndex);
	  AnimateWoodBench(nViewId);
      TransitionToView(nViewId);
   }

   private function OnTestimonialsMenuRelease(nIndex:Number):Void
   {
      trace("SystemController::OnTestimonialsMenuRelease");
	  var nViewId:Number = Enum.VIEW_TESTIMONIALS;
	  SetTopButtonSelected(nIndex);
	  AnimateWoodBench(nViewId);
      TransitionToView(nViewId);
   }

   private function OnWhatsNewMenuRelease(nIndex:Number):Void
   {
      trace("SystemController::OnWhatsNewMenuRelease");
	  var nViewId:Number = Enum.VIEW_WHATS_NEW;
	  SetTopButtonSelected(nIndex);
	  AnimateWoodBench(nViewId);
      TransitionToView(nViewId);
   }

   private function SetTopButtonSelected(nIndex:Number):Void
   {
      trace("SystemController::SetTopButtonSelected(" + nIndex + ")");
      var nTopMenus:Number = m_aTopMenus.length;
      var oMenu:Object = null;
	  var cButton:TopMenuButton = null;
	  for(var nItem:Number = 0; nItem < nTopMenus; nItem++)
	  {
         oMenu = m_aTopMenus[nItem];
	     cButton = oMenu.cButton;
		 if(nIndex == nItem) cButton.EnableButton(false);
		 else cButton.EnableButton(true);
	  }
   }

   public function clearTopClipContents():Void
   {
      for(var sMc:String in m_mcTopClip)
	  {
         m_mcTopClip[sMc].removeMovieClip();
	  }
   }

   public function createMcInTopClip(sName:String):MovieClip
   {
      var nDepth:Number = m_mcTopClip.getNextHighestDepth();
      var mc:MovieClip = m_mcTopClip.createEmptyMovieClip(sName, nDepth);
      return mc;
   }

   public function destroy(Void):Void
   {
      trace("SystemController::destroy");
	  DeleteBenchTweens(false);
	  for(var oProp in m_aTopMenus)
	  {
         var oMenu:Object = m_aTopMenus[oProp];
		 oMenu.mcButton.removeMovieClip();
		 oMenu.cButton.destroy();
		 delete oMenu.cButton;
		 delete m_aTopMenus[oProp];
	  }
	  delete m_aTopMenus;
      super.destroy();
   }
}