({
    submitSegmentationDetails : function(component) {

        // console.log('DBG: inside handleShowModal');
        // var modalBody;
        // $A.createComponent("c:rysldstestpopup", { "modalId" : "modalForSessionMgmt" },
        //     function(content, status, err) {
        //         console.log('DBG: content >>> ' + content);
        //         console.log('DBG: status >>> ' + status);
        //         if (status === "SUCCESS") {
        //             modalBody = content;
        //             // component.find('overlayLib').showCustomModal({
        //             //     header: "CONGRATULATIONS!",
        //             //     body: modalBody, 
        //             //     showCloseButton: true,
        //             //     cssClass: "mymodal",
        //             //     closeCallback: function() {
        //             //         // alert('You closed the alert!');
        //             //     }
        //             // })
        //             console.log('DBG: modalBody > ', modalBody);
        //             var modal = component.find('modalForSessionMgmt');
        //             console.log('DBG: modal > ', modal);

        //             var body = component.get("v.body");
        //             body.push(content);
        //             component.set("v.body", body);

        //             console.log('DBG: body >>> ', JSON.stringify(body, null, '\t'));
        //         }
        //     }
        // );


        component.set('v.attendee.FirstName', document.getElementById("firstName").value);
        component.set('v.attendee.LastName', document.getElementById("lastName").value);
        component.set('v.attendee.PersonEmail', document.getElementById("email").value);
        component.set('v.attendee.PersonMobilePhone', document.getElementById("mobilePhone").value);

        console.log('DBG: attendee >>> ', JSON.stringify(component.get('v.attendee'), null, '\t'));
        console.log('DBG: confidenceLevel >>> ', component.find('confidenceLevel').get('v.value'));
        console.log('DBG: skillLevel >>> ', component.find('skillLevel').get('v.value'));

        var action = component.get("c.submitSegmentationDetailsApex");
        action.setParams({
            'attendee' : component.get('v.attendee'),
            'confidenceLevel' : component.find('confidenceLevel').get('v.value'),
            'skillLevel' : component.find('skillLevel').get('v.value')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('DBG: state > ', state);
            console.log('DBG: error > ', JSON.stringify(response.getError(), null, '\t'));
            if (state === "SUCCESS") {
                console.log('DBG: PERSON ACCOUNT & MARKETING CAMPAIGN CREATED > ', response.getReturnValue());
                // var toastEvent = $A.get("e.force:showToast");
                // toastEvent.setParams({
                //     "title": "Success!",
                //     "message": "Survey complete."
                // });
                // toastEvent.fire();

                component.find("modal").open(
                    'SessionMgmt',
                    response.getReturnValue()
                );
            }
            if (state === "ERROR") {
                // TODO

                // var toastEvent = $A.get("e.force:showToast");
                // toastEvent.setParams({
                //     "title": "Failed!",
                //     "message": "Survey failed to submit.",
                //     "type": "error"
                // });
                // toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    }
})