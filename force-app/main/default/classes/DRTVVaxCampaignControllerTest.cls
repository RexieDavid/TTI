@isTest
private class DRTVVaxCampaignControllerTest {
	
	@isTest static void testFormSubmission() {
		PageReference pageRef = Page.DRTVVaxCampaignPage;
        Test.setCurrentPage(pageRef);        

        DRTVVaxCampaignController controller = new DRTVVaxCampaignController();
        List<SelectOption> floorSurfaceItems = controller.floorSurfaceItems;
        List<SelectOption> propertySizeItems = controller.propertySizeItems;
        List<SelectOption> hasPetsItems = controller.hasPetsItems;
        controller.firstName = 'TestFirstName';
		controller.lastName = 'TestLastName';
		controller.email = 'TestFL@test.com';
		controller.mobile = '01234567890';
		controller.newsletter = true;
		controller.selectedFloorSurface = 'N/A';
		controller.selectedPropertySize = 'N/A';
		controller.selectedHasPets = 'N/A';
        controller.createVaxPersonAccount();

	}
	
}