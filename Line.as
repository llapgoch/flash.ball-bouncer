﻿package  {
	import com.davidpreece.util.NumFuncts;
	
	public class Line extends BaseObject{
		protected var angle:Number = 0;
		protected var lineLength:Number = 100;
		protected var friction:Number = 0.9;
		protected var bounce:Number = 0.6;

		public function Line(lineLength:Number, angle:Number = 0) {
			super();
			this.angle = angle;
			
			
			this.lineLength = lineLength;
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
		}
		
		

	}
	
}
