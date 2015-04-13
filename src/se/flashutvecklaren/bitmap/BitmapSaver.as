/**
 * @author: Andreas
 * @copyright: Flashutvecklaren.se All rights reserved.
 */
package se.flashutvecklaren.bitmap
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.IImageEncoder;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	/**
	 *  Class for saving an image of a DisplayObject to the users file system.
	 *  The image can be saved using PNG or JPG compression.
	 */
	public class BitmapSaver
	{
		/**
		 *  Constructor.
		 */
		public function BitmapSaver()
		{
		}
		/**
		 *  Saves an images of a DisplayObject as a PNG file on the users filesystem.
		 *  @param rSource the DisplayObject to save an image of
		 *  @see #saveJPG() 
		 */
		public function savePNG(rSource:DisplayObject):void
		{
			save(rSource, new PNGEncoder(), '.png');
		}
		/**
		 *  Saves an images of a DisplayObject as a JPG file on the users filesystem.
		 *  @param rSource the DisplayObject to save an image of
		 *  @param rQuality a value between 0.0 and 100.0. The smaller the quality value, the smaller the file size of the resultant image. The default value is 50.0.
		 *  @see #savePNG()
		 */
		public function saveJPG(rSource:DisplayObject, rQuality:Number = 50.0):void
		{
			save(rSource, new JPEGEncoder(rQuality), '.jpg');
		}
		/**
		 *  @private
		 *  Used for capturing and saving the image
		 */
		protected function save(rSource:DisplayObject, rEncoder:IImageEncoder, rDefaultFileName:String):void
		{
			var tBD:BitmapData = new BitmapData(rSource.width, rSource.height);
			tBD.draw(rSource);
			var tBA:ByteArray = rEncoder.encode(tBD);
			var tFR:FileReference = new FileReference();
			tFR.save(tBA, rDefaultFileName);
			tBD.dispose();
			tBA.clear();
		}
	}
}