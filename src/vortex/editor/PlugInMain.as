package vortex.editor
{
    import fairygui.editor.plugin.IFairyGUIEditor;
    
    import vortex.editor.detect.DetectElementHandler;
	import vortex.editor.detect.DetectPackageHandler;
	import vortex.editor.detect.DetectFolderStructHandler;
	import vortex.editor.detect.DetectComponentHandler;	
    import vortex.editor.detect.DetectManager;

    /**
     * 插件入口类，名字必须为PlugInMain。每个项目打开都会创建一个新的PlugInMain实例，并传入当前的编辑器句柄；
     * 项目关闭时dispose被调用，可以在这里处理一些清理的工作（如果有）。
     */
    public class PlugInMain
    {
        private var _editor:IFairyGUIEditor;
		private var _detectManager:DetectManager; 

        public function PlugInMain(editor:IFairyGUIEditor)
        {
			_editor = editor;
			
			initDetector(_editor);

			_editor.registerPublishHandler(_detectManager);
        }

        public function dispose():void
        {
			
        }
		
		/**
		 * 初始化以及注册检测器
		 */
		public function initDetector(editor:IFairyGUIEditor):void{
			_detectManager = new DetectManager(editor);
			_detectManager.registerDetectHandler(new DetectFolderStructHandler(editor));
			_detectManager.registerDetectHandler(new DetectPackageHandler(editor));
			_detectManager.registerDetectHandler(new DetectElementHandler(editor));
			_detectManager.registerDetectHandler(new DetectComponentHandler(editor));
		}
    }
}