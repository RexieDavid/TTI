({
    doInit : function(component, event, helper) {
        var caseId = component.get("v.Service_Request_Case");
        var getApprovalLastComment = component.get("c.getApprovalProcessLastStep");

        getApprovalLastComment.setParams({
            'targetObjectId' : caseId.Id
        });

        getApprovalLastComment.setCallback(this, function(response) {
            if(response.getState() == 'SUCCESS') {
                var result = JSON.parse(response.getReturnValue());
                if(result != null) {
                    component.set("v.approval", result);
                    component.set("v.hasComments", true);
                }                    
            }
        });

        $A.enqueueAction(getApprovalLastComment);
    },

    assignToMe : function(component, event, helper) {
        
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var action=component.get("c.getCurrentUser");
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS' && response.getReturnValue()!=null)
            {
                var ServiceReqCase=component.get("v.Service_Request_Case");
                var strUserDetails=response.getReturnValue();
                var lstUserDetails=strUserDetails.split(":");
                ServiceReqCase.OwnerId=lstUserDetails[0];
                ServiceReqCase.Owner.Name=lstUserDetails[1];
                component.set("v.Service_Request_Case",ServiceReqCase);
                $A.util.toggleClass(spinner, "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },
    claimTypeChanged:function(component,event,helper)
    {
        var oldValue= event.getParam("oldValue");
        var newValue= event.getParam("value");
        if(oldValue=='Non-Warranty' && newValue=='Warranty')
        {
            var NonWarrantyLineItemsList=component.get("v.NonWarrantyLineItemsList");
            if(NonWarrantyLineItemsList.length>0)
            {
                component.set("v.claimTypeFlag",false);
                var Service_Request_Case=component.get("v.Service_Request_Case");
                Service_Request_Case.Claim_Type__c=oldValue;
                component.set("v.Service_Request_Case",Service_Request_Case);
                var selectCmp = component.find("claimType");
                selectCmp.set("v.errors",[{message:"Please remove all the non-warranty line items prior to changing this claim to Warranty"}]);
            }
            else
            {
                component.set("v.claimTypeFlag",true);
            }
            //window.scrollTo(0, document.body.scrollHeight);
        }
        
        
    },
    setClaimType:function(component,event,helper)
    {
        if(component.get("v.claimTypeFlag")==false) return;
        var Service_Request_Case=component.get("v.Service_Request_Case");
        var selectCmp = component.find("claimType");
        selectCmp.set("v.errors",null);
        Service_Request_Case.Claim_Type__c=selectCmp.get("v.value");
        component.set("v.Service_Request_Case",Service_Request_Case);
    },
    toggleSection:function(component,event,helper)
    {
        var acc = component.find("section");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    }
})