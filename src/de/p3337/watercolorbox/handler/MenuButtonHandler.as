/**
 * @author: Peter Hansen
 * @copyright: p3337.de All rights reserved.
 */
package de.p3337.watercolorbox.handler
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import de.p3337.watercolorbox.Painter;
	import de.p3337.watercolorbox.WaterColorBox;

	public class MenuButtonHandler
	{
		private var app:WaterColorBox;
		private var painter:Painter;
		
		public function MenuButtonHandler(app:WaterColorBox, painter:Painter)
		{
			this.app = app;
			this.painter = painter;
			addButtonHandler();
		}
		
		private function addButtonHandler():void
		{
			app.btnStartRepainting.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				painter.startRepainting();
			});
			
			app.btnStopRepainting.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				painter.stopRepainting();
			});
			
			app.btnDelete.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				painter.handleBrushVisibility();
				Alert.show("Are you sure?", "Title",
					Alert.YES | Alert.NO, app, function(event:CloseEvent):void {
						if(event.detail == Alert.YES) {
							painter.clearCanvas();
						}
						painter.handleBrushVisibility(true, app.mouseX, app.mouseY);
					});
			});
			
			app.btnUndo.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				painter.undoPaintingLastStroke();
			});
			
			app.btnSaveImage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				painter.saveImage();
			});
			
			app.pointsToDrawPerFrameSlider.addEventListener(Event.CHANGE, function(e:Event):void {
				painter.changePointsToDrawPerFrameValue(app.pointsToDrawPerFrameSlider.value);
			});
		}
	}
}