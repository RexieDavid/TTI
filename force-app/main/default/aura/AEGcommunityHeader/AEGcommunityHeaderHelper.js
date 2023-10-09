({
	showHeaderAndTitle : function(component) {
		var action = component.get("c.getCommunityHeader");
         
       	action.setParams({ pageName : component.get("v.PageName") });

        action.setCallback(this, function(response){
            this.setHeaderDetails(response,component);
        });
        $A.enqueueAction(action);

    
        var action2 = component.get("c.getCommunitySettings");
        action2.setStorable();
        action2.setCallback(this, function(response){
            this.receiveCommunitySettings(response,component);
        });
        $A.enqueueAction(action2);
    	
       

    },
    receiveCommunitySettings : function(response, component){
 		component.set('v.siteSettings',response.getReturnValue());
        
    },
        
    setHeaderDetails : function(response, component){
        
        var r = response.getReturnValue();
        component.set("v.Header",r[0]);
        component.set("v.Title",r[1]);
        
        if(r.length>2){
        	component.set("v.ImageURL",r[2]);            
        }
        
    }
    
})