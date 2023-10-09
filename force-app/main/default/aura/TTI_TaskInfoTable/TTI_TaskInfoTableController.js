({
    populateTaskInfoMethod : function(component, event, helper) {
        var action=component.get("c.getInCompletedTasks");
        action.setParams({
            "caseId":component.get("v.Service_Request_Case").Id
        });
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS' && response.getReturnValue()!=null)
            {
                component.set("v.TaskList",JSON.parse(response.getReturnValue()));
            }
            else
            {
                var TaskTableId=component.find("TaskTableId");
                if(TaskTableId!=null || TaskTableId!=undefined){
                TaskTableId.destroy();
                }
            }
        });
        $A.enqueueAction(action);
    },
    completeClicked:function(component,event,helper){
        var source=event.getSource();
        var index=source.get("v.labelClass");
        var TaskList=component.get("v.TaskList");
        var modal=component.find("modal");
        component.set("v.selectedTaskId",TaskList[index].Id);
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        component.find("edit").get("e.recordSave").fire();
        setTimeout(function(){ $A.util.toggleClass(modal,"slds-hide");$A.util.toggleClass(spinner, "slds-hide");
                             }, 1000);
        
    },
    closeModal:function(component,event,helper)
    {
        var modal=component.find("modal");
        $A.util.toggleClass(modal,"slds-hide");
    },
    toggleSection:function(component,event,helper)
    {
        var acc = component.find("section");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    }
})