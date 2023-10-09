({
    doInit : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        
        // //option 1 QR code contains the URL
        // if (component.get("v.UrlType") == "Full S1 URL"){
        //     urlEvent.setParams({
        //         "url": "scan://scan"
        //     });
        // }
        
        // //option 2 QR codes contains just the record Id 
        // else if (component.get("v.UrlType") == "Id Only"){
        //     var url = "scan://scan?callback="+encodeURIComponent("salesforce1://sObject/SCANNED_DATA/view");
        //     urlEvent.setParams({
        //         "url": url
        //     });
        // }
        
        // //use an custom field using a special VF page to search and redirect to the object
        // else if (component.get("v.UrlType") == "Custom Field"){
            
        //     var callback = component.get("v.baseURL")
        //       + "/apex/BarCodeSearch?objectName=" + component.get("v.CustomObject") 
        //       + "&fieldName=" + component.get("v.CustomField")
        //       + "&fieldValue=SCANNED_DATA";
            
        //     //alert(callback);
            
        //     var url = "scan://scan?callback=" + encodeURIComponent(callback);    
        //     //alert(url);
            
        //     urlEvent.setParams({
        //         "url": url
        //     });
        // }

        var url;
        var isAndroid = $A.get("$Browser.isAndroid");
        if (isAndroid) {
            url = "scan://scan?callback=com.salesforce.chatter://sObject/SCANNED_DATA/view";
        } else {
            var callback = component.get("v.baseURL")
              + "/apex/BarCodeSearch?objectName=" + component.get("v.CustomObject") 
              + "&fieldName=" + component.get("v.CustomField")
              + "&fieldValue=SCANNED_DATA";
            
            url = "scan://scan?callback=" + encodeURIComponent(callback);
            // url = "scan://scan?callback=" + callback;
            // alert('CALLBACK > ' + callback);
        }
        
        component.set("v.messageText", "Opening the QR scanner. If it doesn't load right away, just scroll down to refresh.");

        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
        
        
    }
})