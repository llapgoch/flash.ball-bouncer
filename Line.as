package  {
	import flash.events.Event;
	import com.davidpreece.util.NumFuncts;
	
	public class Line extends BaseObject{
		protected var angle:Number = 0;
		protected var lineLength:Number = 100;
		protected var friction:Number = 0.95;
		protected var bounce:Number = 0.6;
		protected var minYMove:Number = 0;
		protected var maxYMove:Number = 4;
		protected var moveDistance:Number = 80;
		protected var origX:Number;
		protected var origY:Number;
		protected var yDirection:int;
		protected var yMove:Number = 0;

		public function Line(lineLength:Number, angle:Number = 0) {
			super();
			this.angle = angle;
			
			this.lineLength = lineLength;
		}
		
		public function getYVelocity():Number{
			return yDirection * yMove;
		}
		
		public function getAngle():Number{
			return this.angle;
		}
		
		public function getFriction():Number{
			return this.friction;
		}
		
		public function getBounce():Number{
			return this.bounce;
		}
		
		public function getLineLength():Number{
			return this.lineLength;
		}
		
		public override function init(world:World):void{
			super.init(world);
			
			// draw the line
			this.graphics.lineStyle(1, 0xFF0000, 1);
			
			var rad:Number = NumFuncts.degToRad(this.angle);
			var xPos:Number = Math.cos(rad) * lineLength;
			var yPos:Number = Math.sin(rad) * lineLength;
			
			this.graphics.lineTo(xPos, yPos);
			
			yMove = Math.round(Math.random() * maxYMove);
			yDirection = Math.round(Math.random() * 2) == 1 ? -1 : 1;
			
			// constructor code
			origX = this.x;
			origY = this.y;
			
			this.addEventListener(Event.ENTER_FRAME, moveObject);
		}
		
		public function moveObject(ev:Event = null):void{
			
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
		
		

	}
	
}
