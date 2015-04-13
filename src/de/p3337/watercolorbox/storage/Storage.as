/**
 * @author: Peter Hansen
 * @copyright: p3337.de All rights reserved.
 */
package de.p3337.watercolorbox.storage
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.utils.LinkedList;
	import mx.utils.LinkedListNode;

	public class Storage extends EventDispatcher
	{
		private var strokes:LinkedList;
		private var currentStrokeNode:LinkedListNode;
		private var currentStrokePointNode:LinkedListNode;
		private var lastStrokeNode:LinkedListNode;
		
		public function Storage() {
			strokes = new LinkedList();
			lastStrokeNode = null;
			currentStrokeNode = null;
			currentStrokePointNode = null;
		}
		
		public function removeAllStrokes():void {
			strokes = new LinkedList();
			dispatchEventStrokesChanged();
		}
		
		public function pushStroke(stroke:Stroke):void {
			if(stroke !== null) {
				lastStrokeNode = strokes.push(stroke);
				dispatchEventStrokesChanged();
			}
		}
		
		public function popStroke():void {
			lastStrokeNode = lastStrokeNode.prev;
			strokes.pop();
			dispatchEventStrokesChanged();
		}
		
		public function pushStrokePoint(point:Point):void {
			var stroke:Stroke = lastStrokeNode.value;
			if(point != null) {
				stroke.points.push(point);
			}
		}
		
		public function popStrokePoint():void {
			var stroke:Stroke = lastStrokeNode.value;
			if(lastStrokeNode !== null)	{
				stroke.points.pop();
			}
		}
		
		private function dispatchEventStrokesChanged():void {
			var eventObj:Event = new Event("strokesChanged"); 
			dispatchEvent(eventObj);
		}
		
		public function getNumberOfStrokes():uint {
			return strokes.length;
		}
		
		public function setFirstStroke():Stroke {
			currentStrokeNode = strokes === null? null : strokes.head;
			return getCurrentStroke();
		}
		
		public function setFirstStrokePoint():Point {
			currentStrokePointNode = (currentStrokeNode === null 
				|| currentStrokeNode.value === null
				|| currentStrokeNode.value.points === null)?
				null : currentStrokeNode.value.points.head;
			return getCurrentStrokePoint();
		}
		
		public function getCurrentStroke():Stroke {
			var stroke:Stroke = null;
			if(currentStrokeNode !== null) {
				stroke = currentStrokeNode.value;
			}
			
			return stroke;
		}
		
		public function getCurrentStrokePoint():Point {
			var point:Point = null;
			if(currentStrokePointNode !== null) {
				point = currentStrokePointNode.value;
			}
			return point;
		}
		
		public function setNextStroke():Stroke {
			currentStrokeNode = currentStrokeNode === null? null : currentStrokeNode.next;
			return getCurrentStroke();
		}
		
		public function setNextStrokePoint():Point {
			currentStrokePointNode = currentStrokePointNode === null? null : currentStrokePointNode.next;
			return getCurrentStrokePoint();
		}
		
		public function isFirstStroke():Boolean {
			var result:Boolean = false;
			if(strokes !== null) {
				result = currentStrokeNode === strokes.head;
			}
			return result;
		}
		
		public function isFirstStrokePoint():Boolean {
			var result:Boolean = false;
			if(currentStrokeNode !== null && currentStrokeNode.value !== null && currentStrokeNode.value.points !== null) {
				result = currentStrokePointNode === currentStrokeNode.value.points.head;
			}
			return result;
		}
		
		public function resetCurrentStrokeAndPoint():void {
			currentStrokeNode = null;
			currentStrokePointNode = null;
		}
	}
}