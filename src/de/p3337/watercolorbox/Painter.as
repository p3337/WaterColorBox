/**
 * @author: Peter Hansen
 * @copyright: p3337.de All rights reserved.
 */
package de.p3337.watercolorbox
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.ui.Mouse;
	
	import de.p3337.watercolorbox.storage.Point;
	import de.p3337.watercolorbox.storage.Storage;
	import de.p3337.watercolorbox.storage.Stroke;
	
	import se.flashutvecklaren.bitmap.BitmapSaver;
	
	public class Painter extends EventDispatcher
	{
		private const BRUSH_OFFSET_X:Number = -7;
		private const BRUSH_OFFSET_Y:Number = -24;
		private const POINTS_PER_FRAME:Number = 5;
		
		private var app:WaterColorBox;
		private var canvasMask:Shape;
		
		private var brushSize:uint;
		private var brushColor:uint;
		private var brushAlpha:Number;
		
		private var isInRepaintingMode:Boolean = false;
		private var isInDrawingMode:Boolean = false;
		
		private var pointsPerFrame:Number;
		private var pointsToDrawPerFrame:Number;
		
		private var storage:Storage;
		
		public function Painter(app:WaterColorBox, storage:Storage) {
			this.app = app;		
			this.storage = storage;
			pointsToDrawPerFrame = POINTS_PER_FRAME;
			
			app.addEventListener(Event.ENTER_FRAME, onTimePassesBy);
			app.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				brushOnTouchingCanvas();
			});
			createCanvasMask();
		}
		
		/**
		 * Creates a mask to reveal only a certain portion of the canvas.
		 */
		private function createCanvasMask():void {
			canvasMask = new Shape();
			canvasMask.graphics.beginFill(0xFF0000, 1);
			canvasMask.graphics.drawRect(
				app.canvas.x + 1,
				app.canvas.y + 27,
				app.canvas.width - 2,
				app.canvas.height - 28);
			canvasMask.graphics.endFill();
			app.myGraphic.mask = canvasMask;			
		}
		
		/**
		 * On mouse down and only if brush is on canvas this method stores 
		 * the new stroke parameters and draws first stroke point.
		 */
		public function brushOnTouchingCanvas():void {
			var posX:int = app.mouseX;
			var posY:int = app.mouseY;
			
			if(!isBrushOnCanvas(posX, posY)) return;
			if(!isInRepaintingMode) {
				app.addEventListener(MouseEvent.MOUSE_MOVE, brushOnMoving);
				app.addEventListener(MouseEvent.MOUSE_UP, brushOnLosingGround);
				
				isInDrawingMode = true;
				
				brushSize = 2 * Math.exp(app.brushSizeSlider.value);
				brushColor = app.brushColorPicker.selectedColor;
				brushAlpha = Math.round(app.alphaSlider.value) / 100;
				
				app.myGraphic.graphics.lineStyle(brushSize, brushColor, brushAlpha);
				
				app.imgBrush.x = posX + BRUSH_OFFSET_X;
				app.imgBrush.y = posY + BRUSH_OFFSET_Y;
				
				app.myGraphic.graphics.moveTo(posX - 1, posY - 1);
				
				storage.pushStroke(new Stroke(brushSize, brushColor, brushAlpha, new Point(posX - 1, posY - 1)));

				app.myGraphic.graphics.lineTo(posX, posY);
				storage.pushStrokePoint(new Point(posX, posY));	
			}
		}
		
		/**
		 * Removes all active drawing event listener if mouse leaves down state 
		 */
		public function brushOnLosingGround(event:MouseEvent):void {
			if(isInDrawingMode == true) {
				isInDrawingMode = false;
				if(app.hasEventListener(MouseEvent.MOUSE_UP)) {
					app.removeEventListener(MouseEvent.MOUSE_UP, brushOnLosingGround);
				}
				if(app.hasEventListener(MouseEvent.MOUSE_MOVE)) {
					app.removeEventListener(MouseEvent.MOUSE_MOVE, brushOnMoving);
				}
			}
		}
		
		
		/**
		 * While mouse is pressed and moves on canvas this method is drawing and storing all resulting points.
		 * 
		 * @param event flash.events.MouseEvent
		 */
		public function brushOnMoving(event:MouseEvent):void {
			if(isInDrawingMode) {
				var posX:int = app.mouseX;
				var posY:int = app.mouseY;
				
				var isBrushOnCanvas:Boolean = isBrushOnCanvas(posX, posY);
				handleBrushVisibility(isBrushOnCanvas, posX, posY);
				
				if(posX > 50 && posY > 50) {
					app.imgBrush.x = posX + BRUSH_OFFSET_X;
					app.imgBrush.y = posY + BRUSH_OFFSET_Y;
					
					app.myGraphic.graphics.lineTo(posX, posY);
					storage.pushStrokePoint(new Point(posX, posY));
					
					event.updateAfterEvent();
				} else {
					isInDrawingMode = false;
					
					if(app.hasEventListener(MouseEvent.MOUSE_UP)) { 
						app.removeEventListener(MouseEvent.MOUSE_UP, brushOnLosingGround);
					}
					if(app.hasEventListener(MouseEvent.MOUSE_MOVE)) {
						app.removeEventListener(MouseEvent.MOUSE_MOVE, brushOnMoving);
					}
				}
			}
		}
		
		/**
		 * Toggles between main menu and repainting menu view.
		 * 
		 * @param showRepaintingMenuVGroup Shows repainting menu if true.
		 */
		public function toggleMenuVGroup(showRepaintingMenuVGroup:Boolean = false):void {	
			if(showRepaintingMenuVGroup) {
				if(storage.getNumberOfStrokes() > 0) {
					app.mainMenuVGroup.visible = false;
					app.mainMenuVGroup.x = -300;
					app.repaintingMenuVGroup.visible = true;
					app.repaintingMenuVGroup.x = 0;
				}
			} else {
				app.repaintingMenuVGroup.visible = false;
				app.repaintingMenuVGroup.x = -300;
				app.mainMenuVGroup.visible = true;
				app.mainMenuVGroup.x = 0;
			}
		}
		
		/**
		 * Aborts repainting mode.
		 */
		public function stopRepainting():void {
			storage.resetCurrentStrokeAndPoint();
			app.imgBrush.visible = false;
			isInRepaintingMode = false;
			toggleMenuVGroup();
			redrawPainting();
		}
		
		/**
		 * Initializes repainting mode.
		 */
		public function startRepainting():void {
			if(!isInRepaintingMode) {
				toggleMenuVGroup(true);
				app.myGraphic.graphics.clear();
				isInRepaintingMode = true;
			}
		}
		
		public function clearCanvas():void {
			if(!isInRepaintingMode) {
				app.myGraphic.graphics.clear();
				storage.removeAllStrokes();
				app.pointsToDrawPerFrameSlider.value = POINTS_PER_FRAME;
				pointsToDrawPerFrame = POINTS_PER_FRAME;
			}
		}
		
		/**
		 * Removes last stroke from canvas and storage.
		 */
		public function undoPaintingLastStroke():void {
			if(!isInRepaintingMode) {
				storage.popStroke();
				redrawPainting();
			}
		}
		
		/**
		 * Draws all storkes and their points stored in storage.
		 */
		public function redrawPainting():void {
			app.myGraphic.graphics.clear();
			var stroke:Stroke = storage.setFirstStroke();
			while(stroke) { 
				drawStroke(stroke);
				stroke = storage.setNextStroke();
			}
		}
		
		/**
		 * Draws a single stroke and all of it's points.
		 * 
		 * @param stroke The stroke to draw.
		 */
		private function drawStroke(stroke:Stroke):void {
			if(stroke !== null) {
				app.myGraphic.graphics.lineStyle(stroke.size, stroke.color, stroke.alpha);
				
				var point:Point = storage.setFirstStrokePoint();
				app.myGraphic.graphics.moveTo(point.x, point.y);
				while(point) {
					app.myGraphic.graphics.lineTo(point.x, point.y);
					point = storage.setNextStrokePoint();
				}
			}
		}
		
		/**
		 * Draws just a single point of a stroke (used for repainting mode).
		 */
		private function drawStrokePoint():void {
			var currentStroke:Stroke = storage.getCurrentStroke();
			var currentStrokePoint:Point = storage.getCurrentStrokePoint();
			if(currentStroke !== null) {
				if(storage.isFirstStrokePoint()) {
					app.myGraphic.graphics.lineStyle(currentStroke.size, currentStroke.color, currentStroke.alpha);
					app.myGraphic.graphics.moveTo(currentStrokePoint.x, currentStrokePoint.y);
				}
				app.myGraphic.graphics.lineTo(currentStrokePoint.x, currentStrokePoint.y);
				app.imgBrush.x = currentStrokePoint.x + BRUSH_OFFSET_X;
				app.imgBrush.y = currentStrokePoint.y + BRUSH_OFFSET_Y;
			}
		}
		
		/**
		 * On enter frame methode - used for repainting mode to redraw a picture step by step.
		 * 
		 * @param event flash.events.Event
		 */
		private function onTimePassesBy(event:Event):void {
			if(isInRepaintingMode) {
				pointsPerFrame = pointsToDrawPerFrame;
				
				var currentStroke:Stroke = storage.getCurrentStroke();
				var currentStrokePoint:Point = storage.getCurrentStrokePoint();
				
				if(currentStroke === null) {
					currentStroke = storage.setFirstStroke();
					currentStrokePoint = storage.setFirstStrokePoint();
					app.myGraphic.graphics.clear();
					app.imgBrush.visible = true;
				}
				
				while(pointsPerFrame > 0) {
					if(currentStrokePoint === null) {
						currentStroke = storage.setNextStroke();
						if(currentStroke !== null) {
							currentStrokePoint = storage.setFirstStrokePoint();
						}
					}
					
					if(currentStroke === null) {
						storage.resetCurrentStrokeAndPoint();
						app.imgBrush.visible = false;
						isInRepaintingMode = false;
						toggleMenuVGroup();
						pointsPerFrame = 0;
					} else {
						drawStrokePoint();
						currentStrokePoint = storage.setNextStrokePoint();
						pointsPerFrame--;
					}
				}
			} else {
				var isMouseOnTopOfCanvas:Boolean = isBrushOnCanvas(app.mouseX, app.mouseY);
				handleBrushVisibility(isMouseOnTopOfCanvas, app.mouseX, app.mouseY);
			}
		}
		
		/**
		 * Checks if brush is on top of canvas (mask).
		 *  
		 * @param posX The current mouse x coordinate.
		 * @param posY The current mouse y coordinate.
		 * @return true if pressed mouse is on canvas; false otherwise.
		 * 
		 */		
		private function isBrushOnCanvas(posX:int, posY:int):Boolean {
			return canvasMask.hitTestPoint(posX, posY);
		}
		
		/**
		 * Sets the visibility of the brush image which replaces the mouse cursor in drawing mode.
		 * 
		 * @param setVisibility true if brush image should be visible and follow mouse cursor; false otherwise.
		 * @param posX The current mouse x coordinate.
		 * @param posY The current mouse y coordinate.
		 */		
		public function handleBrushVisibility(setVisibility:Boolean = false, posX:int = 0, posY:int = 0):void {
			if(setVisibility) {
				if(!app.imgBrush.visible) {
					Mouse.hide();
					app.imgBrush.visible = true;
				}
				
				if(!isInDrawingMode) {
					app.imgBrush.x = posX + BRUSH_OFFSET_X;
					app.imgBrush.y = posY + BRUSH_OFFSET_Y;
				}
			} else {
				if(app.imgBrush.visible) {
					Mouse.show();
					app.imgBrush.visible = false;
				}
			}
		}
		
		/**
		 * Opens a file dialog to save the whole canvas as an image. 
		 */		
		public function saveImage():void {
			var bmd:BitmapData = new BitmapData(app.canvas.width - 2, app.canvas.height - 28);
			var m:Matrix = new Matrix();
				m.translate(-(app.canvas.x + 1), -(app.canvas.y + 27));
			
				bmd.draw(app.myGraphic, m);
			var bm:Bitmap = new Bitmap(bmd);
			
			var tBS:BitmapSaver = new BitmapSaver();
				tBS.savePNG(bm);
		}
		
		public function changePointsToDrawPerFrameValue(value:Number):void {
			pointsToDrawPerFrame = value;
		}
	}
}