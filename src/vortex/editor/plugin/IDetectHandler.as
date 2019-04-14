package vortex.editor.plugin
{
	import fairygui.editor.plugin.ICallback;
	import fairygui.editor.plugin.IPublishData;
	
	public interface IDetectHandler
	{
		/**
		 * 检测器名称
		 */
		function get name():String;
		
		/**
		 * 警告文本，会由管理器整理打印和弹窗提示
		 */
		function get alert():String;
		
		function set alert(str:String):void;
		
		/**
		 * 输出处理。这里可以是异步处理。
		 * @return 返回false表示不处理。返回true表示已经开始了处理，处理完成后，成功调用callback.callOnSuccess，失败则调用callback.callOnFail。
		 */
		function doDetect(publishData:IPublishData):Boolean; 
	}
}



