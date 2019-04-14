/**
 * 
 * @desc	detect resources legitimacy
 * @author	xtom
 * @time	2019/4/10.
 * 
 */
package vortex.editor.detect
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import fairygui.editor.plugin.IFairyGUIEditor;
	import fairygui.editor.plugin.IPublishData;
	
	import vortex.editor.plugin.IDetectHandler;
	
	public final class DetectPackageHandler implements IDetectHandler 
	{
		private var _pkgName:String;
		private var _pkgPath:String;
		private var _pkgResMap:Object; // package.xml中记录的资源
		private var _alert:String = "";
		private var _uselessAlert:String = "";
		
		public function DetectPackageHandler(editor:IFairyGUIEditor)
		{
		}
		
		public function get name():String
		{
			return "DetectPackageHandler";
		}
		
		public function get alert():String
		{
			return _alert;
		}
		
		public function set alert(str:String):void
		{
			_alert = str;
		}
		
		public function doDetect(data:IPublishData):Boolean {
			_pkgName = data.targetUIPackage.name;
			_pkgPath = data.targetUIPackage.basePath;
			
			// 加载xml
			var xml:XML = LoadPackageXml(_pkgPath + "/package.xml");
			
			// 检测重复资源
			DetectDuplicateRes(xml); // 检查重复项
			
			// 检测废弃资源
			_uselessAlert = "";
			DetectUselessRes(_pkgPath); 
			if(_uselessAlert != ""){
				_uselessAlert = _pkgName + "包中存在废弃的资源:" + _uselessAlert;
				alert += "\n" + _uselessAlert
			}
			
			return false;
		}
		
		/**
		 * 加载package.xml
		 */
		public function LoadPackageXml(pkgPath:String):XML{
			var file:File = File.documentsDirectory.resolvePath(pkgPath); 
			var fileStream:FileStream = new FileStream(); 
			fileStream.open(file, FileMode.READ); 
			var xml:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable)); 
			fileStream.close(); 
			return xml;
		}
		
		/**
		 * 检测资源重复，主要检测由处理冲突错误带来的package.xml中同个资源存在多行的问题
		 */
		public function DetectDuplicateRes(xml:XML):void {
			
			_pkgResMap = new Object();
			
			var resources:XMLList = xml.child("resources")
			for each(var line:Object in resources.children()){
				
				var name:String = line.@path + line.@name;
				if(_pkgResMap[name] != undefined){
					alert += "\n" + name;
					continue;
				}
				
				_pkgResMap[name] = 1;
			}
			
			if(alert != ""){
				alert = "\n" + _pkgName + "包中存在下列相同的资源:" + alert;
			}
		}
		
		/**
		 * 检测无用资源，即package.xml中没有但文件夹中有的资源
		 */
		public function DetectUselessRes(path:String):void
		{
			//获取指定路径下的所有文件名
			var directory:File = new File(path); 
			var contents:Array = directory.getDirectoryListing(); 
			for (var i:uint = 0; i < contents.length; i++){ 
				var file:File = contents[i] as File;
				
				// 文件夹则继续遍历
				if(file.isDirectory){
					DetectUselessRes(file.nativePath);
					continue;
				}
				
				var name:String = file.nativePath.replace(_pkgPath, "").split("\\").join("/"); // 只对比包内路径
				if(!_pkgResMap.hasOwnProperty(name) && name != "/package.xml" && name != "/.DS_Store"){ // package中没有
					_uselessAlert += "\n" + name;
				}
			}
		}
	}
}