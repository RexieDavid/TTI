({
    doInit:function(component){
        var date=new Date();
        date.setDate(date.getDate() + 1);
        if(date.getDay()==0)
        {
            date.setDate(date.getDate() + 1);
        }
        if(date.getDay()==1)
        {
            date.setDate(date.getDate() +2);
        }
        component.set("v.freightCompanyDate",date);
    },
    yesClicked : function(component, event, helper) {
       
        var urlEvent = $A.get("e.force:navigateToURL"); 
        window.open('/ttiservice/s/claimreceipt?claimNumber='+component.get("v.claim.Id")+'&type=receipt');
        component.set("v.activeScreenId","9");
        
        
    },
    noClicked : function(component, event, helper) {
        component.set("v.activeScreenId","9");
    }
})