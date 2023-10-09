({
    showPDF: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        var searchAction = component.get("c.openReceiptPdf");
        searchAction.setParams({     
            "receiptId": component.get("v.claimNumber")            
        });
        searchAction.setCallback(this, function(response) {
            var lst = response.getReturnValue();
            lst = lst.split(":");
            var type = lst[1];
            if (type=='application/pdf') {
                this.goToPDF(component, event, lst[0]);
            } else {
                component.set("v.ImageSrc",lst[0]);
            }
            $A.util.addClass(spinner, "slds-hide");
        });
        $A.enqueueAction(searchAction);
    },

    goToPDF: function(component, event, PDFData) {
		$A.createComponent(
            "c:TTI_PdfViewer",
            {
                "pdfData": PDFData
            },
            function(PDFViewer, status, errorMessage) {
                var pdfContainer = component.get("v.pdfContainer");
                pdfContainer.push(PDFViewer);
                component.set("v.pdfContainer", pdfContainer);
            }
		);	
	},
})