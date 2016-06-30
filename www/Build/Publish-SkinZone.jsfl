var sScriptPath = fl.scriptURI;
var sJsFile = "Publish-SkinZone.jsfl";
var sProjectName = "SkinZone.flp";
var sSystemName = "System.fla";
var sSzContent = "SkinZone.fla";
var sErrorLogName = "ErrorLog.txt";
var sProjectPath = (sScriptPath.split("/Build/")[0] + "/");
var sErrorLogPath = (sScriptPath.split(sJsFile)[0] + sErrorLogName);
var sSystemPath = sProjectPath + sSystemName;
var sSzContent = sProjectPath + "Swf/Movies/" + sSzContent;

fl.saveAll();
fl.outputPanel.clear();
fl.outputPanel.trace("JavaScript Execution Path: " + sScriptPath);
fl.outputPanel.trace("ProjectPath Path: " + sProjectPath);
fl.outputPanel.trace("Publishing SkinZone Project: " + sSzContent);

var oSnContent = fl.openDocument(sSzContent);
oSnContent.publish();
//fl.closeDocument(oSnContent);
//var oSystem = fl.openDocument(sSystemPath);
//oSystem.publish();
//fl.closeDocument(oSystem);

fl.openProject(sProjectPath);

var AirwolfProject = fl.getProject();
var items = AirwolfProject.items;
for ( i = 0 ; i < items.length ; i++ ) {
    items[i].publishProfile = "FL30Release";
	fl.outputPanel.trace("ITEM: " + items[i]);
}

AirwolfProject.publishProject();

for ( i = 0 ; i < items.length ; i++ ) {
    items[i].publishProfile = "Desktop";
	fl.outputPanel.trace("ITEM1: " + items[i]);
}


fl.closeProject();