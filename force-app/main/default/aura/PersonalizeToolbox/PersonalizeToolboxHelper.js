({
	getName : function(component) {
		var action = component.get("c.getRunningContactName");
        
        action.setCallback(this, function(response){
            this.setName(response,component);
        });
        $A.enqueueAction(action);
	},
    
    setName : function(response, component){
        var fName = response.returnValue;
        var lastChar = fName[fName.length -1];
        
        if(lastChar == 's'){
            fName = fName + "'";
        }else{
            fName = fName + "'s";
        }
        component.set("v.Name",fName.toUpperCase());
    }
    
})