<%@ LANGUAGE="VBSCRIPT" %> 
<%option explicit%>

<!--#include file="../../../../lib/odbc.asp"-->
<!--#include file="../../../../lib/string.asp"-->
<!--#include file="../../../../lib/variables.asp"-->
<!--#include file="../../../../lib/constants.asp"-->
<!--#include file="../../../../lib/CheckLogon.asp"-->
<!--#include file="../../../../lib/common.asp"-->

<%
sub Initialise()
	dim sSQL
	dim rsTemp

	miTemplateLinkType = request.queryString("TemplateLinkType")

	if miTemplateLinkType = "" then 
		ws("You need to select object type on the document.")
		response.end
	end if

	sSQL = "Select Description, ObjectId, Reference, ParentObjectId From SEC_Object Where Reference = " & _
			FormatNumeric(miTemplateLinkType)
	Call ExecSQL(sSQL, rsObject)

	if not rsObject.EOF then
		if not(IsNull(rsObject("ParentObjectId"))) Then
			mbParentObject = True
			sSQL = "Select Description, ObjectId, Reference From SEC_Object Where ObjectId = " & rsObject("ParentObjectId")
			Call ExecSQL(sSQL, rsParentObject)
		end if
	end if

	sSQL = "Select ObjectId From SEC_Object Where Reference = " & OBJECT_TEMPLATE_CONFIG
	Call ExecSQL(sSQL, rsTemp)

	miConfigObjectId = rsTemp("ObjectId")

	iMode = MODE_ADD
end sub

const OBJECT_TEMPLATE_FIELD = 165
const OBJECT_TEMPLATE_CONFIG = 166

const MAX_PARAMETER_FIELDS = 20
const TYPE_SYSTEM_FIELD = 2

dim sSQL
dim rsField
dim rsParameter
dim rsObject
dim rsParentObject
dim miTemplateLinkType
dim moTab
dim sHTML
dim iLoop
dim iLoopObject
dim iLoopReference
dim miConfigObjectId
dim sControl
dim i
dim sButtons
dim sParameters
dim sFilter
dim sTmp
dim mbParentObject
dim bIgnore

	Call Connect()

	Call Initialise()

	response.write(PageHeader("Template Fields", ""))
%>
<script language="javascript" type="text/javascript" src="../../tiny_mce_popup.js"></script>
<script language="javascript" type="text/javascript" src="jscripts/functions.js"></script>
<base target="_self" />
<SCRIPT LANGUAGE="JavaScript">
function cboField_OnChange()
{
	var i;
	var iIndex = 0;
	var doc = document.frmInput;
	var sParameters = doc.cboField.options[doc.cboField.selectedIndex].id;
	var aTmp;

	for(i = 0; i < <%=MAX_PARAMETER_FIELDS%>; i++) document.getElementById('divParameter' + i).style.display = 'none';

	if (sParameters != '')
	{
		var aParameters = sParameters.split('|');
		for(i = 0; i < aParameters.length; i = i + 2) 
		{
			document.getElementById('txtParameterCaption' + iIndex).innerHTML = aParameters[i];
			document.getElementById('txtParameter' + iIndex).parameterId  = aParameters[i+1];

			document.getElementById('divParameter' + iIndex).style.display = 'block';

			iIndex ++;
		}
	}

	if (doc.cboField.value == '0') document.getElementById('divHelp').innerHTML = '';
	else
	{
		aTmp = doc.cboField.value.split('|');

		document.getElementById('divHelp').innerHTML = unescape(aTmp[4]);
	}

	doc.txtParameterCount.value = iIndex;
}

function cmdInsert_OnClick()
{
	var doc = document.frmInput;
	var sValue;
	var sId;
	var sParameters = '';
	var sCaption;
	var aTmp;

	if (doc.cboField.value != '0')	
	{
		for(var i = 0; i < doc.txtParameterCount.value - 0; i++) 
		{
			sId = document.getElementById('txtParameter' + i).parameterId;
			sValue = document.getElementById('txtParameter' + i).value;

			if (sParameters != '') sParameters = sParameters + '|';
			sParameters = sParameters + sId + '|' + sValue;
		}
		sCaption = doc.cboField.options[doc.cboField.selectedIndex].text;

		aTmp = doc.cboField.value.split('|');

		templateFieldsDialog.insert(sCaption, aTmp[0], aTmp[1], aTmp[2], aTmp[3], sParameters);
	}
}
</SCRIPT>

<body style="display: none">
<FORM ACTION="doNothing.Asp" Method="POST" Name="frmInput">
<%
response.write("<INPUT TYPE=HIDDEN NAME='txtParameterCount' VALUE='0'>" & vbCrLf)

sButtons = "<INPUT TYPE='button' class='Button' NAME='cmdSave' VALUE=' Insert ' onClick='cmdInsert_OnClick()'>"

response.write(InitHeading(1,"Template Fields", sButtons))
response.write("<BR Clear='All'>")

sHTML = "<TABLE BORDER=0 WIDTH='100%' CELLPADDING=2 CELLSPACING=0>"

sControl = "<SELECT NAME='cboField' OnChange='cboField_OnChange()'>" & _
		"<OPTION ID='' VALUE='0'>[Select Field To Insert...]"

for iLoop = 1 to 3
	bIgnore = False

	select case cint(iLoop)
	case 1
		if CurrencyDefault(miTemplateLinkType) > 0 then
			iLoopObject = rsObject("ObjectId")
			iLoopReference = rsObject("Reference")
			sFilter = " ASMS_ObjectTemplateField.ObjectId = " & iLoopObject & " " & _
					" And ASMS_ObjectTemplateField.TypeId <> " & TYPE_SYSTEM_FIELD & " "

			sControl = sControl & _
				"<OPTION style='background-color:#0080C0;color:white;' ID='' VALUE='0'>" & _
				rsObject("Description") & " Detail Fields"
		else
			bIgnore = True
		end if

	case 2
		if mbParentObject Then
			iLoopObject = rsParentObject("ObjectId")
			iLoopReference = rsParentObject("Reference")
			sFilter = " ASMS_ObjectTemplateField.ObjectId = " & iLoopObject & " " & _
					" AND ASMS_ObjectTemplateField.TypeId <> " & TYPE_SYSTEM_FIELD & " "

			sControl = sControl & _
				"<OPTION style='background-color:#008040;color:white;' ID='' VALUE='0'>" & rsParentObject("Description") & " Detail Fields"
		else
			bIgnore = True
		end if

	case 3
		iLoopObject = miConfigObjectId
		iLoopReference = OBJECT_TEMPLATE_CONFIG
		sFilter = " ASMS_ObjectTemplateField.TypeId = " & TYPE_SYSTEM_FIELD & " "

		if CurrencyDefault(miTemplateLinkType) = 0 then
			'blocks fields only allowed for objects - like current copy
			sFilter = sFilter & _
				" And ASMS_ObjectTemplateField.RequiresObject = 'N' "
		end if

		sControl = sControl & _
			"<OPTION style='background-color:#FF8000;color:white;' ID='' VALUE='0'>Standard Fields"
	end select

	if not(bIgnore) Then
		sSQL = "Select ASMS_ObjectTemplateField.Title, ASMS_ObjectTemplateField.Reference, ASMS_ObjectTemplateField.Notes, " & _
			"ASMS_ObjectTemplateField.FieldId, ASMS_ObjectTemplateField.TypeId " & _
			" From ASMS_ObjectTemplateField " & _
			" WHERE " & _
				sFilter & _
			"Order By ASMS_ObjectTemplateField.Title"
		Call ExecSQL(sSQL, rsField)
	
		do until rsField.EOF
			sSQL = "Select Title, Reference " & _
				"From ASMS_ObjectTemplateFieldParameter " & _
				"Where FieldId = " & rsField("FieldId") & " " & _
				"Order By ParameterId"
			Call ExecSQL(sSQL, rsParameter)
	
			sParameters = ""
	
			do until rsParameter.EOF
				if sParameters <> "" Then
					sParameters = sParameters & "|"
				end if
	
				sParameters = sParameters & _
					rsParameter("Title") & "|" & rsParameter("Reference")
	
				rsParameter.MoveNext
			loop
	
			sTmp = rsField("Notes")
			sTmp = Replace(sTmp, "'", "&#39;")
			sTmp = Server.HTMLEncode(sTmp)
	
			sControl = sControl & _
				"<OPTION ID='" & sParameters & "' VALUE='" & iLoopReference & "|" & rsField("FieldId") & "|" & rsField("Reference") & _
					"|" & currencydefault(rsField("TypeId")) & "|" & sTmp & "'>&nbsp;" & rsField("Title")
	
			rsField.MoveNext
		loop
	end if
next

sControl = sControl & _
	"</SELECT>"

sHTML = sHTML & _
	"<TR><TD Width='30%'>Field</TD><TD>" & sControl & "</TD></TR>" & _
	"</TABLE>"

sHTML = sHTML & _
	"<BR Clear='All'>"

for i = 0 to MAX_PARAMETER_FIELDS - 1
	sHTML = sHTML & _
		"<DIV ID='divParameter" & i & "' STYLE='display: none;'>" & _
		"<TABLE BORDER=0 WIDTH='100%' CELLPADDING=2 CELLSPACING=0>" & _
		"<TR><TD Id='txtParameterCaption" & i & "' Width='30%'>&nbsp;</TD>" & _
		"<TD><INPUT TYPE='TEXT' name='txtParameter" & i & "' id='txtParameter" & i & "' SIZE='20' MAXLENGTH='50' VALUE=''></TD></TR>" & _
		"</TABLE>" & _
		"</DIV>"
next

response.write(sHTML)

response.write("<DIV ID='divHelp' STYLE='display: block;'></div>")

response.write(PageFooter(""))
%>
</FORM>
</body>
</html>
