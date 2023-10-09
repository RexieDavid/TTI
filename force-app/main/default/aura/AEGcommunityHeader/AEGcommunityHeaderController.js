({
	doInit : function(component, event, helper) {
        console.log('doInit started...');
        
        if (component.get('v.UseStatic')){
            component.set("v.Header",component.get('v.StaticHeader'));
       		component.set("v.Title",component.get('v.StaticTitle'));
        }
        else{
        	helper.showHeaderAndTitle(component);
		}
        console.log('doInit finished');     
    },
    
})