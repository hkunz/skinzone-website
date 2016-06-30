//Structure
class BubbleMenu
{
   public var sName:String;
   public var cArcTween:ArcTween;
   public var mcClip:MovieClip;
   public var mcBubble:MovieClip;
   public var mcText:MovieClip;
   public var nId:Number;
   public var nPosition:Number;
   public var nNxPosition:Number;
   public var cButton:BubbleMenuButton;
   public var nAngle:Number;

   public function BubbleMenu(_id:Number, _name:String, _pos:Number)
   {
      //BUG: _name cannot be received through constructor; it will return "SzRoot_MC"
      trace("BubbleMenu::BubbleMenu(" + _id + "," + _name + "," + _pos + ")");
      sName = _name;
	  nId = _id;
	  nPosition = _pos;
	  nNxPosition = _pos;
   }

   public function SetActive(Void):Void
   {

   }

   public function SetInactive(Void):Void
   {

   }

   public function destroy(Void):Void
   {
      trace("BubbleMenu::destroy");
	  mcClip = null;
      mcBubble = null;
      mcText = null;
	  cArcTween.destroy();
	  cButton.destroy();
	  delete cArcTween;
	  delete cButton;
   }
}