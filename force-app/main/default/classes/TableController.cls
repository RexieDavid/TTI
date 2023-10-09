/**
* @author: Francis Nasalita
* @date: March 2018
* @description: This class handles logic for Table component
*/
public class TableController {

	@AuraEnabled
	public static String getFieldSet(String fieldSetApiName, String objectName) {
		List<Schema.FieldSetMember> fields = TTIUtilClass.readFieldSetToList(fieldSetApiName, objectName);
		List<FieldObj> fieldObjects = new List<FieldObj>();

		if (!fields.isEmpty()) {
			for (Schema.FieldSetMember field : fields) {
				fieldObjects.add(new FieldObj(String.valueOf(field.getLabel()), String.valueOf(field.getFieldPath()), String.valueOf(field.getType())));
			}
		}

		return JSON.serialize(fieldObjects);
	}

	public class FieldObj {
		public String label { get; set; }
		public String apiName { get; set; }
		public String fieldType { get; set; }

		public FieldObj(String label, String apiName, String fieldType) {
			this.label = label;
			this.apiName = apiName;
			this.fieldType = fieldType;
		}
	}
}