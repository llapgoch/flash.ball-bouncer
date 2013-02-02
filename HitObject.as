package  {
	
	public class HitObject {
		public static const TOP:String = "TOP";
		public static const BOTTOM:String = "BOTTOM";
		public static const LEFT:String = "LEFT";
		public static const RIGHT:String = "RIGHT";
		
		protected var sides:Array = [];
		protected var hitObject:BaseObject;
		
		public function HitObject() {
			// constructor code
		}
		
		public function hitTop():Boolean{
			return sides.indexOf(TOP) > -1;
		}
		
		public function hitBottom():Boolean{
			return sides.indexOf(BOTTOM) > -1;
		}
		
		public function hitLeft():Boolean{
			return sides.indexOf(LEFT) > -1;
		}
		
		public function hitRight():Boolean{
			return sides.indexOf(RIGHT) > -1;
		}
		
		public function addSide(side:String):void{
			sides.push(side);
		}
		
		public function getSides():Array{
			return sides;
		}
		
		public function setHitObject(obj:BaseObject):void{
			this.hitObject = obj;
		}
		
		public function getHitObject():BaseObject{
			return hitObject;
		}

	}
	
}
