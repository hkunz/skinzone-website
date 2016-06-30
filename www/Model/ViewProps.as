class ViewProps
{
   public var nViewId:Number;
   public var sViewName:String;

   public function ViewProps(nId:Number, sName:String)
   {
      trace("ViewProps::ViewProps(" + nId + "," + sName + ")");
	  nViewId = nId;
	  sViewName = sName;
   }
}