public with sharing class SelectViewController {
	
	public SelectViewController (){
		
	}
		
	public PageReference selectViewPageRef(){
		
		String url;
		
		UserRole ur = [SELECT id, Name FROM UserRole where id= :UserInfo.getUserRoleId() LIMIT 1];
		
		if(ur.Name.subString(0,3) == 'IND'){
			url= '/01t';	
		}
		else if(ur.Name.subString(0,3) == 'FLR'){
			url= '/01t';	
		}
		else if(ur.Name.subString(0,3) == 'CMR'){
			url= '/01t';	
		}
		else{
			url= '/01t';	
		}
		
		System.debug('Name substring is : ' + ur.Name.subString(0,2));
		System.debug('url is : ' + url);
		
		PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
              return pageRef;
	}
}