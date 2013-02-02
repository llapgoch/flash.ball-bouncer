package  {
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.Event;
	
	public class Block extends BaseObject {
		var origX:Number;
		var origY:Number;
		var moveDistance:Number = 80;
		var yDirection:int;
		var yMove:Number = 0;
		var minYMove:Number = 0;
		var maxYMove:Number = 4;
		
		public function Block(){
			
		}
		
		public function getYVelocity():Number{
			return yDirection * yMove;
		}
		
		public override function init(world:World):void{
			super.init(world);
			yMove = Math.round(Math.random() * maxYMove);
			yDirection = Math.round(Math.random() * 2) == 1 ? -1 : 1;
			
			// constructor code
			origX = this.x;
			origY = this.y;
			
			this.addEventListener(Event.ENTER_FRAME, moveBlock);
		}
		
		public function moveBlock(ev:Event = null):void{
			
			var dist:Number = yDirection * yMove;
			
			this.y += dist;
			
			if((this.y >= origY + (moveDistance / 2) && yDirection == 1)){
				yDirection *= -1;
			}
			
			if(this.y <= origY - (moveDistance / 2) && yDirection == -1){
				this.y = origY - (moveDistance / 2);
				yDirection *= -1;
			}
			
		}
		
		public function hit(obj:MovieClip, point:Point):Boolean{
			if(leftBound(obj, point) && rightBound(obj, point) && (topBound(obj, point) && bottomBound(obj, point))){
				return true;
			}
			return false;
		}
				
		public function hitLeft(obj:MovieClip, point:Point):Boolean{
			return (topBound(obj, point) && bottomBound(obj, point)) && point.x + (obj.width - 5) < this.x && point.x + obj.width > this.x;
		}
		
		public function hitRight(obj:MovieClip, point:Point):Boolean{
			return (topBound(obj, point) && bottomBound(obj, point)) && point.x < this.x + width && point.x + 5 > this.x + this.width;
		}
		
		public function hitTop(obj:MovieClip, point:Point):Boolean{
			return (leftBound(obj, point) && rightBound(obj, point)) && (point.y + obj.height > this.y && point.y + (obj.height - 5) < this.y);
		}
		
		public function hitBottom(obj:MovieClip, point:Point):Boolean{
			return (leftBound(obj, point) && rightBound(obj, point)) && point.y + obj.height > this.y + this.height && point.y + 5 < (this.y + this.height);
		}
		
		/* Check all of the bounds as being greater than the bounds of the block, so an object can 'roll' */
		
		public function leftBound(obj:MovieClip, point:Point):Boolean{
			return (point.x + obj.width > this.x);		
		}
		
		public function rightBound(obj:MovieClip, point:Point):Boolean{
			return (point.x < this.x + this.width);
		}
		
		public function topBound(obj:MovieClip, point:Point):Boolean{
			return point.y + obj.height > this.y;
		}
		
		public function bottomBound(obj:MovieClip, point:Point):Boolean{
			return point.y < this.y + this.height;
		}

	}
	
}
