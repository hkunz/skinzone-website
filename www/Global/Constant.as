class Constant
{
   static public var STAGE_WIDTH:Number = Stage.width;
   static public var STAGE_HEIGHT:Number = Stage.height;
   static public var STAGE_WIDTH_HALF:Number = STAGE_WIDTH * 0.5;
   static public var STAGE_HEIGHT_HALF:Number = STAGE_HEIGHT * 0.5;
   static public var FRAME_RATE:Number = 20;
   static public var SECONDS_PER_FRAME:Number = 1 / FRAME_RATE;
   static public var MILLISECONDS_PER_FRAME:Number = SECONDS_PER_FRAME * 1000;
   static public var PI:Number = 3.1415926535897932384626433832795;
   static public var FULL_REVOLUTION:Number = 360;
   static public var HALF_REVOLUTION:Number = FULL_REVOLUTION * 0.5;
   static public var RADIANS_PER_REVOLUTION:Number = PI / HALF_REVOLUTION;
}