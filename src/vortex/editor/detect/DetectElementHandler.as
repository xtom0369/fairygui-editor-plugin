/**
 * 
 * @desc	单个组件检测
 * @author	xtom
 * @time	2019/4/11.
 * 
 */
package vortex.editor.detect
{
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import fairygui.editor.plugin.IFairyGUIEditor;
	import fairygui.editor.plugin.IPublishData;
	
	import vortex.editor.plugin.IDetectHandler;

	public class DetectElementHandler implements IDetectHandler
	{
		private var _editor:IFairyGUIEditor;
		private var _elements:Object;
		private var _alert:String = "";
		private var _forbidenCharArray:Array;
		
		public function DetectElementHandler(editor:IFairyGUIEditor)
		{
			_editor = editor;
		}
		
		public function get name():String
		{
			return "DetectElementHandler";
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
			var jsonData:Object = loadJson();
			if(jsonData == null)
				return false;
			
			// 解析component非法字符限制
			_forbidenCharArray = new Array();
			_forbidenCharArray = jsonData["element_forbidden_char"] as Array;
			
			/**
			 * 组件输出类定义列表。这是一个Map，key是组件id，value是一个结构体，例如：
			 * {
			 * 		classId : "8swdiu8f",
			 * 		className ： "AComponent",
			 * 		superClassName : "GButton",
			 * 		members : [
			 * 			{ name : "n1" : type : "GImage" },
			 * 			{ name : "list" : type : "GList" },
			 * 			{ name : "a1" : type : "GComponent", src : "Component1" },
			 * 			{ name : "a2" : type : "GComponent", src : "Component2", pkg : "Package2" },
			 * 		]
			 * }
			 * 注意member里的name并没有做排重处理。
			 */
			
			for each(var classInfo:Object in publishData.outputClasses) {
				
				_elements = new Object();
				for each(var member:Object in classInfo.members) {
//					alert = alert + "\n" + classInfo.className + "," + member.name + "," + member.type + "," + member.src;
					
					var key:String = member.type + "_" + member.name
					if(_elements.hasOwnProperty(key)){
						alert += "\n" + classInfo.className + "中存在相同的元件名字" + member.name;
						continue;
					}
					_elements[key] = 1
						
					if(member.pkg != null && member.pkg != "common"){ // 引用了非common包的内容
						alert += "\n" + classInfo.className + "中的" + member.name + "非法引用了" + member.pkg + "包中的" + member.src;
						continue;
					}
						
					var forbidenAlert:String = "";
//					alert += "\n" + member.name;
					for each(var ch:String in _forbidenCharArray){
						if(member.name.search(ch) == -1) // 不包含非法字符
							continue;
						
						forbidenAlert += "\" " + ch + " \",";
					}
					
					if(forbidenAlert != ""){
						alert += "\n" + classInfo.className + "中的" + member.name + "包含非法字符" + forbidenAlert;
					}
				}
			}
			
			return alert == "";
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
	}
}