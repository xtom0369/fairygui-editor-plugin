package vortex.editor.detect
{
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import fairygui.editor.plugin.IFairyGUIEditor;
	import fairygui.editor.plugin.IPublishData;
	
	import vortex.editor.plugin.IDetectHandler;
	
	public class DetectFolderStructHandler implements IDetectHandler
	{
		private var _editor:IFairyGUIEditor;
		private var _pkgPath:String;
		private var _pkgName:String;
		private var _alert:String = "";
		private var _pathMap:Object;
		
		public function DetectFolderStructHandler(editor:IFairyGUIEditor)
		{
			_editor = editor;
		}
		
		public function get name():String
		{
			return "DetectFolderStructHandler";
		}
		
		public function get alert():String
		{
			return _alert;
		}
		
		public function set alert(str:String):void
		{
			_alert = str;
		}
		
		public function doDetect(publishData:IPublishData):Boolean
		{
			_pkgName = publishData.targetUIPackage.name;
			_pkgPath = publishData.targetUIPackage.basePath;
			
			// 加载配置文件
			var jsonData:Object = loadJson();
			if(jsonData == null)
				return false;
			
			_pathMap = new Object();
			_pathMap["/"] = 1 // 默认设置根目录
			parseJsonNode(jsonData, "folder", "");

			detectFolderStruct(_pkgPath);
			
			if(alert != ""){
				alert = _pkgName + "包中存在路径错误的资源:" + alert
			}
			
			return true;
		}
		
		private function loadJson():Object{
			var settingPath:String = _editor.project.basePath + "/settings/PackageStandard.json";
			var file:File = File.documentsDirectory.resolvePath(settingPath); 
			if(!file.exists){
				alert += "缺少文件夹检测规则配置文件" + file.nativePath;
				return null;
			}
			
			var fileStream:FileStream = new FileStream(); 
			fileStream.open(file, FileMode.READ); 
			var jsonDe:JSONDecoder = new JSONDecoder(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close(); 
			
			var jsonData:Object = jsonDe.getValue();//反序列化
			return jsonData;
		}
		
		private function parseJsonNode(data:Object, node:String, basePath:String):void {
			var arrays:Array = data[node] as Array;
			for each(var array:* in arrays){
				var path:String = basePath;
				
				if(array is String){ // 字串
					path += "/" + array + "/";
//					alert += "\n" + path;
					_pathMap[path] = 1;
				}
				else if(array is Object){
					var obj:Object = array as Object
					for(var key:String in obj){
						path += "/" + key;
						_pathMap[path + "/"] = 1;
						parseJsonNode(obj, key, path);
					}
				}
			}
		}
		
		private function detectFolderStruct(path:String):void{
			//获取指定路径下的所有文件名
			var directory:File = new File(path); 
			var contents:Array = directory.getDirectoryListing(); 
			for (var i:uint = 0; i < contents.length; i++){ 
				var file:File = contents[i] as File;
				
				var name:String;
				var subPath:String;
				
				// 文件夹则继续遍历
				if(file.isDirectory){
					name = file.nativePath.replace(_pkgPath, "").split("\\").join("/") + "/"; // 只对比包内路径
					if(!_pathMap.hasOwnProperty(name)){ 
						alert += "\n" + name;
					}
					
					detectFolderStruct(file.nativePath);
					continue;
				}
				
				name = file.nativePath.replace(_pkgPath, "").split("\\").join("/"); // 只对比包内路径
				subPath = name.replace(file.name, "");
//				alert += "\n" + name;
				if(!_pathMap.hasOwnProperty(subPath) && name != "/package.xml" && name != "/.DS_Store"){ 
					alert += "\n" + name;
				}
			}
		}
	}
}