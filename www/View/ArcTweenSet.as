//import mx.managers.DepthManager;
import mx.transitions.*;
import mx.transitions.easing.*;

class ArcTweenSet
{
   private var m_mcHolder:MovieClip;
   private var m_sItemLinkage:String;
   private var m_sItemMaskLinkage:String;
   private var m_nMaxVisibleItems:Number;
   private var m_nItemIndex:Number;
   private var m_nTotalItems:Number;
   private var m_aItems:Array;
   private var m_aItemContents:Array; //array of names of images to be loaded
   private var m_nHoRadius:Number;
   private var m_nVeRadius:Number;
   private var m_nPivotX:Number;
   private var m_nPivotY:Number;
   private var m_nAngleStart:Number;
   private var m_nAngleEnd:Number;
   private var m_nAngleTolerance:Number;
   private var m_oItemProps:Object;
   private var m_nItemDepth:Number;
   private var m_nTransitionTime:Number;
   private var m_fMultiAngleIncTransition:Boolean;
   private var m_mcNext:MovieClip;
   private var m_mcPrev:MovieClip;
   private var m_sLoadPath:String;
   private var m_pfActiveClick:Function;
   private var m_nLowestDepth:Number;
   private var m_oSelectedItem:Object;
   private var m_pfShutDownAftermath:Function;
   private var m_fCenterLoader:Boolean;
   private var m_fScaleContent:Boolean;
   private var m_pfUpdate:Function;

   public function ArcTweenSet(mcHolder:MovieClip, m_amcItems:Array)
   {
      m_mcHolder = mcHolder;
	  m_nTransitionTime = 1000;
      m_nItemIndex = 0;
      m_aItems = new Array();
      m_oItemProps = new Object();
	  m_nAngleTolerance = 0;
      inTransition(false);
	  m_nLowestDepth = 500000;
      m_pfShutDownAftermath = null;
      m_fCenterLoader = false;
      m_fScaleContent = true;
   }

   private function transitionItemsForward(nIncrements:Number, nTransTime:Number):Void
   {
      var nEndIndex:Number = m_nMaxVisibleItems;
	  var nIndex:Number = 0;

      for(nIndex = 0; nIndex <= m_nMaxVisibleItems; nIndex++)
      {
         var oItem:Object = m_aItems[nIndex];
         if(nTransTime) oItem["cArcTw"].SetDuration(nTransTime);
         transitionItemForward(oItem, nIndex, nIncrements);
		 oItem["cArcTw"].SetDuration(m_nTransitionTime);
	  }
	  var aItems:Array = m_aItems.splice(0, nIncrements);
	  var nRemovedItems:Number = aItems.length;
	  for(nIndex = 0; nIndex < nRemovedItems; nIndex++)
	  {
         var oItem:Object = aItems[nIndex];
	     oItem["cArcTw"].SetCompleteEvent(Fxn.FunctionProxy(this, removeItem, [oItem]));
         oItem["fExit"] = true;
	  }
      if(m_pfShutDownAftermath) oItem["cArcTw"].SetCompleteEvent(Fxn.FunctionProxy(this, shutDownAftermath, [oItem]));
      //cArcTw.SetCompleteEvent(Fxn.FunctionProxy(this, onTransitionComplete));
   }

   private function transitionItemsBackward(nIncrements:Number, nTransTime:Number):Void
   {	  
	  var nIndex:Number = 0;
      //var nEndIndex:Number = m_nMaxVisibleItems + 1;
	  
      for(nIndex = 0; nIndex <= m_nMaxVisibleItems; nIndex++)
      {
         var oItem:Object = m_aItems[nIndex];
         if(nTransTime) oItem["cArcTw"].SetDuration(nTransTime);
         transitionItemBackward(oItem, nIndex, nIncrements);
         oItem["cArcTw"].SetDuration(m_nTransitionTime);
	  }
	  var nItems:Number = m_aItems.length;
      var aItems:Array = m_aItems.splice(nItems - nIncrements, nIncrements);
	  var nRemovedItems:Number = aItems.length;
	  for(nIndex = 0; nIndex < nRemovedItems; nIndex++)
	  {
         var oItem:Object = aItems[nIndex];
	     oItem["cArcTw"].SetCompleteEvent(Fxn.FunctionProxy(this, removeItem, [oItem]));
         oItem["fExit"] = true;
	  }
      //cArcTw.SetCompleteEvent(Fxn.FunctionProxy(this, onTransitionComplete));
   }

   private function transitionItemForward(oItem:Object, nIndex:Number, nIncrements:Number):Void
   {
	  var nEndIndex:Number = m_nMaxVisibleItems + 1;
      var nAngleRange:Number = m_nAngleEnd - m_nAngleStart;
      var nAngleInc:Number = (nAngleRange / m_nMaxVisibleItems)
	  var nInc:Number = -(nIncrements-1)*nAngleInc;
	  var nEndAngle:Number = m_nAngleEnd - (nAngleInc)*(nEndIndex - nIndex) + nInc;
      var cArcTw:ArcTween = oItem["cArcTw"];
      var nStartAngle:Number = cArcTw.getAngle();
      if(nIndex < nIncrements)
      {
         nEndAngle -= m_nAngleTolerance;
         delete oItem["Item_MC"].onPress;
         //cArcTw.SetCompleteEvent(Fxn.FunctionProxy(this, removeItem, [oItem]));
      }
	
      //if(nIndex >= (nEndIndex - nIncrements)) nStartAngle += m_nAngleTolerance;
      cArcTw.SetAngleRoute(nStartAngle, nEndAngle);
	  if(m_pfShutDownAftermath) {cArcTw.removeOnAnimationEvent();}
	  else cArcTw.SetOnAnimationEvent(Fxn.FunctionProxy(this, OnArcAnimEnterFrame), [oItem]);
      cArcTw.StartAnimation();
   }

   private function transitionItemBackward(oItem:Object, nIndex:Number, nIncrements:Number):Void
   {
      var nAngleRange:Number = m_nAngleEnd - m_nAngleStart;
      var nAngleInc:Number = (nAngleRange / m_nMaxVisibleItems);
	  var nInc:Number = (nIncrements-1)*nAngleInc;
      var nAngle:Number = m_nAngleEnd - (nAngleInc)*(nIndex) - nInc;
      var cArcTw:ArcTween = oItem["cArcTw"];
      var nStartAngle:Number = cArcTw.getAngle();
      var nEndAngle:Number = m_nAngleStart + (nAngleInc)*(nIndex) + nInc; //nStartAngle + nAngleInc;
      if(nIndex < nIncrements)
      {
         nStartAngle = m_nAngleStart - m_nAngleTolerance;
         nEndAngle =  m_nAngleStart;
         //cArcTw.SetCompleteEvent(Fxn.FunctionProxy(this, removeItem, [oItem]));
      }
      //if(nIndex >= (nEndIndex - nIncrements)) nAngle -= m_nAngleTolerance;
      cArcTw.SetAngleRoute(nStartAngle, nEndAngle);
      cArcTw.SetOnAnimationEvent(Fxn.FunctionProxy(this, OnArcAnimEnterFrame), [oItem]);
      cArcTw.StartAnimation();
   }

   private function onTransitionComplete():Void
   {

   }

   public function createItems():Void
   {
      var cT:EventTimer = null;
      var nIndex:Number = m_nItemIndex;
      var nEndIndex:Number = nIndex + m_nMaxVisibleItems;
      var nTime:Number = 1;
      inTransition(true);
      for(nIndex; nIndex < nEndIndex; nIndex++)
	  {
		 cT = new EventTimer(Fxn.FunctionProxy(this, createInitItem), nTime);
         cT.StartTimer();
         nTime += 100;
	  }
      cT = new EventTimer(Fxn.FunctionProxy(this, onInitItemCreateComplete), nTime);
      cT.StartTimer();
   }

   private function createInitItem():Void
   {
      if(!m_pfShutDownAftermath)
      {
         var oItem:Object = queueItemAtEnd();
	     var cT:EventTimer = new EventTimer(Fxn.FunctionProxy(this, LoadContentIntoItem, [oItem]), 1000);
         cT.StartTimer();
	  }
      //LoadContentIntoItem(oItem);
   }

   private function onInitItemCreateComplete():Void
   {
      var nIndex:Number = 0;
      var nItems:Number = m_aItems.length;
	  for(nIndex = 0; nIndex < nItems; nIndex++)
	  {
         var oItem:Object = m_aItems[nIndex];
         //LoadContentIntoItem(oItem);
	  }
	  enableItemPress();
   }

   private function setItemSelected(oItem:Object, fYes:Boolean):Void
   {
      /*
      var mcItem:MovieClip = oItem["Item_MC"];
      if(true == fYes)
      {
         mcItem.gotoAndStop("selected");
         m_oSelectedItem["Item_MC"].gotoAndStop("unselected");
         m_oSelectedItem = oItem;
	  }
      else
      {
         mcItem.gotoAndStop("selected");
	  }
	  */
   }

   public function transitionToNextItem():Object
   {
      var oItem:Object = queueItemAtEnd(true);
      setItemSelected(oItem);
      transitionItemsForward(1);
      //updateDepths(); //Needed since addition done with lowest depth
	  //removeQueuedItemsAtStart(1);
      if(!isInTransition()) setItemEnabled(oItem, true);
      LoadContentIntoItem(oItem);
      return oItem;
   }

   public function transitionToPrevItem():Object
   {
      var oItem:Object = queueItemAtStart(true);
      setItemSelected(oItem);
      transitionItemsBackward(1);
	  //updateDepths(); //No need since addition done with highest depth
      //removeQueuedItemsAtEnd(1);
      if(!isInTransition()) setItemEnabled(oItem, true);
      LoadContentIntoItem(oItem);
      return oItem;
   }

   public function setItemEnabled(oItem:Object, fEnabled:Boolean):Void
   {
      if(fEnabled)
	  {
         oItem["Item_MC"].onPress = Fxn.FunctionProxy(this, onItemPress, [oItem]);
         oItem["Item_MC"].onRollOver = function() {this["Bg_MC"]["Blink_MC"].gotoAndPlay("hover");}
	  }
      else
      {
         delete oItem["Item_MC"].onPress;
         delete oItem["Item_MC"].onRollOver;
	  }
   }

   private function removeItem(oItem:Object):Void
   {
      oItem["cArcTw"].destroy();
      oItem["cLoader"].destroy();
      oItem["Item_MC"].removeMovieClip();
      delete oItem["cLoader"];
      delete oItem["cArcTw"];
   }

   private function queueItemAtStart(fPress:Boolean):Object
   {
      var nItems:Number = m_aItems.length;
      var nPrevIndex:Number = (m_aItems[0]["nIndex"] - 1);
      if(nPrevIndex < 0) nPrevIndex = m_nTotalItems - 1;
      var fQueueLimit:Boolean = (nItems == m_nMaxVisibleItems);
      var nEndIndex:Number = m_nMaxVisibleItems;
      var nAngleRange:Number = m_nAngleEnd - m_nAngleStart;
      var nAngleInc:Number = nAngleRange / m_nMaxVisibleItems;
      //var nItemIndex:Number = (m_nItemIndex + nItems)%m_nTotalItems;
      var nDepth:Number = m_mcHolder.getNextHighestDepth();
	  var nItemIndex:Number = decItemIndex(1);
      var oItem:Object = createItem(nDepth, nPrevIndex);
	  //m_nLowestDepth++;
      var mcItem:MovieClip = oItem["Item_MC"];
      var cArcTw:ArcTween = initItemTween(oItem);
      var nAngle:Number = m_nAngleStart + nAngleInc * nItems;
      cArcTw.SetClipOnArc(m_nAngleStart - nAngleInc - m_nAngleTolerance);
      cArcTw.SetAngleRoute(m_nAngleStart, nAngle);
      cArcTw.StartAnimation();
      oItem["cArcTw"] = cArcTw;
      mcItem._visible = true;
	  m_aItems.splice(0, 0, oItem); //Insert at start of array
      return oItem;
   }

   private function queueItemAtEnd(fPress:Boolean, nTransTime:Number):Object
   {
      var nItems:Number = m_aItems.length;
      var nNxIndex:Number = (m_aItems[nItems-1]["nIndex"] + 1)%m_nTotalItems;
      //var nLowestDepth:Number = m_aItems[nItems-1]["Item_MC"].getDepth() - 1;
	  //if(isNaN(nLowestDepth)) nLowestDepth = 500000;
	  if(isNaN(nNxIndex)) nNxIndex = 0;
      var fQueueLimit:Boolean = (nItems == m_nMaxVisibleItems);
      var nEndIndex:Number = m_nMaxVisibleItems;
      var nAngleRange:Number = m_nAngleEnd - m_nAngleStart;
      var nAngleInc:Number = nAngleRange / m_nMaxVisibleItems;
      //var nItemIndex:Number = (m_nItemIndex + nItems)%m_nTotalItems;
      //var nDepth:Number = m_nTotalItems - nNxIndex + 1;
	  //if(fPress) nDepth = m_mcHolder.getNextHighestDepth();
      var oItem:Object = createItem(m_nLowestDepth--, nNxIndex);
      var mcItem:MovieClip = oItem["Item_MC"];
      var cArcTw:ArcTween = initItemTween(oItem);
      var nAngle:Number = m_nAngleEnd - nAngleInc *(nEndIndex - nItems);
      cArcTw.SetClipOnArc(m_nAngleEnd + m_nAngleTolerance);
      cArcTw.SetAngleRoute(m_nAngleEnd, nAngle);
      oItem["cArcTw"] = cArcTw;
      mcItem._visible = true;
      m_aItems.push(oItem);
      if(true == fQueueLimit || fPress) incItemIndex(1);
      if(true == fPress && nTransTime)
	  {
         cArcTw.SetDuration(nTransTime);
	  }
	  cArcTw.StartAnimation();
      cArcTw.SetDuration(m_nTransitionTime);
      //else LoadContentIntoItem(oItem); //Invoked at start
      return oItem;
   }

   private function incItemIndex(nInc:Number):Number
   {
      m_nItemIndex += nInc;
      if(m_nItemIndex >= m_nTotalItems) m_nItemIndex = 0;
	  return m_nItemIndex;
   }

   private function decItemIndex(nDec:Number):Number
   {
      m_nItemIndex -= nDec;
      if(m_nItemIndex < 0) m_nItemIndex = (m_nTotalItems - 1);
	  return m_nItemIndex;
   }

   private function createItem(nDepth:Number, nItemIndex:Number):Object
   {
      //var nLastDepth:Number = m_aItems[m_aItems.length - 1]["Item_MC"].getDepth();
	  //if(nLastDepth == nDepth) {trace("ERROR SAME DEPTH"); nDepth--;}
	  var mcItem:MovieClip = m_mcHolder.createEmptyMovieClip("Item_MC" + nDepth, nDepth);
      mcItem._visible = false;
      var mcBg:MovieClip = mcItem.attachMovie(m_sItemLinkage, "Bg_MC", 0, {_visible:false});
      var mcLoad:MovieClip = mcItem.attachMovie("BrowseItemLoad_MC", "Load_MC", 1, {_visible:false});
      var mcThumb:MovieClip = mcBg["PhotoImg_MC"]; //mcItem.createEmptyMovieClip("Thumb_MC", 1);
      var oItem:Object = new Object();
      mcThumb.createEmptyMovieClip("Img1_MC", 0); //Load Target
      mcThumb.createEmptyMovieClip("Img2_MC", 1); //Backup in case load fails so that we can attachMovie broken image

	  if(false == m_fCenterLoader)
	  {
         mcLoad._x = -mcBg._width/2 + mcLoad._width/2 + 5;
         mcLoad._y = -mcBg._height/2 + mcLoad._height/2 + 5;
	  }
      //mcThumb._visible = false;
      mcBg._alpha = 100;
	  mcBg["Label_TXT"].text = "" + (nItemIndex + 1); //nDepth
      mcBg["Depth_TXT"].text = ""; //nDepth;
	  oItem["mcLoad"] = mcLoad;
      oItem["Item_MC"] = mcItem;
	  oItem["Thumb_MC"] = mcThumb;
      oItem["cArcTw"] = null;
      oItem["nIndex"] = nItemIndex;
      oItem["cLoader"] = new ContentLoader(mcThumb["Img1_MC"]);
      oItem["fExit"] = false;
      oItem["fLoaded"] = false;
	  mcBg.onEnterFrame = function() {this._visible = true; delete this.onEnterFrame; mcLoad._visible = true;}
      return oItem;
   }

   //Need delay due to the updating of depths
   private function LoadContentWithDelay(oItem:Object):Void
   {
      var nInitTime:Number = 3000;
      var cT:EventTimer = new EventTimer(Fxn.FunctionProxy(this, LoadContentIntoItem, [oItem]), nInitTime);
      cT.StartTimer();
   }

   private function LoadContentIntoItem(oItem:Object):Void
   {
      //trace("LOAD INDEX: " + oItem["nIndex"]);
      //LoadAlternativeContentIntoItem(oItem); return; //TEMPORARY
	  if(oItem["fLoaded"] == true) return;
      var sFolder:String = "Thumbnails/";
      var mcThumb:MovieClip = oItem["Thumb_MC"]["Img1_MC"];
      var nItemIndex:Number = oItem["nIndex"];
	  //mcThumb._visible = false; //does not work
	  oItem["Thumb_MC"]._visible = false;
      var cLoader:ContentLoader = oItem["cLoader"];
	  cLoader.SetLoadEvent(Fxn.FunctionProxy(this, onItemThumbContentLoad), [oItem, nItemIndex]);
	  cLoader.LoadFile(m_sLoadPath + sFolder + m_aItemContents[nItemIndex]);
   }
   /*
   private function LoadAlternativeContentIntoItem(oItem:Object):Void
   {
      var sFolder:String = "Originals/";
      var mcThumb:MovieClip = oItem["Thumb_MC"]["Img1_MC"];
      var nItemIndex:Number = oItem["nIndex"];
	  oItem["cLoader"].destroy();
	  delete oItem["cLoader"];
	  oItem["cLoader"] = new ContentLoader(mcThumb["Img1_MC"]);
      var cLoader:ContentLoader = oItem["cLoader"];
	  cLoader.SetLoadEvent(Fxn.FunctionProxy(this, onAlternativeItemContentLoad), [oItem, nItemIndex]);
	  cLoader.LoadFile(m_sLoadPath + sFolder + m_aItemContents[nItemIndex]);
   }*/

   private function onItemThumbContentLoad(fSuccess:Boolean, aParams:Array):Void
   {
      var oItem:Object = aParams[0];
      var mcThumb:MovieClip = oItem["Thumb_MC"]["Img2_MC"];
	  if(true == fSuccess)
	  {
		 //mcThumb._visible = true;
         initLoadedContent(oItem);
	  }
	  else
	  {
         trace("ERROR: No Thumbnail found, loading alternative..");
         //LoadAlternativeContentIntoItem(oItem);
         //WTF: Does not work -> var mcBroken:MovieClip = mcThumb.attachMovie("BlankThumbnail_MC", "BlankThumbnail_MC", 10);
	     var mcBroken:MovieClip = mcThumb.attachMovie("BlankThumbnail_MC", "BlankThumbnail_MC", 10);
         var nDim:Number = oItem["Item_MC"]._width - 30;
         //var oDim:Object = Fxn.getMaxFitDimensions(mcBroken._width, mcBroken._height, nDim, nDim);
         //mcBroken._width = oDim["nW"];
         //mcBroken._height = oDim["nH"];
      }
      oItem["Item_MC"]["Bg_MC"]["Blink_MC"].gotoAndPlay("select");
      oItem["Thumb_MC"]._visible = true;
      oItem["mcLoad"].removeMovieClip();
      delete oItem["mcLoad"];
   }
   /*
   private function onAlternativeItemContentLoad(fSuccess:Boolean, aParams:Array):Void
   {
	  //trace("ALT: " + aParams[0] + ":" + oItem["Thumb_MC"]);
	  //for(var mc in aParams[0]) trace("==WTF: " + mc);
      var oItem:Object = aParams[0];
      var nIndex:Number = aParams[1];
      var mcThumb:MovieClip = oItem["Thumb_MC"];
	  mcThumb.onEnterFrame = Fxn.FunctionProxy(this, initLoadedContent, [oItem]); //function()
	  {
         //var nInitTime:Number = 2000;
	     //var cT:EventTimer = new EventTimer(Fxn.FunctionProxy(this, initLoadedContent, [this]), nInitTime);
         //cT.StartTimer();
	  }
	  //initLoadedContent(mcThumb);
   }*/

   private function initLoadedContent(oItem:Object):Void
   {
      var mcThumb:MovieClip = oItem["Thumb_MC"];
      var mcParent:MovieClip = mcThumb._parent;
      var nItemW:Number = 167; //150 Orig Width - 2*5 side
      var nItemH:Number = 167;
      var oDim:Object = Fxn.getMaxFitDimensions(mcThumb._width, mcThumb._height, nItemW, nItemH);
	  if(true == m_fScaleContent)
	  {
	     mcThumb._width = oDim["nW"];
	     mcThumb._height = oDim["nH"];
	  }
	  mcThumb._x = -mcThumb._width/2;
	  mcThumb._y = -mcThumb._height/2;
      mcThumb._alpha = 100;
      mcThumb._parent._parent["Load_MC"].removeMovieClip();
	  oItem["fLoaded"] = true;
      //oItem["Item_MC"]["Bg_MC"]["Blink_MC"].gotoAndPlay("select");
      delete mcThumb.onEnterFrame;
   }
   /*
   private function getMinFitDimensions(nW:Number, nH:Number, nFitW:Number, nFitH:Number):Object
   {
	  var nRatioW:Number = nW / nFitW;
	  var nRatioH:Number = nH / nFitH;
	  if(nRatioW > nRatioH) return {nW:nFitW, nH:nH*nFitW/nW};
      else return {nW:nW*nFitH/nH, nH:nFitH};
   }

   private function getMaxFitDimensions(nW:Number, nH:Number, nFitW:Number, nFitH:Number):Object
   {
	  var nRatioW:Number = nW / nFitW;
	  var nRatioH:Number = nH / nFitH;
	  if(nRatioW < nRatioH) return {nW:nFitW, nH:nH*nFitW/nW};
      else return {nW:nW*nFitH/nH, nH:nFitH};
   }*/

   public function onItemPress(oItem:Object):Void
   {
      var nIndex:Number = oItem["nIndex"];
      if(nIndex == m_nItemIndex)
	  {
         oItem["Item_MC"]["Bg_MC"]["Blink_MC"].gotoAndPlay("select");
         m_pfActiveClick.apply(this, [m_nItemIndex]);
	     return;
	  }else m_pfUpdate.apply(this, [nIndex]);
	  oItem["Item_MC"]["Bg_MC"]["Blink_MC"].gotoAndPlay("select");
	  setItemSelected(oItem);
      inTransition(true);
      disableItemPress();
      var cT:EventTimer = null;
      var nTime:Number = 1;
      var nIterate:Number = m_nItemIndex - nIndex;
      if(nIterate < 0) nIterate = -nIterate;
      else nIterate = nIndex + (m_nTotalItems - m_nItemIndex);
	  var nTransTime:Number = m_nTransitionTime + nIterate * 200;
	  transitionItemsForward(nIterate, nTransTime);
	  //removeQueuedItemsAtStart(nIterate);
	  
      while(nIterate-- > 0)
	  {
		 cT = new EventTimer(Fxn.FunctionProxy(this, periodicQueueing, [nIterate, nTransTime]), nTime);
         cT.StartTimer();
         nTime += 100;
	  }
      cT = new EventTimer(Fxn.FunctionProxy(this, enableItemPress), nTime);
      cT.StartTimer();
   }

   private function periodicQueueing(nIncrements:Number, nTransTime:Number):Void
   {
      if(!m_pfShutDownAftermath)
	  {
         var oItem:Object = queueItemAtEnd(true, nTransTime);
         //transitionItemForward(oItem, m_aItems.length - 2, nIncrements);
         //updateDepths();
         //removeQueuedItemsAtStart(1);
         LoadContentIntoItem(oItem);
	  }
   }

   public function disableItemPress():Void
   {
      var nItems:Number = m_aItems.length;
      for(var n:Number = 0; n < nItems; n++)
      {
         var oItem:Object = m_aItems[n];
         delete oItem["Item_MC"].onPress;
         delete oItem["Item_MC"].onRollOver;
	  }
   }

   public function enableItemPress():Void
   {
      var nItems:Number = m_aItems.length;

	  for(var n:Number = 0; n < nItems; n++)
      {
         var oItem:Object = m_aItems[n];
         var nItemIndex:Number = oItem["nIndex"];
         oItem["Item_MC"].onPress = Fxn.FunctionProxy(this, onItemPress, [oItem]);
         oItem["Item_MC"].onRollOver = function() {this["Bg_MC"]["Blink_MC"].gotoAndPlay("hover");}
	  }
      inTransition(false);
   }

   private function OnArcAnimEnterFrame(aParameters:Array):Void
   {
      //trace("SystemView::OnArcAnimEnterFrame");
      var nPercComplete:Number = aParameters[0]; //Params from ArcTween
      var aThisParams:Array = aParameters[1]; //Params passed from This class
      var oItem:Object = aThisParams[0];
      var fExitItem:Boolean = oItem["fExit"];
      var mcItem:MovieClip = oItem["Item_MC"];
      var nAngle:Number = oItem["cArcTw"].getAngle();
	  var nAngleRange:Number = m_nAngleEnd - m_nAngleStart;
      var nPerc:Number = (m_nAngleEnd - nAngle) / (nAngleRange) * 100;
      var nMinA:Number = m_oItemProps["nMinAlpha"];
      var nMaxA:Number = m_oItemProps["nMaxAlpha"];
      var nMinS:Number = m_oItemProps["nMinScale"];
      var nMaxS:Number = m_oItemProps["nMaxScale"];
      var nMinR:Number = m_oItemProps["nMinRot"];
      var nMaxR:Number = m_oItemProps["nMaxRot"];
	  //var nMinX:Number = m_oItemProps["nMinX"];
      //var nMaxX:Number = m_oItemProps["nMaxX"];
	  //var nMinY:Number = m_oItemProps["nMinY"];
      //var nMaxY:Number = m_oItemProps["nMaxY"];
	  var nMin:Number = m_nAngleEnd;
	  var nMax:Number = m_nAngleStart;
	  var nAngleRange:Number = nMax - nMin; //∆x
	  var nScale:Number = nMaxS - nMinS; //∆y
      var nAlpha:Number = nMaxA - nMinA; //∆y
      var nRotation:Number = nMaxR - nMinR; //∆y
      //var nX:Number = nMaxX - nMinX; //∆y
	  //var nY:Number = nMaxY - nMinY; //∆y
      var nSlopeA:Number = nAlpha/nAngleRange;
	  var nSlopeS:Number = nScale/nAngleRange;
      var nSlopeR:Number = nRotation/nAngleRange;
	  //var nSlopeX:Number = nX/nAngleRange;
	  //var nSlopeY:Number = nY/nAngleRange;
      var nInterceptA:Number = nMinA - (nMin  * nSlopeA);
	  var nInterceptS:Number = nMinS - (nMin  * nSlopeS);
      var nInterceptR:Number = nMinR - (nMin  * nSlopeR);
	  //var nInterceptX:Number = nMinX - (nMin  * nSlopeX);
	  //var nInterceptY:Number = nMinY - (nMin  * nSlopeY);
	  var nFiScale:Number = (nAngle*nSlopeS) + nInterceptS;
	  var nFiAlpha:Number = (nAngle*nSlopeA) + nInterceptA;
      var nFiRotation:Number = (nAngle*nSlopeR) + nInterceptR;
	  //var nFiX:Number = (nAngle*nSlopeX) + nInterceptX;
	  //var nFiY:Number = (nAngle*nSlopeY) + nInterceptY;
      mcItem._rotation = nFiRotation;
	  //mcItem._x -= nFiX;
	  //mcItem._y -= nFiY;
      //oItem["cArcTw"].SetClipOnArc(nAngle - (100 - nFiScale)*nAngleRange/m_nTotalItems/100);
      if(fExitItem == true)
	  {
         var nScale:Number = mcItem._xscale - 7;
		 if(nScale < 1) nScale = 1;
         mcItem._xscale = nScale;
		 mcItem._yscale = nScale;
	  }
	  else
	  {
         mcItem._xscale = nFiScale;
	     mcItem._yscale = nFiScale;
	     mcItem._alpha = nFiAlpha;
	  }
      //Routine below not necessessary, just to free up memory
	  
	  var fRemove:Boolean = true;
	  fRemove &= (nAngle < (-m_nAngleTolerance + 15));
	  fRemove &= (oItem["fExit"] == true);
	  if(true == fRemove) removeItem(oItem);
	  
   }

   private function initItemTween(oItem:Object):ArcTween
   {
      var mcItem:MovieClip = oItem["Item_MC"];
      var cArcTw:ArcTween = new ArcTween(mcItem);
      cArcTw.SetRotationPivot(m_nPivotX, m_nPivotY);
      cArcTw.SetRadius(m_nHoRadius, m_nVeRadius);
      cArcTw.SetDuration(m_nTransitionTime);
      cArcTw.disableRatioScale();
      cArcTw.SetOnAnimationEvent(Fxn.FunctionProxy(this, OnArcAnimEnterFrame), [oItem]);
	  return cArcTw;
   }

   public function setPivot(nPivotX:Number, nPivotY:Number):Void
   {
      m_nPivotX = nPivotX;
      m_nPivotY = nPivotY;
   }

   public function setRadius(nHoRadius:Number, nVeRadius:Number):Void
   {
      m_nHoRadius = nHoRadius;
      m_nVeRadius = nVeRadius;
   }

   public function setItemGraphic(sLinkage:String, fCenterLoader:Boolean):Void {m_sItemLinkage = sLinkage; m_fCenterLoader = fCenterLoader;}
   public function setItemMask(sLinkage:String):Void {m_sItemMaskLinkage = sLinkage;}
   public function setVisibleItems(nItems:Number):Void {m_nMaxVisibleItems = nItems;}
   public function setTotalItems(nItems:Number):Void {m_nTotalItems = nItems;}
   public function setTransitionTime(nTime:Number):Void {m_nTransitionTime = nTime;}
   public function setAngleRemovalTolerance(nAngle:Number):Void {m_nAngleTolerance = nAngle;}


   public function setScaleRange(nMinScale:Number, nMaxScale:Number)
   {
      m_oItemProps["nMinScale"] = nMinScale;
      m_oItemProps["nMaxScale"] = nMaxScale;
   }

   public function setAlphaRange(nMinAlpha:Number, nMaxAlpha:Number)
   {
      m_oItemProps["nMinAlpha"] = nMinAlpha;
      m_oItemProps["nMaxAlpha"] = nMaxAlpha;
   }

   public function setRotationRange(nMinRot:Number, nMaxRot:Number):Void
   {
      m_oItemProps["nMinRot"] = nMinRot;
      m_oItemProps["nMaxRot"] = nMaxRot;
   }

   public function setXRange(nMinX:Number, nMaxX:Number):Void
   {
      m_oItemProps["nMinX"] = nMinX;
      m_oItemProps["nMaxX"] = nMaxX;
   }

   public function setYRange(nMinY:Number, nMaxY:Number):Void
   {
      m_oItemProps["nMinY"] = nMinY;
      m_oItemProps["nMaxY"] = nMaxY;
   }

   public function setArcAngleLimits(nAngleStart:Number, nAngleEnd:Number):Void
   {
      m_nAngleStart = nAngleStart;
      m_nAngleEnd = nAngleEnd;
   }

   public function setTransitionControlButtons(mcNextBtn:MovieClip, mcPrevBtn:MovieClip):Void
   {
      m_mcNext = mcNextBtn;
	  m_mcPrev = mcPrevBtn;
   }

   private function inTransition(fInMultiAngleIncTransition:Boolean):Void
   {
      var fEnable:Boolean = m_fMultiAngleIncTransition;
      m_fMultiAngleIncTransition = fInMultiAngleIncTransition;
	  m_mcNext.enabled = fEnable;
      m_mcPrev.enabled = fEnable;
   }

   public function isInTransition():Boolean {return m_fMultiAngleIncTransition;}

   public function setFolderLoadPath(sLoadPath:String):Void
   {
      m_sLoadPath = sLoadPath;
   }

   public function addActiveItemListener(pfClickEvent:Function):Void
   {
      m_pfActiveClick = pfClickEvent;
   }

   public function getActiveIndex():Number {return m_nItemIndex;}

   public function setItemContents(aItemContents:Array) {m_aItemContents = aItemContents;}

   public function shutDown(pfShutDownAftermath:Function, nAnimType):Void
   {
      inTransition(true);
      disableItemPress();
      m_pfShutDownAftermath = pfShutDownAftermath;
	  if(nAnimType == undefined) transitionItemsForward(m_nMaxVisibleItems, 2000);
	  else if(nAnimType == 1) {removeItemsOneByOne();}
   }

   private function removeItemsOneByOne():Void
   {
      var cT:EventTimer = null;
      var nIndex:Number = 0;
      var nEndIndex:Number = m_aItems.length;
      var nTime:Number = 1;

      for(nIndex; nIndex < nEndIndex; nIndex++)
	  {
         var oItem:Object = m_aItems[nIndex];
		 cT = new EventTimer(Fxn.FunctionProxy(this, fadeOutItem, [oItem]), nTime);
         cT.StartTimer();
         nTime += 50;
	  }
      cT = new EventTimer(Fxn.FunctionProxy(this, shutDownAftermath, [oItem]), nTime + 1000);
      cT.StartTimer();
   }

   private function fadeOutItem(oItem:Object):Void
   {
      var mcItem:MovieClip = oItem["Item_MC"];
      var nTolerance:Number = 80;
      var nX:Number = nTolerance * Fxn.RandomNumber() - nTolerance;
      var nY:Number = nTolerance * Fxn.RandomNumber() - nTolerance;
      var cTw:Tween = new Tween(mcItem, "_xscale", Strong.easeOut, mcItem._xscale, 0, 1, true);
	  var cTw:Tween = new Tween(mcItem, "_yscale", Strong.easeOut, mcItem._yscale, 0, 1, true);
	  var cTw:Tween = new Tween(mcItem, "_x", Strong.easeOut, mcItem._x, mcItem._x + nY, 1, true);
	  var cTw:Tween = new Tween(mcItem, "_y", Strong.easeOut, mcItem._y, mcItem._y + nX, 1, true);
	  cTw.onMotionFinished = Fxn.FunctionProxy(this, removeItem, [oItem]);
   }

   public function addUpdateHandler(pfUpdate:Function):Void {m_pfUpdate = pfUpdate;}
   public function enableContentScaling(fScale:Boolean):Void {m_fScaleContent = fScale;}

   public function shutDownAftermath(oLastItem:Object):Void
   {
      removeItem(oLastItem);
      m_pfShutDownAftermath.call(this);
   }

   public function destroy():Void
   {
      m_mcHolder.removeMovieClip();
	  delete m_aItems;
	  delete m_aItemContents;
	  delete m_pfActiveClick;
	  delete m_oItemProps;
   }
}
