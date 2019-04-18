package vortex.editor.detect
{
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import fairygui.editor.plugin.IFairyGUIEditor;
	import fairygui.editor.plugin.IPublishData;
	
	import vortex.editor.plugin.IDetectHandler;
	
	public class DetectComponentHandler implements IDetectHandler
	{
		private var _editor:IFairyGUIEditor;
		private var _pkgPath:String;
		private var _pkgName:String;
		private var _alert:String;
		private var _pathMap:Object;
		private var _forbidenCharArray:Array;
		
		public function DetectComponentHandler(editor:IFairyGUIEditor)
		{
			_editor = editor;
		}
		
		public function get name():String
		{
			return "DetectComponentHandler";
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
			
			// 加载xml
			var xml
			
			var jsonData:Object = loadJson();
			if(jsonData == null)
				return false;
			
			// 解析component前缀限制
			_pathMap = new Object();
			_pathMap["/"] = "window_" // 默认设置根目录
			parseJsonNode(jsonData["component_prefix"], "");
			
			// 解析component非法字符限制
			_forbidenCharArray = new Array();
			_forbidenCharArray = jsonData["component_forbidden_char"] as Array;			
						
			var pkgXml:XML = LoadPackageXml(_pkgPath + "/package.xml");
			detectComponentName(pkgXml);
			
			if(alert != ""){
				alert = "\n" + _pkgName + "包中存在下列命名错误的资源:" + alert;
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
		
		private function loadJson():Object{
			var settingPath:String = _editor.project.basePath + "/settings/PackageStandard.json";
			var file:File = File.documentsDirectory.resolvePath(settingPath); 
			if(!file.exists){
				alert += "缺少文件夹检测规则配置文件" +  file.nativePath;
				return null;
			}
			
			var fileStream:FileStream = new FileStream(); 
			fileStream.open(file, FileMode.READ); 
			var jsonDe:JSONDecoder = new JSONDecoder(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close(); 
			
			var jsonData:Object = jsonDe.getValue();//反序列化
			return jsonData
		}
		
		private function parseJsonNode(data:Object, basePath:String):void {
			for(var key:String in data){
				var path:String = basePath;
				var value:* = data[key];
				
				if(value is String){ // 字串
					if(key != ""){
						path += "/" + key + "/";
					}
					else{
						path += "/";
					}
					
					_pathMap[path] = value;
//					alert += "\n" + path + "," + value;
				}
				else if(value is Object){
					path += "/" + key;
					parseJsonNode(value, path);
				}
			}
		}
		
		private function detectComponentName(pkgXml:XML):void{
			var resources:XMLList = pkgXml.child("resources")
			for each(var line:Object in resources.children()){
				var path:String = line.@path;
				if(!_pathMap.hasOwnProperty(path))
					continue;
				
				var prefix:String = _pathMap[path];
				var name:String = line.@name;
				if(name.search(prefix) != 0){
					alert += "\n" + path + name + ",前缀应为" + prefix;
				}
				
				var forbidenAlert:String = "";
				for each(var ch:String in _forbidenCharArray){
					if(name.search(ch) == -1) // 不包含非法字符
						continue;
					
					forbidenAlert += "\" " + ch + " \",";
				}
				
				if(forbidenAlert != ""){
					alert = "\n" + path + name + "包含非法字符" + forbidenAlert;
				}
			}

		}
	}
}