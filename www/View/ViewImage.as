import mx.transitions.*;
import mx.transitions.easing.*;

class ViewImage
{
   private var m_pView:Object;
   private var m_cLoadAnimation:LoadAnimation;
   private var m_aImageContent:Array;
   private var m_cLoader:ContentLoader;
   private var m_mcHolder:MovieClip;
   private var m_mcImages:MovieClip;
   private var m_pfNextImage:Function;
   private var m_pfPrevImage:Function;
   private var m_pfViewExit:Function;
   private var m_nDepth:Number;

   public function ViewImage(pView:Object, mcHolder:MovieClip)
   {
      m_pView = pView;
      m_mcHolder = mcHolder;
      m_mcImages = m_mcHolder.createEmptyMovieClip("Img_MC", 0);
	  var mcLoad:MovieClip = m_mcHolder.createEmptyMovieClip("LoadAnim_MC", 1);
      m_cLoadAnimation = new LoadAnimation(mcLoad);
      m_cLoadAnimation.centerLoadClip();
      m_aImageContent = new Array();
	  m_nDepth = 0;
   }

   public function loadImage(sImagePath:String):Void
   {
      m_cLoadAnimation.StartAnimation();
      var oImgData:Object = new Object();
      var nDepth:Number = ++m_nDepth; //m_mcImages.getNextHighestDepth();
      var mcImage:MovieClip = m_mcImages.createEmptyMovieClip("Img_MC" + nDepth, nDepth);
	  var nImages:Number = m_aImageContent.length;
	  if(nImages > 0) mcImage.swapDepths(m_aImageContent[nImages - 1]["Image_MC"]);
	  mcImage._visible = false;
      mcImage.createEmptyMovieClip("PhotoBg_MC", 0);
	  mcImage.createEmptyMovieClip("Photo_MC", 1);
      var mcControl:MovieClip = mcImage.attachMovie("ImageControl_MC", "Control_MC", 2);
      var mcDescBg:MovieClip = mcImage.attachMovie("PhotoDescBg_MC", "DescBg_MC", 3);
	  var mcLabel:MovieClip = mcImage.attachMovie("PhotoDescription_MC", "Text_MC", 4);
	  var txtLabel:TextField = mcLabel["Label_TXT"];
	  m_cLoader = new ContentLoader(mcImage["Photo_MC"]);
      m_cLoader.SetLoadEvent(Fxn.FunctionProxy(this, onImageLoad, [oImgData]));
	  m_cLoader.LoadFile(sImagePath);
      oImgData["Image_MC"] = mcImage;
	  oImgData["Control_MC"] = mcControl;
      oImgData["cLoader"] = m_cLoader;
      oImgData["fLoaded"] = false;
	  oImgData["cGlow"] = null;
	  oImgData["Label_TXT"] = txtLabel;
	  txtLabel.text = "";
	  m_aImageContent.push(oImgData);
   }

   private function loadNextImage(oImgData:Object):Void
   {
      m_pfNextImage.call(this);
      disableControl(oImgData);
   }

   private function loadPrevImage(oImgData:Object):Void
   {
      m_pfPrevImage.call(this);
      disableControl(oImgData);
   }

   private function disableControl(oImgData:Object):Void
   {
      var mcControl:MovieClip = oImgData["Control_MC"];
      delete mcControl["NextBtn_MC"].onPress;
	  delete mcControl["PrevBtn_MC"].onPress;
   }

   private function onImageLoad(oImgData:Object):Void
   {
      oImgData["fLoaded"] = true;
      var mcImage:MovieClip = oImgData["Image_MC"];
      var mcControl:MovieClip = oImgData["Control_MC"];
      var txtLabel:TextField = oImgData["Label_TXT"];
      var mcDescBg:MovieClip = oImgData["Image_MC"]["DescBg_MC"];
	  var sLabelText:String = m_pView.getImageLabel();
	  mcControl["NextBtn_MC"].onPress = Fxn.FunctionProxy(this, loadNextImage, [oImgData]);
      mcControl["PrevBtn_MC"].onPress = Fxn.FunctionProxy(this, loadPrevImage, [oImgData]);
	  mcControl["ExBtn_MC"].onPress = Fxn.FunctionProxy(this, exitImageView, [oImgData]);
      m_cLoadAnimation.StopAnimation();
	  var nW:Number = 710;
	  var nH:Number = 460;
      var nMargin:Number = 35;
	  var mcBg:MovieClip = mcImage["PhotoBg_MC"].attachMovie("WhitePhotoBg_MC","Bg_MC",0);
      var mcImg:MovieClip = mcImage["Photo_MC"];

      if(mcImg._width == 0 || mcImg._height == 0)
	  {
         mcImg = mcImage["PhotoBg_MC"].attachMovie("BlankImage_MC", "Blank_MC", 1);
	  }
	  if(mcImg._width < nW) nW = mcImg._width;
	  if(mcImg._height < nH) nH = mcImg._height;
	  
	  setFitProps(mcImg, mcImg._width, mcImg._height, nW, nH, nMargin);
	  nW = 710;
	  nH = 460;
      mcImage._rotation = 0;
	  //setFitProps(mcBg, mcImg._width, mcImg._height, nW, nH, 0);
      mcBg._width = mcImg._width + nMargin;
	  mcBg._height = mcImg._height + nMargin;
	  mcDescBg._x = mcImg._x;
	  mcDescBg._width = mcImg._width;
	  mcDescBg._alpha = 30;
	  mcControl._x = (mcBg._x + mcBg._width - mcControl._width) + 1;
	  mcControl._y += 1;
	  txtLabel._x = mcImg._x + 5;
	  txtLabel._width = mcImg._width - 10;
	  InitPhotoLabel(txtLabel, sLabelText, mcImg._height);
	  mcDescBg._y = txtLabel._y;
	  mcDescBg._height = txtLabel._height - 2; //2 = Text fields have a 2-pixel-wide gutter around them, so the value of textFieldHeight is equal the value of height
	  mcImage._x = 62 + (nW - mcImage._width)/2;
	  mcImage._y = 120 + (nH - mcImage._height)/2;
	  var cGlow:GlowHighlight = new GlowHighlight(mcImage);
	  cGlow.SetColor(0x333333);
	  cGlow.SetBlur(20);
      cGlow.AddFilter();
	  oImgData["cGlow"] = cGlow;
      MoveIntoView(oImgData);
      if(m_aImageContent.length > 1)
	  {
         var aImgItems:Array = m_aImageContent.splice(0, 1);
         var oImgData:Object = aImgItems[0];
		 MoveOutView(oImgData);
	  }
   }

   private function InitPhotoLabel(txtLabel:TextField, sText:String, nMaxH:Number):Void
   {
      var cTxtFmt:TextFormat = txtLabel.getTextFormat();
      var oExtent:Object = cTxtFmt.getTextExtent(sText, txtLabel._width);
	  var nH:Number = oExtent["textFieldHeight"];
      txtLabel._height = nH + 5;
      txtLabel._y = nMaxH - nH + 15;
      txtLabel.text = sText;
   }

   private function MoveIntoView(oImgData:Object):Void
   {
	  var nTime:Number = 1;
	  var mcImage:MovieClip = oImgData["Image_MC"];
	  var cTw1:Tween = new Tween(mcImage, "_x", Strong.easeOut, mcImage._x + 30, mcImage._x, nTime, true);
      //var cTw2:Tween = new Tween(mcImage, "_y", Strong.easeOut, 0, mcImage._y, nTime, true);
	  var cTw3:Tween = new Tween(mcImage, "_xscale", Strong.easeOut, 90, mcImage._xscale, nTime, true);
	  var cTw4:Tween = new Tween(mcImage, "_yscale", Strong.easeOut, 90, mcImage._yscale, nTime, true);
	  //var cTw5:Tween = new Tween(mcImage, "_rotation", Strong.easeOut, 10, mcImage._rotation, nTime, true);
	  var cTw6:Tween = new Tween(mcImage, "_alpha", Strong.easeOut, 20, 100, nTime, true);
	  mcImage._visible = true;
   }

   private function MoveOutView(oImgData:Object):Void
   {
      oImgData["cGlow"].destroy();
      var nTime:Number = 2;
	  var mcImage:MovieClip = oImgData["Image_MC"];
      var nRanX:Number = -50 + Fxn.RandomNumber() * 400;
	  var nRanY:Number = -100 + Fxn.RandomNumber() * 350;
      var nRot:Number = -80 + Fxn.RandomNumber() * 160;
      var cTw1:Tween = new Tween(mcImage, "_x", Strong.easeOut, mcImage._x, mcImage._x + nRanX, nTime, true);
      var cTw2:Tween = new Tween(mcImage, "_y", Strong.easeOut, mcImage._y, mcImage._y + nRanY, nTime, true);
	  var cTw3:Tween = new Tween(mcImage, "_xscale", Strong.easeOut, mcImage._xscale, 20, nTime, true);
	  var cTw4:Tween = new Tween(mcImage, "_yscale", Strong.easeOut, mcImage._yscale, 20, nTime, true);
	  var cTw5:Tween = new Tween(mcImage, "_rotation", Strong.easeOut, mcImage._rotation, mcImage._rotation + nRot, nTime, true);
	  var cTw6:Tween = new Tween(mcImage, "_alpha", Strong.easeOut, mcImage._alpha, 0, nTime, true);
	  cTw5.onMotionFinished = Fxn.FunctionProxy(this, unloadImageData, [oImgData]);
   }

   private function unloadImageData(oImgData:Object):Void
   {
      var mcImg:MovieClip = oImgData["Image_MC"];
	  oImgData["cLoader"].destroy();
	  oImgData["cGlow"].destroy();
	  delete oImgData["cLoader"];
	  delete oImgData["cGlow"];
      mcImg._alpha = 0;
      mcImg.removeMovieClip();
   }

   public function exitImageView(fQuickExit:Boolean):Void
   {
      disableControl(oImgData);
      var aImgItems:Array = m_aImageContent.splice(0, 1);
      var oImgData:Object = aImgItems[0];
	  MoveOutView(oImgData);
	  m_cLoader.destroy();
	  m_cLoadAnimation.destroy();
	  delete m_cLoadAnimation;
      delete m_aImageContent;
	  delete m_cLoader;
	  m_pfViewExit.apply(this, [fQuickExit]);
   }

   private function setFitProps(mc:MovieClip, nW:Number, nH:Number, nFitW:Number, nFitH:Number, nMargin:Number):Void
   {
      var oDim:Object = Fxn.getMinFitDimensions(nW, nH, nFitW-nMargin, nFitH-nMargin);
	  mc._width = oDim["nW"];
	  mc._height = oDim["nH"];
      mc._x = nMargin*0.5;
	  mc._y = nMargin*0.5;
   }
   /*
   private function getMinFitDimensions(nW:Number, nH:Number, nFitW:Number, nFitH:Number):Object
   {
	  var nRatioW:Number = nW / nFitW;
	  var nRatioH:Number = nH / nFitH;
	  if(nRatioW > nRatioH) return {nW:nFitW, nH:nH*nFitW/nW};
      else return {nW:nW*nFitH/nH, nH:nFitH};
   }*/

   public function addNextImageListener(pfNextImage:Function) {m_pfNextImage = pfNextImage;}
   public function addPrevImageListener(pfPrevImage:Function) {m_pfPrevImage = pfPrevImage;}
   public function addExitViewListener(pfViewExit:Function) {m_pfViewExit = pfViewExit;}

   public function destroy():Void
   {
      m_mcHolder.removeMovieClip();
	  m_cLoadAnimation.destroy();
	  delete m_cLoadAnimation;
	  delete m_pfNextImage;
	  delete m_pfPrevImage;
	  delete m_pfViewExit;
	  delete m_aImageContent;
   }
}