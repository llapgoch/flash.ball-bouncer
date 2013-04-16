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
		
		protected var movingDown:Boolean;
		protected var movingRight:Boolean;
		
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
			
			if(newCoords.y < this.world.getCeiling()){
				newCoords.y = this.world.getCeiling();
				hitTopOrBottom = true;
			}
			
		
			// Get points on the path of motion and check them against blocks in the world
			var path:Array = PathHelper.getPointsOnPath(new Point(this.x, this.y), xVelocity, yVelocity, 1);
			//var hitBlock:Object = this.checkBlockHit(newCoords, path);
			
			var lineHit:Object = this.checkLineHitPath(path);
			
			if(lineHit){
//				var path2:Array = PathHelper.getPointsOnPath(new Point(this.x, this.y), xVelocity, lineHit.point.y - this.y, 1);
//				var lineHit2:Object = this.checkLineHitPath(path2);
//				
//				if(lineHit2 !== null){
//					lineHit = lineHit2;
//				}
					
				newCoords = lineHit.point;
				this.xVelocity = lineHit.velocities.x;
				this.yVelocity = lineHit.velocities.y;
				onBlock = true;
			}
			
			
			/* this will be an individual block test rather than just the floor */
			if(newCoords.y >= this.world.getGround() - (this.height / 2)){
				newCoords.y = this.world.getGround() - (this.height / 2);
				this.yVelocity *= -world.getFloorBounce();
				this.xVelocity *= world.getGroundFriction();
				onBlock = true;
			}
			
			this.landed = onBlock; //|| hitBlock.landed;
					
			if(newCoords.x >= 550 || newCoords.x <= 0){
				this.xVelocity *= -1;
			}
			
			if(newCoords.x >= 550){
				newCoords.x = 550;
			}
			
			if(newCoords.x < 0){
				newCoords.x = 0;
			}
			
			this.movingDown = newCoords.y > this.y;
			this.movingRight = newCoords.x > this.x;
			
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
		public function checkLineHitPath(path:Array):Object{
			var lines:Array = world.getLines().concat();
			var i:int;
			var hits:Array = [];
			var lineTrack:Array = [];
			var velocities:Object = {
				'xVelocity':this.xVelocity,
				'yVelocity':this.yVelocity
			};
			
			// If we're moving backwards, favour earlier created lines. This is to allow favouring earlier lines to stop items from passing throughs.
			// This is not a perfect system, as later created lines may be created earlier on the X axis.
			if(xVelocity <= 0){
				lines = lines.reverse();
			}
			
			// TODO: If there are multiple items in the hit array, use the first hit rather than the last one 
			// for the aggregate calculations << Doesn't seem to work.
			// Try always using the highest return point's Y value?
			for(var j:int = 0; j < lines.length; j++){
				var initialHit:Object; 
				
				for(i = 0; i < path.length; i++){
					var ballPoint:Point = new Point(path[i].x, path[i].y);
					var hit:Object = checkLineHit(ballPoint, velocities, lines[j]);

					if(hit){
						//trace("first hit", j);
						// now find the first instance of tardvarkhe first kimoosend of this hit type
						for(var k:int = path.length - 1; k >= 0; k--){
							var secondHit:Object = checkLineHit(path[k], velocities, lines[j]);
							
							if(secondHit && secondHit.type == hit.type){
								//trace("hit line", j, hit.type);
								
								hits.push(secondHit);
								break;
							}
						}
						break;
					}
				}
				
			}
			
			if(hits.length){
				var resultPoint:Point = new Point(hits[0].point.x, hits[0].point.y);
				var resultVelocities:Object = {
					"x":hits[0].velocities.x,
					"y":hits[0].velocities.y
				};
				
				var ballHalf:Number = this.width / 2;
				
				for(i = 1; i < hits.length; i++){
					var line:Line = hits[i].line;
					
					// Removed this as a test - now adjusting the y value first
			
					if(xVelocity > 0){
						if(line.getTopPoint() > this.y + ballHalf){
							resultPoint.x = Math.max(resultPoint.x, hits[i].point.x);
							resultVelocities.x = Math.max(resultVelocities.x, hits[i].velocities.x);
						}else{
							resultPoint.x = Math.min(resultPoint.x, hits[i].point.x);
							resultVelocities.x = Math.min(resultVelocities.x, hits[i].velocities.x);
						}
					}else{
						if(line.getTopPoint() > this.y + ballHalf){
							resultPoint.x = Math.min(resultPoint.x, hits[i].point.x);
							resultVelocities.x = Math.min(resultVelocities.x, hits[i].velocities.x);
						}else{
							resultPoint.x = Math.max(resultPoint.x, hits[i].point.x);
							resultVelocities.x = Math.max(resultVelocities.x, hits[i].velocities.x);
						}
					}
					
					resultPoint.y = Math.min(resultPoint.y, hits[i].point.y);
					resultVelocities.y = Math.min(resultVelocities.y, hits[i].velocities.y);			
				}
			
				hits[0].point = resultPoint;
				hits[0].velocities = resultVelocities;
				return hits[0];
			}	
		
			return null;
		}
		
		
		protected function checkLineHit(ballPoint:Point, velocities, line:Line){
			var pixelAccuracy:Number = 3;
			var yAccuracy:Number = 3;
			var ballWidth:Number = this.width;
			var ballHeight:Number = this.height;
			var ballHalf:Number = ballWidth / 2;
			var lineRotation:Number = line.getAngle();
			var linePoint:Point = new Point(line.x, line.y);
			var origLineWidth:Number = line.getLineLength();

			var rNewCoords:Point = rotatePoint(ballPoint, linePoint, -lineRotation);
			var rVelocities:Point = rotatePoint(new Point(velocities.xVelocity, velocities.yVelocity), new Point(0, 0), -lineRotation);
			
			rVelocities.x = NumFuncts.round(rVelocities.x, 2);
			rVelocities.y = NumFuncts.round(rVelocities.y, 2);
			
			if(rNewCoords.x + (ballHalf) < line.x || rNewCoords.x - (ballHalf) > (line.x + origLineWidth)){
				return null;
			}
			
			var aboveIntersect:Boolean = rNewCoords.y + (ballHalf) > line.y && rNewCoords.y + (ballHalf - yAccuracy) < line.y;
			var belowIntersect:Boolean = rNewCoords.y - (ballHalf) < line.y && rNewCoords.y - (ballHalf - yAccuracy) > line.y;
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
						newPoint = rotatePoint(new Point(rNewCoords.x, Math.floor(line.y - (ballHalf + 0.5))), linePoint, lineRotation);
						hitType = HITTOP;
						rVelocities.x *= line.getFriction();
						
						newPoint.x += line.getXVelocity();
					}else{
						newPoint = rotatePoint(new Point(rNewCoords.x, Math.ceil(line.y + (ballHalf + 1))), linePoint, lineRotation);
						hitType = HITBOTTOM;
						rVelocities.x *= line.getFriction();

						newPoint.y += line.getYVelocity();
					}	
				}				

				if(newPoint){
					// flip back
					var fVelocities:Point = rotatePoint(rVelocities, new Point(0, 0), lineRotation);
					
					return {
						"point":newPoint,
						"line":line,
						"type":hitType,
						"rPoint":rNewCoords,
						"rVelocities":rVelocities,
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
			
			//this.y = newY;
			//this.x = newX;
			
			return {
				landed:onBlock
			}
		}

	}
	
}
