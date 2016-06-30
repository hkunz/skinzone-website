class Fxn
{
   static public function RoundOff(nValue:Number):Number {return Math.round(nValue);}
   static public function Abs(nValue:Number):Number {if(nValue < 0) nValue = -nValue; return nValue;}
   static public function Pow(nBase:Number, nPower:Number):Number {return Math.pow(nBase, nPower);}
   static public function Sqrt(nValue:Number):Number {return Math.sqrt(nValue);}
   static public function Sin(nAngle:Number):Number {return Math.sin(nAngle * Constant.RADIANS_PER_REVOLUTION);}
   static public function Cos(nAngle:Number):Number {return Math.cos(nAngle * Constant.RADIANS_PER_REVOLUTION);}
   static public function Tan(nAngle:Number):Number {return Math.tan(nAngle * Constant.RADIANS_PER_REVOLUTION);}
   static public function ArcSin(nRatio:Number):Number {return (Math.asin(nRatio)/Constant.RADIANS_PER_REVOLUTION);}
   static public function ArcCos(nRatio:Number):Number {return (Math.acos(nRatio)/Constant.RADIANS_PER_REVOLUTION);}
   static public function ArcTan(nRatio:Number):Number {return (Math.atan(nRatio)/Constant.RADIANS_PER_REVOLUTION);}
   static public function RandomNumber(Void):Number {return Math.random();}
   static public function RandomAngle(Void):Number {return RandomNumber() * Constant.FULL_REVOLUTION;}
   static public function GetNextHighestRootDepth(Void):Number {return _root.getNextHighestDepth();}

   static public function CreateRootMovieClip(sName:String, nDepth, nX:Number, nY:Number):MovieClip
   {
      var mcClipOnRoot:MovieClip = _root.createEmptyMovieClip(sName, nDepth);
      mcClipOnRoot._x = nX;
      mcClipOnRoot._y = nY;
      return mcClipOnRoot;
   }

   //Function Deprecated
   static public function AttachGraphic(mcParent:MovieClip, sLinkage:String, nDepth:Number, nX:Number, nY:Number):MovieClip
   {
      //Function Deprecated
	  var mc:MovieClip = mcParent.createEmptyMovieClip(sLinkage, nDepth);
	  mc.attachMovie(sLinkage, sLinkage, mc.getNextHighestDepth(), {_x:nX, _y:nY});
	  return mc;
   }

   static public function FunctionProxy(oTarget:Object, pfDelegate:Function, aParams:Array):Function
   {
      var pfWrapper:Function = function()
      {
         var oCalleeTarget:Object = arguments.callee.target;
         var pfCallee:Function = arguments.callee.func;
         var aParamsLength:Number = aParams.length;
         for( var i = 0; i < aParamsLength; i++ ) arguments[i] = aParams[i];
         pfCallee.apply(oCalleeTarget, arguments);
      };
      pfWrapper.target = oTarget;
      pfWrapper.func = pfDelegate;
      return pfWrapper;
   }

   static public function CenterClipToParent(mcClip:MovieClip, nAlpha:Number):Void
   {
      mcClip._x = -mcClip._width/2;
	  mcClip._y = -mcClip._height/2;
	  if(nAlpha == undefined) mcClip._alpha = 100;
	  else mcClip._alpha = nAlpha;
   }

   static public function getMinFitDimensions(nW:Number, nH:Number, nFitW:Number, nFitH:Number):Object
   {
	  var nRatioW:Number = nW / nFitW;
	  var nRatioH:Number = nH / nFitH;
	  if(nRatioW > nRatioH) return {nW:nFitW, nH:nH*nFitW/nW};
      else return {nW:nW*nFitH/nH, nH:nFitH};
   }

   static public function getMaxFitDimensions(nW:Number, nH:Number, nFitW:Number, nFitH:Number):Object
   {
	  var nRatioW:Number = nW / nFitW;
	  var nRatioH:Number = nH / nFitH;
	  if(nRatioW < nRatioH) return {nW:nFitW, nH:nH*nFitW/nW};
      else return {nW:nW*nFitH/nH, nH:nFitH};
   }

   static public function cloneArray(aCopy:Array):Array
   {
      var nLen:Number = aCopy.length;
      var aClone:Array = new Array();
      var nIndex:Number = 0;
      while(nIndex < nLen) aClone.push(aCopy[nIndex++]);
      return aClone;
   }

   static public function cloneObject(oCopy:Object):Object
   {
      var oClone:Object = new Object();
      for(var sProp:String in oCopy) oClone[sProp] = oCopy[sProp]
      return oClone;
   }

   //Send text box set with maximum dimensions and entire text
   static public function getTextExtent(txtMaxArea:TextField):Object
   {
      var oTextExtent:Object = new Object();
      var nRepeats:Number = 0;
      var sFinalText:String = "";
      var sText:String = txtMaxArea.text;
      var cFmt:TextFormat = txtMaxArea.getTextFormat();
      var oExtent:Object = cFmt.getTextExtent(sText, txtMaxArea._width);
      var nTextAreaHeight:Number = txtMaxArea._height;
      var nIndex:Number = 0;
	  var fExceeded:Boolean = true;
	  var nH:Number = 0;

      while (nH < nTextAreaHeight)
      {
         nIndex = sText.indexOf(" ") + 1; //Zero if no more spaces
         sFinalText += sText.substr(0, nIndex);
         sText = sText.slice(nIndex);
         oExtent = cFmt.getTextExtent(sFinalText, txtMaxArea._width);
         nH = oExtent["textFieldHeight"];
         if(nIndex == 0) {fExceeded = false; break;} //If no more spaces detected
      }
      if(false == fExceeded) oTextExtent["nIndex"] = txtMaxArea.text.length;
	  else oTextExtent["nIndex"] = (sFinalText.length - nIndex); //Subtract excess from loop
      oTextExtent["fExceeded"] = fExceeded;
      return oTextExtent;
   }

   static public function removeMovieClip(mc):Void
   {
      mc.removeMovieClip();
   }

   static public function ErrorTrace(sErrTxt:String):Void
   {
      if(sErrTxt != undefined) _root.ERROR_TRACE.text = sErrTxt;
   }

   static public function DebugTrace(sDbgTxt1:String, sDbgTxt2:String, sDbgTxt3:String):Void
   {
      if(sDbgTxt1 != undefined) _root.DEBUG_TRACE1.text = sDbgTxt1;
	  if(sDbgTxt2 != undefined)  _root.DEBUG_TRACE2.text = sDbgTxt2;
	  if(sDbgTxt3 != undefined)  _root.DEBUG_TRACE3.text = sDbgTxt3;
   }
}