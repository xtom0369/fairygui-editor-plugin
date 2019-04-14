package vortex.editor.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class DebugUtil
	{
		private var _bathPath:String;
		private var _logPath:String;
		
		public function DebugUtil(bathPath:String, func:String)
		{
			_bathPath = bathPath;
			_logPath = _bathPath + "/logs/" + func + "_log.txt";
		}
		
		public function LogError(log:String):void{
			LogEx("ERROR", log);
		}
		
		public function LogWarnning(log:String):void{
			LogEx("WARNNING", log);
		}
		
		public function Log(log:String):void {
			LogEx("INFO", log);
		}
		
		public function LogEx(prefix:String, log:String):void {
			var time:String = getTimeStr();
			log = time + " [" + prefix + "] " + log;
			var file:File = new File(_logPath);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.APPEND);
			fileStream.writeUTFBytes(log + "\n");
			fileStream.close();
		}
		
		public function ClearLog():void {
			var file:File = new File(_logPath);
			if (file.exists) {
				file.deleteFile();
			}
		}
		
		private function getTimeStr():String {  
			var nowdate:Date = new Date();  
			//创建新的日期对象，用来获取现在的时间  
			var year:Number = nowdate.getFullYear();  
			//获取当前的年份  
			var month:Number = nowdate.getMonth()+1;  
			//获取当前的月份，因为数组从0开始用0-11表示1-12月，所以要加1  
			var date:Number = nowdate.getDate();  
			//获取当前日期  
			var day:Number = nowdate.getDay();  
			//获取当年的星期  
			var hour:Number = nowdate.getHours();  
			//获取当前小时  
			var minute:Number = nowdate.getMinutes();  
			//获取当前的分钟  
			var second:Number = nowdate.getSeconds();  
			//获取当前的秒钟  
			return "[" + year + "-" + month + "-" + date + " " + hour + ":" + minute + ":" + second + "]";
		}  
	}
}