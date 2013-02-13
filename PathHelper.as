package  {
	import flash.geom.Point;
	
	public class PathHelper {

		public function PathHelper() {
			
		}
		// Increments are the number of pixels on the route to space out.  Lower number = finer 
		public static function getPointsOnPath(center:Point, xVelocity:Number, yVelocity:Number, increments:Number = 1):Array{
			var endX:Number = center.x + xVelocity;
			var endY:Number = center.y + yVelocity;
			var dist:Number = Math.sqrt((xVelocity * xVelocity) + (yVelocity * yVelocity));
			var angle:Number = Math.atan2(yVelocity, xVelocity);
			
			var maxCount:Number = dist / increments;
			var points:Array = [];
			
			for(var a = 0; a <= maxCount; a++){
				var loc:Number = (dist / maxCount) * a;
				var nX:Number = Math.cos(angle) * loc;
				var nY:Number = Math.sin(angle) * loc;
				
				points.push(new Point(center.x + nX, center.y + nY));
			}
			
			points.push(new Point(endX, endY));
			
			return points;
		}
	}
	
}
