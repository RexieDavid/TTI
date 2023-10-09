/**
* @author: Stephen James Laylo
* @date: Apr 2017
* @description: This class handles all CRUD operations for the
* Attachment Trigger. All logic should be placed here and not in the
* trigger itself
*/
public class AttachmentTriggerHandler {

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles all on Before Insert
	* functionalities of the Attachment
	*/
	public static void onBeforeInsert(List<Attachment> newAttachments) {
		updateParentId(newAttachments);
	}

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles all on After Insert
	* functionalities of the Attachment
	*/
	public static void onAfterInsert(List<Attachment> newAttachments, List<Attachment> oldAttachments, Map<Id, Attachment> oldAttachmentsMap) {
		updateOpportunityDocumentAttachedCheckbox(newAttachments, oldAttachments, oldAttachmentsMap);
	}

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles all on After Delete
	* functionalities of the Attachment
	*/
	public static void onAfterDelete(List<Attachment> newAttachments, List<Attachment> oldAttachments, Map<Id, Attachment> oldAttachmentsMap) {
		updateOpportunityDocumentAttachedCheckbox(new List<Attachment>(), oldAttachments, oldAttachmentsMap);
	}

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles all on After Undelete
	* functionalities of the Attachment
	*/
	public static void onAfterUndelete(List<Attachment> newAttachments, List<Attachment> oldAttachments, Map<Id, Attachment> oldAttachmentsMap) {
		updateOpportunityDocumentAttachedCheckbox(newAttachments, oldAttachments, oldAttachmentsMap);
	}

	/**
	* @author: Jerome Liwanag
	* @date: Sep 2017
	* @description: This method handles the assignment of
	* parent Id of attachment if from Email
	*/
	public static void updateParentId(List<Attachment> newAttachments) {
		Set<Id> parentIds = new Set<Id>();
		for (Attachment attachLoop : newAttachments) {
			if (attachLoop.parentId != null) {
				parentIds.add(attachLoop.parentId);
			}
		}

		if (parentIds.isEmpty()) {
			return;
		}

		Map<Id, EmailMessage> emailMessageMap = new Map<Id, EmailMessage>([SELECT Id, ParentId FROM EmailMessage WHERE ID IN :parentIds]);

		for (Attachment attachLoop : newAttachments) {
			if (TTIUtilClass.findObjectNameFromRecordIdPrefix(attachLoop.ParentId) == 'EmailMessage') {
				attachLoop.ParentId = emailMessageMap.get(attachLoop.ParentId).ParentId;
			}
		}
	}

	/**
	* @author: Stephen James Laylo
	* @date: Apr 2017
	* @description: This method handles the flag of Document Attached field in Opportunity
	*/
	public static void updateOpportunityDocumentAttachedCheckbox(List<Attachment> newAttachments, List<Attachment> oldAttachments, Map<Id, Attachment> oldAttachmentsMap) {
		Map<Id, List<Attachment>> parent = new Map<Id, List<Attachment>>();
		Set<Id> opportunityIds = new Set<Id>();

		if (!newAttachments.isEmpty()) {
			for (Attachment c : newAttachments) {
				Opportunity l;
				if (c.ParentId != null) {
					opportunityIds.add(c.ParentId);
				}
			}

		} else if (!oldAttachments.isEmpty()) {
			for (Attachment c : oldAttachments) {
				if (c.ParentId != null && oldAttachmentsMap.containsKey(c.Id)) {
					opportunityIds.add(oldAttachmentsMap.get(c.Id).ParentId);
				}
			}
		}

		if (opportunityIds.size() > 0) {
			try {
				List<Opportunity> opportunities = [SELECT Id, Document_Attached__c FROM Opportunity WHERE Id IN :opportunityIds];

				update opportunities;

			} catch (Exception e) {
				System.debug(e);
			}
		}
	}

}