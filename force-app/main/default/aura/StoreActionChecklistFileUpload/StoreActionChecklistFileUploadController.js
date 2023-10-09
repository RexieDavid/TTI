({
    initializeFileUpload: function (component) {
       
        // Find the component whose aura:id is "flowId"
        var flow = component.find("flowId")
        var recordidevent = component.get("v.recordIdFileUpload")
        var inputVariables = [
        {
            name : "recordId",
            type : "String",
            value : component.get("v.recordIdFileUpload")
        }
        ];
        console.log(recordidevent)
        flow.startFlow("Upload_File_to_Record", inputVariables);
    },


//Not Used
    handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");

        // var items = component.get("v.items");

        // for (var i=0; i<uploadedFiles.length; i++){
        //     items.push({
        //         name: uploadedFiles[i].documentId,
        //         label: uploadedFiles[i].name
        //     });
        // }

        //alert("Files uploaded : " + uploadedFiles.length);

        // component.set("v.items", items)


        // Get the file name
        // uploadedFiles.forEach(file => console.log(file.name));
    },

    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            component.set('v.showFinish', true);
            var compEvent = component.getEvent("storeEvent");
            compEvent.setParams({
                "isFinish" : true  
            });
            compEvent.fire();
        }
    },   

    closeQuickAction: function (cmp, event, helper) {

        $A.get("e.force:closeQuickAction").fire();

    }
})