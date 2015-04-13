/**
 * @author: Peter Hansen
 * @copyright: p3337.de All rights reserved.
 */
package de.p3337.watercolorbox.storage
{
	import mx.utils.LinkedList;

	public class Stroke
	{
		public var size:uint;
		public var color:uint;
		public var alpha:Number;
		public var points:LinkedList = new LinkedList();
		
		public function Stroke(size:uint, color:uint, alpha:Number, point:Point)
		{
			this.size = size;
			this.color = color;
			this.alpha = alpha;
			this.points.push(point);
		}
	}
}