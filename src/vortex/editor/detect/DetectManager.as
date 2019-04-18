package vortex.editor.detect
{
	import fairygui.editor.plugin.ICallback;
	import fairygui.editor.plugin.IFairyGUIEditor;
	import fairygui.editor.plugin.IPublishData;
	import fairygui.editor.plugin.IPublishHandler;
	
	import vortex.editor.plugin.IDetectHandler;
	import vortex.editor.utils.DebugUtil;
	import vortex.editor.plugin.IDetectHandler;
	
	public class DetectManager implements IPublishHandler
	{
		private var _handlerMap:Object = new Object();
		
		private var _editor:IFairyGUIEditor;
		private var _publishData:IPublishData;   
		private var _debugUtil:DebugUtil;
		private var _pkgName:String;
		private var _pkgPath:String;
		private var _alert:String = "";
		
		public function DetectManager(editor:IFairyGUIEditor)
		{
			_editor = editor;
		}
		
		public function doExport(publishData:IPublishData, callback:ICallback):Boolean
		{
			_publishData = publishData;
			
			_pkgName = _publishData.targetUIPackage.name;
			_pkgPath = _publishData.targetUIPackage.basePath;
			_debugUtil = new DebugUtil(_editor.project.basePath, "detect");
			
			_alert = "";
			doDetect(publishData, callback);
			
			return true;
		}
		
		public function doDetect(publishData:IPublishData, callback:ICallback):void
		{
			_debugUtil.ClearLog();
			_debugUtil.Log("start detect package " + _pkgName);

			for each(var handler:IDetectHandler in _handlerMap){
				_debugUtil.Log(handler.name + " start");
				handler.alert = ""; // 清空警告文本
				handler.doDetect(publishData);
				
				if(handler.alert != ""){
//					_alert = _alert + "\n" + _pkgName + "包的" + handler.name + "检测结果为" + handler.alert + "\n";		
					_alert = _alert + "\n" + handler.alert + "\n";	
				}

				_debugUtil.Log(handler.name + " finish");
			}
			
			if(_alert != ""){
				_debugUtil.LogError(_alert);
				
				callback.addMsg(_alert);
				callback.callOnSuccess();
				return;
			}
			
			callback.callOnSuccess();
		}
		
		/**
		 * 注册检测器
		 */
		public function registerDetectHandler(handler:IDetectHandler):Boolean{
			if(_handlerMap.hasOwnProperty(handler.name)){
				_debugUtil.LogError("注册了相同的IDetectHandler, name = " + handler.name);
				return false;
			}
			
			_handlerMap[handler.name] = handler;
			return true;
		}
	}
}