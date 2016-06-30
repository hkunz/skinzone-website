import mx.transitions.*;
import mx.transitions.easing.*;

class PhotoFilmStrip
{
   private var m_cArcTweenSet:ArcTweenSet;
   private var m_mcMask:MovieClip;
   private var m_mcHolder:MovieClip;
   private var m_mcItemsHolder:MovieClip;
   private var m_nRows:Number;
   private var m_nItems:Number;
   private var m_nWidth:Number;
   private var m_nHeight:Number;
   private var m_aImages:Array;
   private var m_sFolderPath:String;
   private var m_pfPhotoClicked:Function;
   private var m_pfShutdown:Function;

   private var VISIBLE_PHOTOS:Number = 12;

   public function PhotoFilmStrip(mcHolder:MovieClip, nItems:Number)
   {
      m_mcHolder = mcHolder;
      m_nItems = nItems;
	  initFileStrip();
   }

   private function initFileStrip():Void
   {
      m_mcItemsHolder = m_mcHolder.createEmptyMovieClip("ItemsHolder_MC", 0);
      m_mcMask = m_mcHolder.attachMovie("PhotoFilmStripMask_MC", "Mask_MC", 1, {_x:50, _y:105});
	  m_mcItemsHolder.setMask(m_mcMask);
	  var nAdj:Number = 95;
	  var mcNxBtn:MovieClip = m_mcHolder.attachMovie("NextPhotoBtn_MC", "NextPhotoBtn_MC", 2, {_x:105 + nAdj, _y:110});
      var mcPrBtn:MovieClip = m_mcHolder.attachMovie("PrevPhotoBtn_MC", "PrevPhotoBtn_MC", 3, {_x:55 + nAdj, _y:110});
      var mcViewBtn:MovieClip = m_mcHolder.attachMovie("ViewPhotoBtn_MC", "ViewPhotoBtn_MC", 4, {_x:155 + nAdj, _y:110});
	  var mcBackBtn:MovieClip = m_mcHolder.attachMovie("ViewPhotoBackBtn_MC", "ViewPhotoBackBtn_MC", 5, {_x:710, _y:400});
	  m_cArcTweenSet = new ArcTweenSet(m_mcItemsHolder);
	  mcNxBtn["Btn_MC"].onPress = Fxn.FunctionProxy(this, nextPhoto, [true]);
	  mcPrBtn["Btn_MC"].onPress = Fxn.FunctionProxy(this, prevPhoto, [true]);
      mcViewBtn["Btn_MC"].onPress = Fxn.FunctionProxy(this, onActivePhotoClicked);
      mcBackBtn["Btn_MC"].onPress = Fxn.FunctionProxy(this, onViewShutDown);
      mcNxBtn["Btn_MC"].enabled = true;
	  mcPrBtn["Btn_MC"].enabled = false;
   }

   private function onViewShutDown():Void
   {
      m_pfShutdown.apply(this);
   }

   public function createFlimStrip(nX:Number, nY:Number, nWidth:Number, nHeight:Number):Void
   {
      m_nWidth = nWidth;
      m_nHeight = nHeight;
      m_cArcTweenSet.setPivot(nX, nY);
      m_cArcTweenSet.setRadius(nWidth/2, nHeight/2);
      m_cArcTweenSet.setItemGraphic("BrowseItem_MC");
      m_cArcTweenSet.setItemMask("BrowseItemMask_MC");
      //m_cArcTweenSet.setLoadPath(
      //m_cArcTweenSet.setAngleDisappearLimits(
      m_cArcTweenSet.setArcAngleLimits(20, 120); //90 Start at button 180 End at left
	  m_cArcTweenSet.setAngleRemovalTolerance(30); //90 Start at button 180 End at left
	  m_cArcTweenSet.setTransitionTime(2000);
      var nVisibleItems:Number = VISIBLE_PHOTOS;
	  if(m_nItems < nVisibleItems) nVisibleItems = m_nItems;
	  m_cArcTweenSet.setVisibleItems(nVisibleItems);
      m_cArcTweenSet.setTotalItems(m_nItems);
      m_cArcTweenSet.setScaleRange(30, 90);
      m_cArcTweenSet.setAlphaRange(100, 100);
	  //m_cArcTweenSet.setRotationRange(0, 20);
	  m_cArcTweenSet.createItems();
      m_cArcTweenSet.setTransitionControlButtons(m_mcHolder["NextPhotoBtn_MC"]["Btn_MC"], m_mcHolder["PrevPhotoBtn_MC"]["Btn_MC"]);
      m_cArcTweenSet.addActiveItemListener(Fxn.FunctionProxy(this, onActivePhotoClicked));
   }

   public function setEnabled(fEnabled:Boolean):Void
   {
      if(fEnabled) m_cArcTweenSet.enableItemPress();
	  else m_cArcTweenSet.disableItemPress();
      m_mcHolder["NextPhotoBtn_MC"]["Btn_MC"].enabled = fEnabled;
      m_mcHolder["PrevPhotoBtn_MC"]["Btn_MC"].enabled = fEnabled;
      m_mcHolder["ViewPhotoBtn_MC"]["Btn_MC"].enabled = fEnabled;
	  m_mcHolder["ViewPhotoBackBtn_MC"]["Btn_MC"].enabled = fEnabled;
   }

   private function onActivePhotoClicked(nIndex:Number):Void
   {
      if(nIndex == undefined) nIndex = m_cArcTweenSet.getActiveIndex();
      m_pfPhotoClicked.call(this, [nIndex]);
   }

   public function getActiveIndex():Number
   {
      return m_cArcTweenSet.getActiveIndex();
   }

   public function setPhotoClickEvent(pfPhotoClick:Function):Void
   {
      m_pfPhotoClicked = pfPhotoClick;
   }

   public function nextPhoto(fEnableNewItem:Boolean):Void
   {
      var oItem:Object = m_cArcTweenSet.transitionToNextItem();
      m_cArcTweenSet.setItemEnabled(oItem, fEnableNewItem);
   }

   public function prevPhoto(fEnableNewItem:Boolean):Void
   {
      var oItem:Object = m_cArcTweenSet.transitionToPrevItem();
	  m_cArcTweenSet.setItemEnabled(oItem, fEnableNewItem);
   }

   public function setFolderLoadPath(sFolderPath:String):Void
   {
      m_sFolderPath = sFolderPath;
      m_cArcTweenSet.setFolderLoadPath(m_sFolderPath);
   }

   public function setImagesArray(aImages:Array):Void
   {
      m_aImages = aImages;
      m_cArcTweenSet.setItemContents(m_aImages);
   }

   public function addShutdownListener(pfShutdown:Function):Void {m_pfShutdown = pfShutdown;}

   public function shutDown(pfShutDownAftermath:Function, nAnimType:Number):Void
   {
      m_cArcTweenSet.shutDown(pfShutDownAftermath, nAnimType);
      setEnabled(false);
      new Tween(m_mcHolder, "_alpha", null, m_mcHolder._alpha, 0, 1, true);
   }

   public function isInTransition():Boolean {return m_cArcTweenSet.isInTransition();}
   public function getHolder():MovieClip {return m_mcHolder;}

   public function destroy():Void
   {
      m_mcHolder.removeMovieClip();
	  m_cArcTweenSet.destroy();
	  delete m_cArcTweenSet;
	  delete m_pfPhotoClicked;
   }
}
