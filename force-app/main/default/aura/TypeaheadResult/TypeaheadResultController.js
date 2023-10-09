({
    handleSelection : function(component, event, helper) {      
        var compEvent = component.getEvent("selectedValEvent");
        var selected = component.get("v.selectedValue");
        compEvent.setParams({"valueByEvent" : selected});   
        compEvent.fire();  
        console.log("Fired event onClick!");      
    }
})