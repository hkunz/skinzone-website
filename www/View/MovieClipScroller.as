//**********************************************************
//*  MovieClipScroller (for ActionScript 2.0)
//**********************************************************
//*  Author: Harry Roland Kunz
//*  e-mail: har_rki219_mc2e@yahoo.com
//*        : hkunz@lexmark.com
//*
//*  The MovieClipScroller lets you scroll through
//*  a MovieClip Content like a Scroller TextField
//*
//*  Steps to Use:
//*  1. Instantiate an Empty MovieClip
//*  2. Instantiate new MovieClipScroller and pass MovieClip
//*  3. setContentLinkage("Linkage of MovieClip in Library")
//*  4. Set Mask either by setLineDrawMask or setGraphicMask
//*  5. Set Scroll Bar by setVeScroller and/or setHoScroller
//*     See Function Description for nested MovieClip Detail
//*  6. Set needed listeners in m_oListener with addListener
//*
//**********************************************************
//*   Date Created: 11/09/2009
//*  Last Modified: 11/11/2009
//**********************************************************

import mx.utils.Delegate;
import mx.transitions.*;
import mx.transitions.easing.*;

class MovieClipScroller
{
   private var m_cTween:Tween;
   private var m_mcHolder:MovieClip;
   private var m_mcContent:MovieClip;
   private var m_mcMask:MovieClip; //Masks the Content in m_mcContent
   private var m_mcVeScroll:MovieClip;
   private var m_mcHoScroll:MovieClip;
   private var m_nContentX:Number;
   private var m_nContentY:Number;
   private var m_nWidth:Number;
   private var m_nHeight:Number;
   private var m_nContentHeight:Number;
   private var m_nContentWidth:Number;
   private var m_nEaseInTweenTime:Number;
   private var m_nPressTimerId:Number;
   private var m_nVeScrollPerc:Number;
   private var m_nHoScrollPerc:Number;
   private var m_fKnobDrag:Boolean;
   private var m_oListener:Object; //Props: "onVeScroll", "onHoScroll" to return Percentage, "onKnobPress", "onKnobRelease"

   private static var SCROLL_BUTTON_LONG_PRESS_DELAY_TIME:Number = 500; //0.5 Seconds Delay before continuous increment takes place
   private static var SCROLL_KNOB_INCREMENT_TIME_ON_LONG_PRESS:Number = 50; //Knob Position Increment every 0.05 Seconds on Long Press
   private static var PERCENT_SCROLL_INCREMENT:Number = 0.05; //5% Scroll Knob Increment based on Knob Length
   private static var MINIMUM_KNOB_BODY_LENGTH:Number = 5; //Length in Pixels of Knob Body when content length reaches infinity

   //MovieClips Nested in Main Scroll Bar MovieClip
   private static var SCROLL_BAR_BODY_MC:String = "Body_MC"; //Scroll Bar Scrolling Length
   private static var SCROLL_BUTTON_1_MC:String = "Btn1_MC"; //Upper/Left Scroo Button of Scroll Bar
   private static var SCROLL_BUTTON_2_MC:String = "Btn2_MC"; //Lower/Right Scroll Button of Scroll Bar
   private static var KNOB_MC:String = "Knob_MC"; //Knob

   //MovieClips Nested in "Knob_MC" MovieClip
   private static var KNOB_BODY_MC:String = "KnobBody_MC"; //Knob Body used for Scroll Knob Elongation
   private static var KNOB_EDGE_1_MC:String = "Edge1_MC"; //Upper/Left Edge of Knob
   private static var KNOB_EDGE_2_MC:String = "Edge2_MC"; //Lower/Right Edge of Knob

   /********************************************************************************
   * Constructor: Pass Empty MovieClip as Parent Container
   * NOTE: Width & Height are determined either by SetGraphicMask or SetLineDrawMask
   ********************************************************************************/
   public function MovieClipScroller(mcHolder:MovieClip)
   {
      trace("ScrollerWindow::ScrollerWindow(" + mcHolder + ")");
	  m_mcHolder = mcHolder;
	  m_mcContent = null;
	  m_nEaseInTweenTime = 0; //If not zero, Strong.easeIn invoked per that time interval
	  m_nPressTimerId = null;
	  m_fKnobDrag = false;
	  m_oListener = null;
	  m_nVeScrollPerc = 0;
	  m_nHoScrollPerc = 0;
	  m_nContentX = 0;
	  m_nContentY = 0;
   }

   public function setContentLinkage(sLinkage:String):MovieClip
   {
      trace("ScrollerWindow::setContentLinkage(" + sLinkage + ")");
      var nDepth:Number = m_mcHolder.getNextHighestDepth();
      m_mcContent = m_mcHolder.attachMovie(sLinkage, sLinkage, nDepth);
	  m_nContentHeight = m_mcContent._height;
	  m_nContentWidth = m_mcContent._width;
	  return m_mcContent;
   }

   public function setContentMc(mcContent:MovieClip):Void
   {
      m_mcContent = mcContent;
	  m_nContentHeight = m_mcContent._height;
	  m_nContentWidth = m_mcContent._width;
   }

   /********************************************************************************
   * SetGraphicMask Creates a Mask with Graphic in Library
   ********************************************************************************/
   public function setGraphicMask(sLinkage:String):MovieClip
   {
      trace("ScrollerWindow::setViewableMask(" + sLinkage + ")");
      var nDepth:Number = m_mcHolder.getNextHighestDepth();
      m_mcMask = m_mcHolder.attachMovie(sLinkage, sLinkage, nDepth);
      m_mcContent.setMask(m_mcMask);
      m_nWidth = m_mcMask._width;
      m_nHeight = m_mcMask._height;
	  return m_mcMask;
   }

   /********************************************************************************
   * SetLineDrawMask Creates a Mask with Dynamic Line Drawing
   ********************************************************************************/
   public function setLineDrawMask(nWidth:Number, nHeight:Number):MovieClip
   {
      trace("ScrollerWindow::setLineDrawMask(" + nWidth + "," + nHeight + ")");
	  var nDepth:Number = m_mcHolder.getNextHighestDepth();
      m_nWidth = nWidth;
	  m_nHeight = nHeight;
	  m_mcMask = m_mcHolder.createEmptyMovieClip("Mask_MC", nDepth);
      m_mcContent.setMask(m_mcMask);
	  m_mcMask.lineStyle(1,0xFFFFFF,100);
      m_mcMask.moveTo(0,0);
      m_mcMask.beginFill(0xFFFFFF, 100);
      m_mcMask.lineTo(m_nWidth, 0);
      m_mcMask.lineTo(m_nWidth, m_nHeight);
      m_mcMask.lineTo(0, m_nHeight);
      m_mcMask.lineTo(0, 0);
      m_mcMask.endFill();
	  return m_mcMask;
   }

   /********************************************************************************
   * sLinkage -> Linkage to Vertical Scroll Bar Graphic
   * With 4 Nested MCs of Instances "Body_MC", "Btn1_MC", "Btn2_MC", "Knob_MC"
   * Extra: 3 Nested MCs in "Knob_MC" for elongation purposes
   * With Instance names of "KnobBody_MC", "Edge1_MC", "Edge2_MC"
   ********************************************************************************/
   public function setVeScroller(sLinkage:String):MovieClip
   {
      trace("ScrollerWindow::setVeScroller(" + sLinkage + ")");
      var nDepth:Number = m_mcHolder.getNextHighestDepth();
	  var mcBtnUp:MovieClip = null;
	  var mcBtnDown:MovieClip = null;
	  m_mcVeScroll = m_mcHolder.attachMovie(sLinkage, sLinkage, nDepth);
	  m_mcVeScroll._x = m_nWidth;
	  m_mcVeScroll._y = 0;
	  mcBtnUp = m_mcVeScroll[SCROLL_BUTTON_1_MC];
	  mcBtnDown = m_mcVeScroll[SCROLL_BUTTON_2_MC];
	  m_mcVeScroll[KNOB_MC].onPress = Delegate.create(this, onVeKnobPress);
	  mcBtnUp.onPress = Delegate.create(this, onVeBtnUpPress);
	  mcBtnDown.onPress = Delegate.create(this, onVeBtnDownPress);
	  mcBtnUp.onRelease = Delegate.create(this, clearPressTimer);
	  mcBtnUp.onDragOut = Delegate.create(this, clearPressTimer);
	  mcBtnDown.onRelease = Delegate.create(this, clearPressTimer);
      mcBtnDown.onDragOut = Delegate.create(this, clearPressTimer);
	  updateVeScrollerLength(true);
	  return m_mcVeScroll;
   }

   public function SetVeScrollEnabled(fEnabled:Boolean):Void
   {
      m_mcVeScroll[SCROLL_BUTTON_1_MC].enabled = fEnabled;
	  m_mcVeScroll[SCROLL_BUTTON_2_MC].enabled = fEnabled;
	  m_mcVeScroll[KNOB_MC].enabled = fEnabled;
   }

   public function SetHoScrollEnabled(fEnabled:Boolean):Void
   {
      m_mcHoScroll[SCROLL_BUTTON_1_MC].enabled = fEnabled;
	  m_mcHoScroll[SCROLL_BUTTON_2_MC].enabled = fEnabled;
	  m_mcHoScroll[KNOB_MC].enabled = fEnabled;
   }

   /********************************************************************************
   * sLinkage -> Linkage to Horizontal Scroll Bar Graphic
   * With 3 Nested MCs with Instances "Body_MC", "Btn1_MC", "Btn2_MC", "Knob_MC"
   * Extra: 3 Nested MCs in "Knob_MC" for elongation purposes
   * With Instance names of "KnobBody_MC", "Edge1_MC", "Edge2_MC"
   ********************************************************************************/
   public function setHoScroller(sLinkage:String):MovieClip
   {
      trace("ScrollerWindow::setVeScroller(" + sLinkage + ")");
	  var nDepth:Number = m_mcHolder.getNextHighestDepth();
	  var mcBtnLeft:MovieClip = null;
	  var mcBtnRight:MovieClip = null;
	  m_mcHoScroll = m_mcHolder.attachMovie(sLinkage, sLinkage, nDepth);
	  m_mcHoScroll._x = 0;
	  m_mcHoScroll._y = m_nHeight;
	  mcBtnLeft = m_mcHoScroll[SCROLL_BUTTON_1_MC];
	  mcBtnRight = m_mcHoScroll[SCROLL_BUTTON_2_MC];
	  m_mcHoScroll[KNOB_MC].onPress = Delegate.create(this, onHoKnobPress);
	  mcBtnLeft.onPress = Delegate.create(this, onHoBtnLeftPress);
	  mcBtnRight.onPress = Delegate.create(this, onHoBtnRightPress);
	  mcBtnLeft.onRelease = Delegate.create(this, clearPressTimer);
	  mcBtnLeft.onDragOut = Delegate.create(this, clearPressTimer);
	  mcBtnRight.onRelease = Delegate.create(this, clearPressTimer);
	  mcBtnRight.onDragOut = Delegate.create(this, clearPressTimer);
	  updateHoScrollerLength(true);
	  return m_mcHoScroll;
   }

   public function updateVeScrollerLength(fResetPosition:Boolean):Void
   {
      trace("ScrollerWindow::updateVeScrollerLength");
      var mcScrollBody:MovieClip = m_mcVeScroll[SCROLL_BAR_BODY_MC];
	  var mcKnob:MovieClip = m_mcVeScroll[KNOB_MC];
	  var mcBody:MovieClip = mcKnob[KNOB_BODY_MC];
	  var mcTopEdge:MovieClip = mcKnob[KNOB_EDGE_1_MC];
	  var mcBottomEdge:MovieClip = mcKnob[KNOB_EDGE_2_MC];
	  var nScrollBodyHeight:Number = mcScrollBody._height;
	  var nKnobHeight:Number = m_nHeight / m_nContentHeight * nScrollBodyHeight;
      var nTopEdgeHeight:Number = mcTopEdge._height;
	  if(nKnobHeight > nScrollBodyHeight) nKnobHeight = nScrollBodyHeight;
	  var nKnobBodyHeight:Number = nKnobHeight - (nTopEdgeHeight + mcBottomEdge._height);
	  if(true == fResetPosition) mcKnob._y = mcScrollBody._y;
	  mcTopEdge._y = 0;
	  if(nKnobBodyHeight < MINIMUM_KNOB_BODY_LENGTH) nKnobBodyHeight = MINIMUM_KNOB_BODY_LENGTH;
	  //new Tween(mcBody, "_height", Strong.easeOut, mcBody._height, nKnobBodyHeight, m_nEaseInTweenTime, true);
	  //new Tween(mcBottomEdge, "_y", Strong.easeOut, mcBottomEdge._y, nTopEdgeHeight + nKnobBodyHeight, m_nEaseInTweenTime, true);
	  mcBody._height = nKnobBodyHeight;
	  mcBottomEdge._y = nTopEdgeHeight + nKnobBodyHeight;
	  updateVeContentPosition();
   }

   public function updateHoScrollerLength(fResetPosition:Boolean):Void
   {
      trace("ScrollerWindow::updateHoScrollerLength");
      var mcScrollBody:MovieClip = m_mcHoScroll[SCROLL_BAR_BODY_MC];
      var mcKnob:MovieClip = m_mcHoScroll[KNOB_MC];
	  var mcBody:MovieClip = mcKnob[KNOB_BODY_MC];
	  var mcLeftEdge:MovieClip = mcKnob[KNOB_EDGE_1_MC];
	  var mcRightEdge:MovieClip = mcKnob[KNOB_EDGE_2_MC];
	  var nScrollBodyWidth:Number = mcScrollBody._width;
	  var nKnobWidth:Number = m_nWidth / m_nContentWidth * nScrollBodyWidth;
      var nLeftEdgeWidth:Number = mcLeftEdge._width;
	  if(nKnobWidth > nScrollBodyWidth) nKnobWidth = nScrollBodyWidth;
	  var nKnobBodyWidth:Number = nKnobWidth - (nLeftEdgeWidth + mcRightEdge._width);
	  if(true == fResetPosition) mcKnob._x = mcScrollBody._x;
	  mcLeftEdge._x = 0;
	  if(nKnobBodyWidth < MINIMUM_KNOB_BODY_LENGTH) nKnobBodyWidth = MINIMUM_KNOB_BODY_LENGTH;
	  //new Tween(mcBody, "_width", Strong.easeOut, mcBody._width, nKnobBodyWidth, m_nEaseInTweenTime, true);
	  //new Tween(mcRightEdge, "_x", Strong.easeOut, mcRightEdge._x, nLeftEdgeWidth + nKnobBodyWidth, m_nEaseInTweenTime, true);
	  mcBody._width = nKnobBodyWidth;
	  mcRightEdge._x = nLeftEdgeWidth + nKnobBodyWidth;
	  updateHoContentPosition();
   }

   public function updateVeContentPosition(fTween:Boolean):Void
   {
      trace("ScrollerWindow::updateVeContentPosition(" + fTween + ")");
      fTween = ((m_nEaseInTweenTime > 0) && (true != fTween) && (!m_fKnobDrag));
	  var mcKnob:MovieClip = m_mcVeScroll[KNOB_MC];
      var mcBody:MovieClip = m_mcVeScroll[SCROLL_BAR_BODY_MC];
	  var nFreePlayKnob:Number = mcBody._height - mcKnob._height;
	  var nFreePlayContent = m_nContentHeight - m_nHeight;
	  var nPercScroll:Number = (mcBody._y + nFreePlayKnob - mcKnob._y) / nFreePlayKnob;
	  var nY:Number = m_nContentY + m_nHeight + ((m_nContentHeight - m_nHeight) * nPercScroll) - m_nContentHeight;
	  m_nVeScrollPerc = Math.round((1 - nPercScroll) * 100);
	  if(m_oListener.onVeScroll != null) m_oListener.onVeScroll.call(this);
	  if(undefined != m_cTween) m_cTween.stopEnterFrame();
	  if(fTween == true) m_cTween = new Tween(m_mcContent, "_y", Strong.easeOut, m_mcContent._y, nY, m_nEaseInTweenTime, true);
      else m_mcContent._y = nY;
   }

   public function updateHoContentPosition(fTween:Boolean):Void
   {
      trace("ScrollerWindow::updateHoContentPosition(" + fTween + ")");
      fTween = ((m_nEaseInTweenTime > 0) && (true != fTween) && (!m_fKnobDrag));
	  var mcKnob:MovieClip = m_mcHoScroll[KNOB_MC];
      var mcBody:MovieClip = m_mcHoScroll[SCROLL_BAR_BODY_MC];
	  var nFreePlayKnob:Number = mcBody._width - mcKnob._width;
	  var nFreePlayContent = m_nContentWidth - m_nWidth;
	  var nPercScroll:Number = (mcBody._x + nFreePlayKnob - mcKnob._x) / nFreePlayKnob;
	  var nX:Number = m_nContentX + m_nWidth + ((m_nContentWidth - m_nWidth) * nPercScroll) - m_nContentWidth;
	  m_nHoScrollPerc = Math.round((1 - nPercScroll) * 100);
	  if(m_oListener.onHoScroll != null) m_oListener.onHoScroll.call(this);
	  if(undefined != m_cTween) m_cTween.stopEnterFrame();
	  if(fTween == true) m_cTween = new Tween(m_mcContent, "_x", Strong.easeOut, m_mcContent._x, nX, m_nEaseInTweenTime, true);
      else m_mcContent._x = nX;
   }

   public function updateVeScrollerKnobPosition(Void):Void
   {
      trace("ScrollerWindow::updateVeScrollerKnobPosition");
	  var mcKnob:MovieClip = m_mcVeScroll[KNOB_MC];
      var mcBody:MovieClip = m_mcVeScroll[SCROLL_BAR_BODY_MC];
	  var nPercKnobY:Number = -m_mcContent._y / (m_nContentHeight - m_nHeight);
	  var nFreePlayKnob:Number = mcBody._height - mcKnob._height;
	  mcKnob._y = mcBody._y + (nFreePlayKnob * nPercKnobY);
   }

   public function updateHoScrollerKnobPosition(Void):Void
   {
      trace("ScrollerWindow::updateHoScrollerKnobPosition");
      var mcKnob:MovieClip = m_mcHoScroll[KNOB_MC];
      var mcBody:MovieClip = m_mcHoScroll[SCROLL_BAR_BODY_MC];
	  var nPercKnobX:Number = m_mcContent._x / (m_nContentWidth - m_nWidth);
	  var nFreePlayKnob:Number = mcBody._width - mcKnob._width;
	  mcKnob._x = mcBody._x - (nFreePlayKnob * nPercKnobX);
   }

   private function onVeKnobPress(Void):Void
   {
      trace("ScrollerWindow::onVeKnobPress");
      var mcKnob:MovieClip = m_mcVeScroll[KNOB_MC];
      var mcBody:MovieClip = m_mcVeScroll[SCROLL_BAR_BODY_MC];
      var nX:Number = mcKnob._x;
      var nY:Number = mcBody._y;
      startDrag(mcKnob, false, nX, nY, nX, nY + mcBody._height - mcKnob._height);
	  setScrollerDragHandlers(mcKnob, updateVeContentPosition, onVeKnobRelease);
	  m_oListener["onKnobPress"].call(this);
   }

   private function onHoKnobPress(Void):Void
   {
      trace("ScrollerWindow::onHoKnobPress");
      var mcKnob:MovieClip = m_mcHoScroll[KNOB_MC];
      var mcBody:MovieClip = m_mcHoScroll[SCROLL_BAR_BODY_MC];
      var nX:Number = mcBody._x;
      var nY:Number = mcKnob._y;
      startDrag(mcKnob, false, nX, nY, nX + mcBody._width - mcKnob._width, nY);
	  setScrollerDragHandlers(mcKnob, updateHoContentPosition, onHoKnobRelease);
   }

   private function onVeBtnUpPress(fLongPress:Boolean):Void
   {
      trace("ScrollerWindow::onVeBtnUpPress");
	  var mcBody:MovieClip = m_mcVeScroll[SCROLL_BAR_BODY_MC];
	  var mcKnob:MovieClip = m_mcVeScroll[KNOB_MC];
	  var nBodyY:Number = mcBody._y;
	  var nY:Number = mcKnob._y - (mcKnob._height * PERCENT_SCROLL_INCREMENT);
	  if(nY < nBodyY) nY = nBodyY;
	  else startPressTimer(onVeBtnUpPress, fLongPress);
	  mcKnob._y = nY;
	  updateVeContentPosition(fLongPress);
   }

   private function onVeBtnDownPress(fLongPress:Boolean):Void
   {
      trace("ScrollerWindow::onVeBtnDownPress");
	  var mcBody:MovieClip = m_mcVeScroll[SCROLL_BAR_BODY_MC];
	  var mcKnob:MovieClip = m_mcVeScroll[KNOB_MC];
	  var nKnowHeight:Number = mcKnob._height;
	  var nBodyBottom:Number = mcBody._y + mcBody._height - nKnowHeight;
	  var nY:Number = mcKnob._y + (nKnowHeight * PERCENT_SCROLL_INCREMENT);
	  if(nY > nBodyBottom) nY = nBodyBottom;
	  else startPressTimer(onVeBtnDownPress, fLongPress);
	  mcKnob._y = nY;
	  updateVeContentPosition(fLongPress);
   }

   private function onHoBtnLeftPress(fLongPress:Boolean):Void
   {
      trace("ScrollerWindow::onHoBtnLeftPress");
      var mcBody:MovieClip = m_mcHoScroll[SCROLL_BAR_BODY_MC];
      var mcKnob:MovieClip = m_mcHoScroll[KNOB_MC];
      var nBodyX:Number = mcBody._x;
	  var nX:Number = mcKnob._x - (mcKnob._width * PERCENT_SCROLL_INCREMENT);
      if(nX < nBodyX) nX = nBodyX;
      else startPressTimer(onHoBtnLeftPress, fLongPress);
	  mcKnob._x = nX;
	  updateHoContentPosition(fLongPress);
   }

   private function onHoBtnRightPress(fLongPress:Boolean):Void
   {
      trace("ScrollerWindow::onHoBtnRightPress");
	  var mcBody:MovieClip = m_mcHoScroll[SCROLL_BAR_BODY_MC];
	  var mcKnob:MovieClip = m_mcHoScroll[KNOB_MC];
	  var nKnowWidth:Number = mcKnob._width;
	  var nBodyRightMost:Number = mcBody._x + mcBody._width - nKnowWidth;
	  var nX:Number = mcKnob._x + (nKnowWidth * PERCENT_SCROLL_INCREMENT);
	  if(nX > nBodyRightMost) nX = nBodyRightMost;
	  else startPressTimer(onHoBtnRightPress, fLongPress);
	  mcKnob._x = nX;
	  updateHoContentPosition(fLongPress);
   }

   private function startPressTimer(pfEvent:Function, fLongPress:Boolean)
   {
      trace("ScrollerWindow::startPressTimer");
      var nTime:Number = SCROLL_BUTTON_LONG_PRESS_DELAY_TIME
	  clearPressTimer();
	  if(true == fLongPress) nTime = SCROLL_KNOB_INCREMENT_TIME_ON_LONG_PRESS;
	  m_nPressTimerId = _global.setTimeout(Delegate.create(this, pfEvent), nTime, true);
   }

   private function clearPressTimer(Void):Void
   {
      trace("ScrollerWindow::clearPressTimer");
      if(m_nPressTimerId != null)
	  {
         clearInterval(m_nPressTimerId);
         m_nPressTimerId = null;
      }
   }

   private function setScrollerDragHandlers(mcKnob:MovieClip, pfUpdate:Function, pfRelease:Function):Void
   {
      trace("ScrollerWindow::setScrollerDragHandlers(" + mcKnob + ")");
      m_fKnobDrag = true;
	  mcKnob.onMouseMove = Delegate.create(this, pfUpdate);
      mcKnob.onRelease = Delegate.create(this, pfRelease);
      mcKnob.onReleaseOutside = Delegate.create(this, pfRelease);
   }

   private function deleteScrollerDragHandlers(mcKnob:MovieClip):Void
   {
      trace("ScrollerWindow::deleteScrollerDragHandlers(" + mcKnob + ")");
	  m_fKnobDrag = false;
      delete mcKnob.onRelease;
      delete mcKnob.onReleaseOutside;
      delete mcKnob.onMouseMove;
	  mcKnob.stopDrag();
   }

   private function onVeKnobRelease(Void):Void {m_oListener["onKnobRelease"].call(this); deleteScrollerDragHandlers(m_mcVeScroll[KNOB_MC]);}
   private function onHoKnobRelease(Void):Void {deleteScrollerDragHandlers(m_mcHoScroll[KNOB_MC]);}

   public function addListener(oListener:Object):Void {m_oListener = oListener;}
   public function setVeContentProps(nY:Number, nHeight:Number):Void {m_nContentHeight = nHeight; m_nContentY = nY; updateVeScrollerLength(true); m_mcContent._y = nY;}
   public function setHoContentProps(nX:Number, nWidth:Number):Void {m_nContentWidth = nWidth; m_nContentX = nX; updateHoScrollerLength(true); m_mcContent._x = nX;}
   public function setEaseInTweenTime(nSeconds:Number):Void {m_nEaseInTweenTime = nSeconds;}
   public function setHoScrollerPosition(nX:Number, nY:Number):Void {m_mcHoScroll._x = nX; m_mcHoScroll._y = nY;}
   public function setVeScrollerPosition(nX:Number, nY:Number):Void {m_mcVeScroll._x = nX; m_mcVeScroll._y = nY;}
   public function setWidth(nWidth:Number):Void {m_nWidth = nWidth;}
   public function setHeight(nHeight:Number):Void {m_nHeight = nHeight;}
   public function getWidth(Void):Number {return m_nWidth;}
   public function getHeight(Void):Number {return m_nHeight;}
   public function getVePercScroll(Void):Number {return m_nVeScrollPerc;}
   public function getHoPercScroll(Void):Number {return m_nHoScrollPerc;}
   public function getContainer(Void):MovieClip {return m_mcHolder;}
   public function getHoScrollBar(Void):MovieClip {return m_mcHoScroll;}
   public function getVeScrollBar(Void):MovieClip {return m_mcVeScroll;}
   public function getContent():MovieClip {return m_mcContent;}

   public function destroy(Void):Void
   {
      m_cTween.stopEnterFrame();
	  m_mcContent.removeMovieClip();
	  m_mcMask.removeMovieClip();
	  m_mcVeScroll.removeMovieClip();
	  m_mcHoScroll.removeMovieClip();
	  m_mcHolder.removeMovieClip();
      delete m_oListener;
	  delete m_cTween;
   }
}