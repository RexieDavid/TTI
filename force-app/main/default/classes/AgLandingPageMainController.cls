/**
 * @author                          Kristopher Veraces
 * @description                     AEG Community Footer controller
 * 
 * @group                           AEG Community
 * 
 */
public class AgLandingPageMainController {
    @TestVisible
    private static String siteLabel = Site.getMasterLabel();

    /**********************************************************************
     * @description                     Fetch community settings in custom
     *                                  metadata
     */
    @AuraEnabled
    public static Community_Setting__mdt getSiteSettings() {
        return CommunitySettingsHelper.getSiteSettings(siteLabel);
    }
}