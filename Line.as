package  {
	import com.davidpreece.util.NumFuncts;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Line extends BaseObject{
		protected var angle:Number = 0;
		protected var lineLength:Number = 100;
		protected var friction:Number = 0.85;
		protected var bounce:Number = 0.6;
		protected var minYMove:Number = 0;
		protected var maxYMove:Number = 1;
		protected var moveDistance:Number = 80;
		protected var origX:Number;
		protected var origY:Number;
		protected var yDirection:int;
		protected var yMove:Number = 0;
		protected var lineId:String = '';
		
		protected static var lastStartPoint:Point = new Point(0, 0);
		protected static var lastCreatedPoint:Point = new Point(0, 0);
		protected static var xOverlap:Number = 0;
		protected static var lineCounter:int = 0;

		public function Line(lineLength:Number, angle:Number = 0) {
			super();
			this.angle = angle;
			
			this.lineLength = lineLength;
		}
		
		public static function createLine(start:Point, end:Point, world:World = null):Line{
			// Calculate the distance between the two points
			var deltaY:Number = end.y - start.y;
			var deltaX:Number = end.x - start.x;
			var dist:Number = Math.sqrt(Math.pow(deltaX, 2) + Math.pow(deltaY, 2));
			var angle:Number = NumFuncts.radToDeg(Math.atan2(deltaY, deltaX));
			var line:Line = new Line(dist, angle);
			line.setLineId("line_" + lineCounter);
			
			lineCounter++;
			if(world){
				line.init(world);
				world.addObject(line, start);
			}
			
			lastCreatedPoint = end;
			lastStartPoint = start;
			lastCreatedPoint.x -= xOverlap;
			
			return line;
		}
		
		public function getTopPoint():Number{
			var startPoint:Point = new Point(this.x, this.y);
			var deg:Number = NumFuncts.degToRad(this.angle);
			var endY:Number = Math.sin(deg) * this.lineLength;
			
			return Math.min(startPoint.y, startPoint.y + endY);
		}
		
		public function getBottomPoint():Number{
			var startPoint:Point = new Point(this.x, this.y);
			var deg:Number = NumFuncts.degToRad(this.angle);
			var endY:Number = Math.sin(deg) * this.lineLength;
			
			return Math.max(startPoint.y, startPoint.y + endY);
		}
		
		public function getLeftPoint():Number{
			var startPoint:Point = new Point(this.x, this.y);
			var deg:Number = NumFuncts.degToRad(this.angle);
			var endX:Number = Math.cos(deg) * this.lineLength;
			
			return Math.min(startPoint.x, startPoint.x + endX);
		}
		
		public function getRightPoint():Number{
			var startPoint:Point = new Point(this.x, this.y);
			var deg:Number = NumFuncts.degToRad(this.angle);
			var endX:Number = Math.cos(deg) * this.lineLength;
			
			return Math.max(startPoint.x, startPoint.x + endX);
		}
		
		public function getLineId():String{
			return this.lineId;
		}
		
		public function setLineId(id:String){
			this.lineId = id;
		}
		
		public static function drawTo(end:Point, world:World):Line{
			return createLine(lastCreatedPoint, end, world);
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
			
			yMove = Math.round(Math.random() * maxYMove);
			yDirection = Math.round(Math.random() * 2) == 1 ? -1 : 1;
			
			// draw the line
			this.drawLine();
			
			this.addEventListener(Event.ENTER_FRAME, moveObject);
		}
		
		protected function drawLine(){
			this.graphics.clear();
			this.graphics.lineStyle(1, 0xFF0000, 1);
			
			var rad:Number = NumFuncts.degToRad(this.angle);
			var xPos:Number = Math.cos(rad) * lineLength;
			var yPos:Number = Math.sin(rad) * lineLength;
	
			this.graphics.moveTo(0,0);
			this.graphics.lineTo(xPos, yPos);
		
			// constructor code
			origX = this.x;
			origY = this.y;
		}
		
		public function moveObject(ev:Event = null):void{
			
			var dist:Number = yDirection * yMove;
			
//			this.x += dist;
//			this.y += dist;
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
