/**
 * $Id: editor_plugin_src.js 520 2008-07-10 11:00:00Z chud $
 *
 * @author ibCom
 * @copyright Copyright � 2004-2008, ibCom, All rights reserved.
 */

(function() {
	tinymce.create('tinymce.plugins.templateFieldsPlugin', {
		init : function(ed, url) {
			var TemplateLinkType = tinyMCE.activeEditor.getParam("TemplateLinkType");

			// Register commands
			ed.addCommand('mcetemplateFields', function() {
				ed.windowManager.open({
					file : url + '/templateFields.asp?TemplateLinkType=' + TemplateLinkType,
					width : 500,
					height : 600,
					inline : 1
				}, {
					plugin_url : url
				});
			});

			// Register buttons
			ed.addButton('templateFields', {title : 'templateFields.templateFields_desc', cmd : 'mcetemplateFields', image:  url + '/img/templateFields.gif'});
		},

		getInfo : function() {
			return {
				longname : 'templateFields',
				author : 'ibCom',
				authorurl : 'http://ibcom.com.au',
				infourl : 'http://ibcom.com.au',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('templateFields', tinymce.plugins.templateFieldsPlugin);
})();