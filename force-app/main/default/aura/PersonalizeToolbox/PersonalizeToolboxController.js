({
	doInit : function(component, event, helper) {
        console.log('doInit started');
        
        helper.getName(component);

        console.log('doInit finished');     
    },
})