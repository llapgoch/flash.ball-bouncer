package  {
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
		
		protected var landed:Boolean;
		
		public function Ball() {
			// constructor coded
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
			
			//trace(ev.keyCode);
			
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
			this.yVelocity += Math.min(5, world.getGravity() + yAccelaration);
			this.xVelocity += world.getWind() + xAccelaration;
			
			var newCoords:Point = new Point(
				this.x + xVelocity,
				this.y + yVelocity
			);
			
			var onBlock:Boolean = false;
			var hitTopOrBottom:Boolean;
			
			/* this will be an individual block test rather than just the floor */
			if(newCoords.y >= this.world.getGround() - this.height){
				newCoords.y = this.world.getGround() - this.height;
				this.yVelocity *= -world.getFloorBounce();
				this.xVelocity *= world.getGroundFriction();
				onBlock = true;
			}
			
			if(newCoords.y < this.world.getCeiling()){
				newCoords.y = this.world.getCeiling();
				hitTopOrBottom = true;
			}
			
		
			// Get points on the path of motion and check them against blocks in the world
			var path:Array = PathHelper.getPointsOnPath(new Point(this.x, this.y), xVelocity, yVelocity);
			var hitBlock:Object = this.checkBlockHit(newCoords, path);
			
			var lineHit = this.checkLineHit(newCoords, path);
			
			if(lineHit){
				trace('line hit');
				newCoords = lineHit.point;
				this.xVelocity = lineHit.velocities.x;
				this.yVelocity = lineHit.velocities.y;
			}
			
			this.landed = onBlock || hitBlock.landed;
			
			if(onBlock){
				this.xVelocity *= world.getGroundFriction();
			}
			
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
		
		public function checkLineHit(newPos:Point, path:Array):Object{
			var lines = world.getLines();
			var pixelAccuracy:Number = 10;
			var ballWidth:Number = 29;
			var ballHeight:Number = 29;

			
			for(var i:int = 0; i < path.length; i++){
				var ballPoint:Point = new Point(path[i].x, path[i].y);

				for(var j:int = 0; j < lines.length; j++){
					var line = lines[j];
					var lineRotation:Number = line.getAngle();
					var linePoint:Point = new Point(line.x, line.y);
					var origLineWidth:Number = line.getLineLength();
					
					var rNewCoords:Point = rotatePoint(ballPoint, linePoint, -lineRotation);
					var rVelocities:Point = rotatePoint(new Point(this.xVelocity, this.yVelocity), new Point(0, 0), -lineRotation);
			
					if(rNewCoords.x + ballWidth >= line.x && rNewCoords.x < (line.x + origLineWidth)){
						var aboveIntersect:Boolean = rNewCoords.y + ballHeight > line.y && rNewCoords.y + (ballHeight -  pixelAccuracy) < line.y;
						var belowIntersect:Boolean = rNewCoords.y < line.y && rNewCoords.y + (ballHeight - pixelAccuracy) > line.y;
						var hitLeftOrRight:Boolean;
						var newPoint:Point;
				
						if(belowIntersect || aboveIntersect){
							if(rNewCoords.x + pixelAccuracy < line.x && (rNewCoords.x + ballWidth) > line.x){
								rVelocities.x *= -1;
								hitLeftOrRight = true;
								newPoint = rotatePoint(new Point(line.x, rNewCoords.y), linePoint, lineRotation);
							}
					
							if(rNewCoords.x <= line.x + origLineWidth && rNewCoords.x - pixelAccuracy > line.x + origLineWidth){
								rVelocities.x *= -1;
								hitLeftOrRight = true;
								newPoint = rotatePoint(new Point(line.x + origLineWidth, rNewCoords.y), linePoint, lineRotation); 
							}
					
							if(!hitLeftOrRight){
								// Flip the y velocity
								rVelocities.y *= -1;
								// flip back
					
								if(aboveIntersect){
									trace('above');
									newPoint = rotatePoint(new Point(rNewCoords.x, line.y - ballHeight), linePoint, lineRotation);
									//this.y = newPoint.y;
									//this.x = newPoint.x;
								}else{
									trace('below');
									newPoint = rotatePoint(new Point(rNewCoords.x, line.y), linePoint, lineRotation);
								}
							}
					
						}
						
						if(newPoint){
							var fVelocities:Point = rotatePoint(rVelocities, new Point(0, 0), lineRotation);
							
							return {"point":newPoint, 
									"velocities":{
										"x":fVelocities.x, 
										"y":fVelocities.y
									}
							};
						}
						
					}
					
					
					
					
					/*
					if(newX - ballHalf <= 0 || newX + ballHalf >= stage.stageWidth){
						ball.vx *= -1;
					}
					
					if(newY - ballHalf <= 0 || newY + ballHalf >= stage.stageHeight){
						ball.vy *= -1;
					}
					*/
				}
			}
			
			return null;
		}
		
		public function checkBlockHit(newPos:Point, path:Array):Object{
			// TODO: Turn this into an array
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
