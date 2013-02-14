package  {
	import flash.display.MovieClip;
	import flash.geom.Point;

	public class Main extends MovieClip {
		var world:World;

		public function Main() {
			world = new World();
			
			this.addChild(world);
			
			
			/*
			var block = new Block();
			world.addObject(block, new Point(200, 300));
			
			var block2 = new Block();
			world.addObject(block2, new Point(100, 200));
			
			var block3 = new  Block();
			world.addObject(block3, new Point(250, 50));
			*/
			var line:Line = new Line(400, 10);
			world.addObject(line, new Point(0, 300));
			
			var line2:Line = new Line(400, -20);
			world.addObject(line2, new Point(200, 250));
			
			var line3:Line = new Line(200, 1);
			world.addObject(line3, new Point(100, 100));
			
			var ball = new Ball();
			world.addObject(ball, new Point(200, 0));
			
		}

	}
	
}
