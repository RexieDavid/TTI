({
	yesClicked : function(component, event, helper) {
		component.set("v.flag",false);
        var functionToRunObject=component.get("v.functionToRunObject");
        functionToRunObject.run();
	},
    noClicked : function(component, event, helper) {
		component.set("v.flag",false);
        var functionToRunObject=component.get("v.functionToRunObject");
        functionToRunObject.Norun();
	},
    ModalClicked:function(component,event,helper){
        component.set("v.flag",event.getParam("OpenModal"));
        component.set("v.Message",event.getParam("question"));
        component.set("v.ButtonNames",event.getParam("buttonNames"));
		component.set("v.functionToRunObject",event.getParam("functionToRunObject"));        
    }
    
})