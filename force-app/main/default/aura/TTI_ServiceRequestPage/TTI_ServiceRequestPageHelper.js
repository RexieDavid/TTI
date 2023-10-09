({
    LABELS: {
        New: 'Case Number,Priority,Date Opened,Retailer Account,Customer Account,Brand,Product Number,Serial Number',
        Awaiting_Approval: 'Case Number,Priority,Claim Type,Diagnosed Date,Diagnosed User,Retailer Account,Customer Account,Brand,Product Number,Serial Number',
        In_Progress: 'Case Number,Priority,Claim Type,Approval Date,Diagnosed User,Retailer Account,Customer Account,Brand,Product Number,Serial Number',
        Completed: 'Case Number,Claim Type,Completed Date,Diagnosed User,Retailer Account,Customer Account,Brand,Product Number,Serial Number',
        Closed: {
            Internal: 'Case Number,Claim Type,Closed Date,Diagnosed User,Retailer Account,Customer Account,Brand,Product Number,Serial Number,Invoice Number',
            External: 'Case Number,Claim Type,Closed Date,Diagnosed User,Retailer Account,Customer Account,Brand,Product Number,Serial Number,Invoice Number,Invoice Amount,View Invoice'
        },
        Rejected: 'Case Number,Claim Type,Closed Date,Diagnosed User,Retailer Account,Customer Account,Brand,Product Number,Serial Number,Closed Reason'
    },

    FIELDS: {
        New: 'CaseNumber,Priority,CreatedDate,Retailer_Account__r.Name,TTI_Customer_Account__r.Name,Brand__c,Product_Name__r.ProductCode,Serial_Number__c,TTI_Service_Agent_Job_Number__c',
        Awaiting_Approval: 'CaseNumber,Priority,Claim_Type__c,Diagnosed_Date__c,Diagnosed_User__r.Name,Retailer_Account__r.Name,TTI_Customer_Account__r.Name,Brand__c,Product_Name__r.ProductCode,Serial_Number__c,TTI_Service_Agent_Job_Number__c',
        In_Progress: 'CaseNumber,Priority,Claim_Type__c,Approved_Date__c,Diagnosed_User__r.Name,Retailer_Account__r.Name,TTI_Customer_Account__r.Name,Brand__c,Product_Name__r.ProductCode,Serial_Number__c,TTI_Service_Agent_Job_Number__c',
        Completed: 'CaseNumber,Claim_Type__c,Completion_Date__c,Diagnosed_User__r.Name,Retailer_Account__r.Name,TTI_Customer_Account__r.Name,Brand__c,Product_Name__r.ProductCode,Serial_Number__c,TTI_Service_Agent_Job_Number__c',
        Closed: "CaseNumber,Claim_Type__c,ClosedDate,Diagnosed_User__r.Name,Retailer_Account__r.Name,TTI_Customer_Account__r.Name,Brand__c,Product_Name__r.ProductCode,Serial_Number__c,Total_Invoice_Amount__c,Invoice_Number_PC__c",
        Rejected: 'CaseNumber,Claim_Type__c,Completion_Date__c,Diagnosed_User__r.Name,Retailer_Account__r.Name,TTI_Customer_Account__r.Name,Brand__c,Product_Name__r.ProductCode,Serial_Number__c,Closed_Reason__c,TTI_Service_Agent_Job_Number__c'
    },

    FIELD_TYPE: {
        New: 'Link,Image,Date,Text,Text,Text,Text,Text',
        Awaiting_Approval: 'Link,Image,Text,Date,Text,Text,Text,Text,Text,Text,Text',
        In_Progress: 'Link,Image,Text,Date,Text,Text,Text,Text,Text,Text,Text',
        Completed: 'Link,Text,Date,Text,Text,Text,Text,Text,Text',
        Closed: {
            Internal: 'Link,Text,Date,Text,Text,Text,Text,Text,Text,Text',
            External: 'Link,Text,Date,Text,Text,Text,Text,Text,Text,Text,Currency,IMAGEURL',
        },
        Rejected: 'Link,Text,Date,Text,Text,Text,Text,Text,,Text,Text',
    },

    WHERE_CLAUSE: {
        New: "CreatedDate = LAST_N_DAYS:<purchase_date> AND Service_Request_Milestone__c ='New' ORDER BY CreatedDate ASC",
        Awaiting_Approval: "CreatedDate = LAST_N_DAYS:<purchase_date> AND Service_Request_Milestone__c ='Awaiting Approval' ORDER BY CreatedDate ASC",
        In_Progress: "CreatedDate = LAST_N_DAYS:<purchase_date> AND Service_Request_Milestone__c ='In Progress' ORDER BY CreatedDate ASC",
        Completed: "CreatedDate = LAST_N_DAYS:<purchase_date> AND (Service_Request_Milestone__c ='Invoice Awaiting Approval'OR Service_Request_Milestone__c ='Completed')  ORDER BY Completion_Date__c DESC",
        Closed: "CreatedDate = LAST_N_DAYS:<purchase_date> AND Service_Request_Milestone__c ='Closed' AND Closed_Reason__c='Service Request Completed' ORDER BY Completion_Date__c DESC",
        Rejected: "CreatedDate = LAST_N_DAYS:<purchase_date> AND Service_Request_Milestone__c ='Closed' AND Closed_Reason__c !='Service Request Completed' ORDER BY Completion_Date__c DESC"
    },

    displayListView: function(component, claimType) {
        let spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");

        const header = `${claimType} Claims`;
        claimType = claimType.replace(' ', '_');

        let dateOpenedFilter;
        const openClaimsStatus = ['New', 'Awaiting_Approval', 'In_Progress'];

        if (openClaimsStatus.indexOf(claimType) >= 0) {
            dateOpenedFilter = component.get("v.dateOpenedFilterOpenClaims");
        } else {
            dateOpenedFilter = component.get("v.dateOpenedFilterClosedClaims");
        }
        component.set('v.dateOpenedFilter', dateOpenedFilter);

        const whereQuery = this.WHERE_CLAUSE[claimType].replace('<purchase_date>', dateOpenedFilter);
        const fields = this.FIELDS[claimType];

        let action = component.get("c.getCasedeatils");
        action.setParams({
            'whereQuery': whereQuery,
            'fields': fields
        });
        action.setCallback(this, function(response) {
            $A.util.addClass(spinner, "slds-hide");
            if (response.getState() == 'SUCCESS') {
                let ShowLandingPage = component.find("ShowLandingPage");
                ShowLandingPage.destroy();
                let contentHeading = component.find("contentHeading");
                contentHeading.destroy();

                component.set("v.showListView", true);
                let claims = JSON.parse(response.getReturnValue());
                this.populateClaimPriorityAndInvoiceLink(component, claims, claimType);
                
                const agentType = component.get('v.userType.Account.Internal_Service_Agent__c') ? 'Internal' : 'External';
                component.set('v.listViewObj', {
                    claimType: claimType,
                    header: header,
                    fields: claimType === 'Closed' ? `${this.FIELDS[claimType]},InvoiceLink` : this.FIELDS[claimType],
                    fieldType: claimType === 'Closed' ? this.FIELD_TYPE.Closed[agentType] : this.FIELD_TYPE[claimType],
                    whereClause: this.WHERE_CLAUSE[claimType],
                    labels: claimType === 'Closed' ? this.LABELS.Closed[agentType] : this.LABELS[claimType],
                    data: claims
                });
            }

        });
        $A.enqueueAction(action);
    },
    
    populateClaimPriorityAndInvoiceLink: function(component, claims, claimType) {
        claims.forEach(claim => {
            if (claim.Priority === 'Low') {
                claim.Priority =  component.get("v.imageLow");
            } else if (claim.Priority === 'Medium') {
                claim.Priority = component.get("v.imageMedium");
            } else if (claim.Priority === 'High') {
                claim.Priority =  component.get("v.imageHigh");
            } else if (claim.Priority === 'Critical') {
                claim.Priority =  component.get("v.imageCritical"); 
            }

            if (claimType === 'Closed') {
                if (claim.Invoice_Number_PC__c != null && claim.Total_Invoice_Amount__c > 0) {
                    claim.InvoiceLink = '/ttiservice/s/claimreceipt?type=invoice&claimNumber=' + claim.Id;
                } else {
                    claim.InvoiceLink = null; 
                }
            }
        });
    }
})