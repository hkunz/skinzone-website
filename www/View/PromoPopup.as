import mx.transitions.*;
import mx.transitions.easing.*;

class PromoPopup
{
   private var m_sLoadPath:String;
   private var m_mcHolder:MovieClip;
   private var m_mcBox:MovieClip;
   private var m_mcPromoPic:MovieClip;
   private var m_pfLoadEvent:Function;
   private var m_pfExBtnHandler:Function;
   private var m_cLoadAnimation:LoadAnimation;

   public function PromoPopup(mcHolder:MovieClip, pfLoad:Function)
   {
      m_mcHolder = mcHolder;
      m_pfLoadEvent = pfLoad;
      m_mcHolder._alpha = 95;
   }

   public function setLoadPath(sLoadPath):Void {m_sLoadPath = sLoadPath;}

   public function createPopup():Void
   {
	  var cLoader:ContentLoader = null;
      var mcLoading:MovieClip = m_mcHolder.createEmptyMovieClip("Loading_MC", 1);
	  m_mcBox = m_mcHolder.attachMovie("PromoPopupBg_MC", "Box_MC", 0);
      m_mcBox._visible = false;
	  m_mcBox.onExitAnimComplete = Fxn.FunctionProxy(this, removePopup);
	  m_mcBox.onStartAnimComplete = Fxn.FunctionProxy(this, onStartAnimComplete);
      m_mcPromoPic = m_mcBox["PromoPic_MC"];
      m_mcPromoPic.createEmptyMovieClip("Img1_MC", 0);
      m_mcPromoPic.createEmptyMovieClip("Img2_MC", 1);
      cLoader = new ContentLoader(m_mcPromoPic["Img1_MC"]);
	  m_mcPromoPic._alpha = 0;
	  cLoader.SetLoadEvent(Fxn.FunctionProxy(this, onPromoGraphicLoad));
	  cLoader.LoadFile(m_sLoadPath);
	  m_cLoadAnimation = new LoadAnimation(mcLoading);
	  mcLoading._x = Constant.STAGE_WIDTH_HALF;
	  mcLoading._y = Constant.STAGE_HEIGHT_HALF;
	  m_cLoadAnimation.StartAnimation();
   }

   public function setPosition(nX:Number, nY:Number):Void
   {
      m_mcBox._x = nX; //125;
	  m_mcBox._y = nY; //135;
   }

   private function onStartAnimComplete():Void
   {
      var mcExBtn:MovieClip = m_mcBox["ExBtn_MC"];
	  var cButton:GenericButton = new GenericButton(mcExBtn);
      cButton.SetButtonReleaseEvent(Fxn.FunctionProxy(this, onPopupExPress, [cButton]));
   }

   public function stopLoadingClip():Void
   {
      m_cLoadAnimation.StopAnimation();
   }

   private function onPopupExPress(cButton:GenericButton):Void
   {
      m_pfExBtnHandler.apply(this);
      cButton.destroy();
      exitPopup();
   }

   public function exitPopup():Void
   {
      m_mcBox.gotoAndPlay("exit");
   }

   public function onPromoGraphicLoad(fSuccess:Boolean):Void
   {
      var nBoxWidth:Number = 492; //500;
      var nBoxHeight:Number = 302;
      var oDim:Object = Fxn.getMinFitDimensions(m_mcPromoPic._width, m_mcPromoPic._height, nBoxWidth, nBoxHeight);

	  if(fSuccess == false) {m_mcPromoPic["Img2_MC"].attachMovie("BlankImage_MC", "Broken_MC", 10);}

	  if(m_mcPromoPic._width > oDim["nW"])
	  {
	     m_mcPromoPic._width = oDim["nW"];
         m_mcPromoPic._height = oDim["nH"];
	  }
      m_mcPromoPic._x = (nBoxWidth - m_mcPromoPic._width) * 0.5;
      m_mcPromoPic._y = (m_mcBox._height - m_mcPromoPic._height) * 0.5;
      m_pfLoadEvent.apply(this, [fSuccess]);
	  new Tween(m_mcPromoPic, "_alpha", Strong.easeOut, m_mcPromoPic._alpha, 100, 0.5, true);
      stopLoadingClip();
	  m_mcBox.play();
	  m_mcBox._visible = true;
      m_mcPromoPic._alpha = 100;
   }

   public function removePopup():Void
   {
      destroy();
   }

   public function addExBtnPressHandler(pfHandler:Function):Void
   {
      m_pfExBtnHandler = pfHandler;
   }

   public function destroy():Void
   {
      delete m_pfLoadEvent;
	  delete m_pfExBtnHandler;
      m_mcHolder.removeMovieClip();
   }
}