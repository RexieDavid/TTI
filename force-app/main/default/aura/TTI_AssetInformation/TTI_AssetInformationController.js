({
    toggleSection:function(component,event,helper)
    {
        var acc = component.find("section");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    },
    openReceipt:function(component,event,helper)
    {
        var Service_Request_Case=component.get("v.Service_Request_Case");
        var action=component.get("c.openReceiptPdf");
        window.open("https://sboxfull-ttibrandsanz.cs72.force.com/ttiservice/s/claimreceipt?type=receipt&claimNumber="+Service_Request_Case.Asset.Receipt__c);
            
        
    }
    
})