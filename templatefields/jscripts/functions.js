tinyMCEPopup.requireLangPack();

var templateFieldsDialog = {
	init : function(ed) {
		tinyMCEPopup.resizeToInnerSize();
	},

	insert : function(asTitle, aiLinkType, alFieldId, aiFieldReference, aiFieldType, asParameters) {
		var ed = tinyMCEPopup.editor, dom = ed.dom;
		var html = '<img src="../security/showImage.asp?CombinedLink=165,' + alFieldId + '" id="TemplateField|' + aiLinkType + '|' + aiFieldReference + '|' + aiFieldType + '|' + asParameters + '" alt="' + asTitle + '" title="' + asTitle + '" />';

		tinyMCEPopup.execCommand('mceInsertContent', false, html);
		tinyMCEPopup.close();
	}
};

tinyMCEPopup.onInit.add(templateFieldsDialog.init, templateFieldsDialog);
