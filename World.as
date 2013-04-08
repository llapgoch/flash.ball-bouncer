package  {
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class World extends MovieClip {
		protected var gravity:Number = 4;
		protected var ceiling:Number = 0;
		protected var ground:Number = 400;
		protected var groundFriction:Number = 0.9;
		protected var floorBounce:Number = 0.6;
		protected var wind:Number = 0;
		protected var objects:Vector.<BaseObject> = new Vector.<BaseObject>;
		protected var blocks:Array = [];
		protected var lines:Array = [];
		
		public function World() {
			// constructor code
		}
		
		public function addObject(object:BaseObject, loc:Point):void{
			objects.push(object);
			
			object.x = loc.x;
			object.y = loc.y;
			
			this.addChild(object);
			object.init(this);
			
			if(object is Block){
				blocks.push(object);
			}
			
			if(object is Line){
				lines.push(object);
			}
		}
		
		public function getLines():Array{
			return this.lines;
		}
		
		public function lineHitTest(obj:BaseObject, point:Point):HitObject{
			return null;
		}
		
		public function blockHitTest(obj:BaseObject, point:Point):HitObject{
			var hitObject = new HitObject();
			
			for each(var block in blocks){
				if(!block.hit(obj, point)){
					continue;
				}
				
				if(block.hitTop(obj, point)){
					hitObject.setHitObject(block);
					hitObject.addSide(HitObject.TOP);
				}
				
				if(block.hitBottom(obj, point)){
				   hitObject.setHitObject(block);
				   hitObject.addSide(HitObject.BOTTOM);
				}
				
				if(block.hitLeft(obj, point)){
				   hitObject.setHitObject(block);
				   hitObject.addSide(HitObject.LEFT);
				}
				
				if(block.hitRight(obj, point)){
					hitObject.setHitObject(block);
					hitObject.addSide(HitObject.RIGHT);
				}
				
				if(hitObject.getHitObject() !== null){
					return hitObject;
				}
			}
			
			return null;
		}
		
		public function getGravity():Number{
			return this.gravity;
		}
		
		public function getGround():Number{
			return this.ground;
		}
		
		public function getCeiling():Number{
			return this.ceiling;
		}
		
		public function getGroundFriction():Number{
			return this.groundFriction;
		}
		
		public function getFloorBounce():Number{
			return this.floorBounce;
		}
		
		public function getWind():Number{
			return this.wind;
		}

	}
	
}
