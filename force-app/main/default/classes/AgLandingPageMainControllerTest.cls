/**
 * @author                          Kristopher Veraces
 * 
 */
@isTest
private class AgLandingPageMainControllerTest {
    private static final String MYAEG_SITE_LABEL = 'myAEG';

    /**********************************************************************
     * @description                     Fetch community settings in custom
     *                                  metadata
     */
    @isTest
    private static void fetchSiteSettings() {
        Community_Setting__mdt settings;
        AgLandingPageMainController.siteLabel = MYAEG_SITE_LABEL;
        Test.startTest();
            settings = AgLandingPageMainController.getSiteSettings();
        Test.stopTest();
        assertSettings(settings);
    }

    /**********************************************************************
     * @description                     Assert data in custom metadata
     */
    private static void assertSettings(Community_Setting__mdt settings) {
        /**
            Can only check master label as it is database dependent
            and prone to different changes
         */ 
        System.assert(settings != null, 'Failed to fetch community settings');
        System.assertEquals(MYAEG_SITE_LABEL, settings.MasterLabel, 'Master label does not match');
    }
}