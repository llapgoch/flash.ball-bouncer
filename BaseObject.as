package  {
	//moo
	import flash.display.MovieClip;
	
	public class BaseObject extends MovieClip {
		protected var world:World;
		
		public function BaseObject() {
			// constructor code
		}
		
		public function init(world:World):void{
			this.world = world;
		}
		
	

	}
	
}
