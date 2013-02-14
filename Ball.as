package  {
	import com.davidpreece.util.NumFuncts;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	
	public class Ball extends BaseObject {
		protected var xAccelaration:Number = 0;
		protected var yAccelaration:Number = 0;
		
		protected var xVelocity:Number = 30;
		protected var yVelocity:Number = 0;
		protected var jumpDistance:Number = -40;
		protected var maxAcceleration = 60;
		
		public static var HITLEFT = "left";
		public static var HITRIGHT = "right";
		public static var HITTOP = "top";
		public static var HITBOTTOM = "bottom";
		
		protected var landed:Boolean;
		
		public function Ball() {
	
		}
		
		public override function init(world:World):void{
			super.init(world);
			this.addEventListener(Event.ENTER_FRAME, gameLoop);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, keyupListener);
		}
		
		protected function keyListener(ev:KeyboardEvent = null){
			if(ev.keyCode == 37){
				this.xAccelaration = -2;
			}
			
			if(ev.keyCode == 39){
				this.xAccelaration = 2;
			}
			
			if(ev.keyCode == 38 && this.landed){
				this.yVelocity = this.jumpDistance;
			}
		}
		
		protected function keyupListener(ev:KeyboardEvent = null){
			this.xAccelaration = 0;
			this.yAccelaration = 0;
		}
		
		protected function gameLoop(ev:Event = null):void{
			this.yVelocity += Math.min(this.maxAcceleration, world.getGravity() + yAccelaration);
			this.xVelocity += Math.min(this.maxAcceleration, world.getWind() + xAccelaration);
			
			var newCoords:Point = new Point(
				this.x + xVelocity,
				this.y + yVelocity
			);
			
			var onFloor:Boolean = false;
			var onBlock:Boolean = false;
			var hitTopOrBottom:Boolean;
			
			/* this will be an individual block test rather than just the floor */
			if(newCoords.y >= this.world.getGround() - (this.height / 2)){
				newCoords.y = this.world.getGround() - (this.height / 2);
				this.yVelocity *= -world.getFloorBounce();
				this.xVelocity *= world.getGroundFriction();
				onBlock = true;
			}
			
			if(newCoords.y < this.world.getCeiling()){
				newCoords.y = this.world.getCeiling();
				hitTopOrBottom = true;
			}
			
		
			// Get points on the path of motion and check them against blocks in the world
			var path:Array = PathHelper.getPointsOnPath(new Point(this.x, this.y), xVelocity, yVelocity, 2);
			var hitBlock:Object = this.checkBlockHit(newCoords, path);
			
			var lineHit = this.checkLineHitPath(newCoords, path);
			
			if(lineHit){
				newCoords = lineHit.point;
				this.xVelocity = lineHit.velocities.x;
				this.yVelocity = lineHit.velocities.y;
				onBlock = true;
			}
			
			this.landed = onBlock || hitBlock.landed;
					
			if(newCoords.x >= 550 || newCoords.x <= 0){
				this.xVelocity *= -1;
			}
			
			if(newCoords.x >= 550){
				newCoords.x = 550;
			}
			
			if(newCoords.x < 0){
				newCoords.x = 0;
			}
			
			this.y = newCoords.y;
			this.x = newCoords.x;
		}
		
		public function rotatePoint(pPoint:Point, pOrigin:Point, rot:Number){
			var rp:Point = new Point();
			var radians:Number = (rot / 180) * Math.PI;
		
			rp.x = pOrigin.x + (Math.cos(radians) * (pPoint.x - pOrigin.x) - Math.sin(radians) * (pPoint.y - pOrigin.y));
			rp.y = pOrigin.y + (Math.sin(radians) * (pPoint.x - pOrigin.x) + Math.cos(radians) * (pPoint.y - pOrigin.y));
	
			return rp;
		}
		
		// Loop through an array of points to find the first hit point and get the new values for the object
		/*  TODO: Loop through, find the first hit point of a type, then loop through in reverse to find the last hitpoint
			of the same type. Return this hit point to preserve velocities */
		public function checkLineHitPath(newPos:Point, path:Array):Object{
			var lines = world.getLines();
			
			for(var i:int = 0; i < path.length; i++){
				var ballPoint:Point = new Point(path[i].x, path[i].y);
				var initialHit:Object; 
				
				for(var j:int = 0; j < lines.length; j++){
					var hit = checkLineHit(ballPoint, lines[j]);
							
					if(hit){
						// now find the first instance of the first kind of this hit type
						for(var k:int = path.length - 1; k > 0; k--){
							var secondHit:Object = checkLineHit(path[k], lines[j]);
							
							if(secondHit && secondHit.type == hit.type){
								return secondHit;
							}
						}
						
					}
				}
				
			}
			
			return null;
		}
		
		
		protected function checkLineHit(ballPoint:Point, line:Line){
			var pixelAccuracy:Number = 12;
			var ballWidth:Number = 29;
			var ballHeight:Number = 29;
			var ballHalf:Number = ballWidth / 2;
			var lineRotation:Number = line.getAngle();
			var linePoint:Point = new Point(line.x, line.y);
			var origLineWidth:Number = line.getLineLength();
			
			var rNewCoords:Point = rotatePoint(ballPoint, linePoint, -lineRotation);
			var rVelocities:Point = rotatePoint(new Point(this.xVelocity, this.yVelocity), new Point(0, 0), -lineRotation);
			
			rVelocities.x = NumFuncts.round(rVelocities.x, 2);
			rVelocities.y = NumFuncts.round(rVelocities.y, 2);
			
			if(rNewCoords.x + ballHalf < line.x || rNewCoords.x - ballHalf > (line.x + origLineWidth)){
				return null;
			}
			var aboveIntersect:Boolean = rNewCoords.y + ballHalf > line.y && rNewCoords.y + (ballHalf - pixelAccuracy) < line.y;
			var belowIntersect:Boolean = rNewCoords.y - ballHalf < line.y && rNewCoords.y - (ballHalf - pixelAccuracy) > line.y;
			var hitLeftOrRight:Boolean;
			var newPoint:Point; 
			var hitType:String;
						
			if(belowIntersect || aboveIntersect){
				if((rNewCoords.x + (ballHalf - pixelAccuracy) < line.x && (rNewCoords.x + ballHalf) > line.x) && rVelocities.x > 0){
					rVelocities.x *= -line.getFriction();
					hitLeftOrRight = true;
					newPoint = rotatePoint(new Point(line.x - ballHalf, rNewCoords.y), linePoint, lineRotation);
					hitType = HITLEFT;
				}
				
				if((rNewCoords.x - ballHalf < line.x + origLineWidth && rNewCoords.x - (ballHalf - pixelAccuracy) > line.x + origLineWidth) && rVelocities.x < 0){
					rVelocities.x *= -line.getFriction();
					hitLeftOrRight = true;
					newPoint = rotatePoint(new Point(line.x + origLineWidth + ballHalf + 1, rNewCoords.y), linePoint, lineRotation); 
					hitType = HITRIGHT;
				}
				
				if(!hitLeftOrRight){
					// Flip the y velocity
					rVelocities.y *= -line.getBounce();
					
					if(aboveIntersect){
						newPoint = rotatePoint(new Point(rNewCoords.x, Math.floor(line.y - ballHalf)), linePoint, lineRotation);
						hitType = HITTOP;
						rVelocities.x *= line.getFriction();
					}else{
						
						newPoint = rotatePoint(new Point(rNewCoords.x, Math.ceil(line.y + ballHalf)), linePoint, lineRotation);
						hitType = HITBOTTOM;
					}	
				}				

				if(newPoint){
					// flip back
					var fVelocities:Point = rotatePoint(rVelocities, new Point(0, 0), lineRotation);
					
					return {
						"point":newPoint, 
						"type":hitType,
						"velocities":{
							"x":fVelocities.x, 
							"y":fVelocities.y
						}
					};
				}
			}
		}
		
		public function checkBlockHit(newPos:Point, path:Array):Object{
			var hitObject:HitObject;
			var hitPoint:Point = new Point(newPos.x, newPos.y);
			var newY:Number, newX:Number;
			var hitTopOrBottom:Boolean;
			var onBlock:Boolean;
			
			for(var i:int = 0; i < path.length; i++){
				hitObject = world.blockHitTest(this, path[i]);
				
				if(hitObject !== null){
					break;
				}
				hitPoint = path[i];
			}
			
			if(hitObject){
				var collisionObj = hitObject.getHitObject();
				var hitLeftOrRight:Boolean;
				
				
				if(hitObject.hitTop() /*&& yVelocity > 0 */){
					newY = collisionObj.y - this.height + Math.min(0, collisionObj.getYVelocity());
					hitTopOrBottom = true;
					onBlock = true;
				}
				
				if(hitObject.hitBottom() /*&& yVelocity < 0 */){
					hitTopOrBottom = true;
					newY = collisionObj.y + collisionObj.height + Math.max(0, collisionObj.getYVelocity());
				}
				
				if(hitObject.hitLeft() && xVelocity > 0){
					newX = collisionObj.x - this.width;
					hitLeftOrRight = true;
				}
				
				if(hitObject.hitRight() && xVelocity < 0){
					newX = collisionObj.x + collisionObj.width;
					hitLeftOrRight = true;
				}
				
				if(hitLeftOrRight){
					this.xVelocity *= -1;
				}
			
			}
			
			if(hitTopOrBottom){
				this.yVelocity *= -world.getFloorBounce();
			}
			
			this.y = newY;
			this.x = newX;
			
			return {
				landed:onBlock
			}
		}

	}
	
}
