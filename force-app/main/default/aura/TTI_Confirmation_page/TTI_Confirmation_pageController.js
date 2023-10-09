({
    yesClicked : function(component, event, helper) {
        component.set("v.Yesclicked", true);
        const claim = component.get('v.claim');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": `/ttiservice/s/searchclaim?claimNumber=${claim.CaseNumber}`
        });
        urlEvent.fire();
    },
    noClicked : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            'url': '/'
        });
        urlEvent.fire();
    },
})