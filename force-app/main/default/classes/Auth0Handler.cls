/**
 * @description  Custom Handler class for authentication or creation of the user
 **/

global class Auth0Handler implements Auth.RegistrationHandler{
    static final string MIL_COMMUNITY_PROFILE = '~Customer Community Milwaukee';
    static final String MIL_BRAND = 'Milwaukee'; 
    static final String AUTH0_NAMESPACE  = 'https://Salesforce_Custom_Claim/';
    static Map<String,String> userMap;
   
/**
* @description         Check whether the user can be created
*                       or not  
*                          
* 
* @param               user metadata from Auth0
* @return              Boolean value       
*/  
global boolean canCreateUser(Auth.UserData data) {
    userMap = Auth0HandlerCommunityUtility.getExternalUserMap(data.attributeMap, AUTH0_NAMESPACE);
    Boolean isUserExist = Auth0HandlerCommunityUtility.doesUserExist(userMap.get('email'),MIL_BRAND);
    return !isUserExist;
}

/**
* @description         Used to create the new user
*                       
*                             
* 
* @param               portal Id and user metadata from Auth0
* @return              User if eligible to create user      
*/      
global User createUser(Id portalId, Auth.UserData data){
     //We have a community id, so create a user with community access   
    Network CommunityNetwork =  Auth0HandlerCommunityUtility.getCommunityNetworkid();
    userMap = Auth0HandlerCommunityUtility.getExternalUserMap(data.attributeMap, AUTH0_NAMESPACE);
    if(CommunityNetwork != NULL && CommunityNetwork.id == Network.getNetworkId() || Test.isRunningTest() && CommunityNetwork.id == userMap.get('sfdc_networkid')) {
          return Auth0HandlerCommunityUtility.createMilwaukeeUser(data,canCreateUser(data),MIL_BRAND,MIL_COMMUNITY_PROFILE,AUTH0_NAMESPACE);
        }else{
            //This is not a Onekeycommunity
                return null;
        }
}

/**
* @description         Used to update the existing user
*                       
*                             
* 
* @param               userId, portal Id and user metadata from Auth0
* @return              User profile data    
*/   
global void updateUser(Id userId, Id portalId, Auth.UserData data){
    User milwaukeeUser = new User(id=userId);
    userMap = Auth0HandlerCommunityUtility.getExternalUserMap(data.attributeMap, AUTH0_NAMESPACE); 
   if(milwaukeeUser.lastName != userMap.get('last_name'))
   {
        milwaukeeUser.lastName = userMap.get('last_name');
   }   
    if( milwaukeeUser.firstName != userMap.get('first_name'))
   {
         milwaukeeUser.firstName = userMap.get('first_name');
   }  
    try {
         update(milwaukeeUser) ;
       } catch (DmlException e) {
        } catch (Exception e) {
       } 
    
    }
}