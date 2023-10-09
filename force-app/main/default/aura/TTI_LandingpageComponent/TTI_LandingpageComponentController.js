({
    redirectToSubmitClaim : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/submitclaim/"
        });
        urlEvent.fire();
        
    },
    
    redirectToTask : function(component, event, helper) {
        
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Task"
        });
        homeEvent.fire();
        
    },
    
    redirectToClaim : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/servicerequest"
        });
        urlEvent.fire();
        
    },
    
    redirectToSearchClaim : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/searchclaim/"
        });
        urlEvent.fire();
        
    },
    
    redirectToPermormance : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/my-performance/"
        });
        urlEvent.fire();
    },
    
    redirectToReplenishment : function(component, event, helper) {
        
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "TTI_Replenishment_Header__c"
        });
        homeEvent.fire();
        
    }
})