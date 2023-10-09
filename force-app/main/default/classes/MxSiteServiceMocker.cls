@isTest
public class MxSiteServiceMocker implements System.StubProvider {
    
    public Object handleMethodCall(
            Object stubbedObject, 
            String stubbedMethodName, 
            Type returnType, 
            List<Type> listOfParamTypes, 
            List<String> listOfParamNames, 
            List<Object> listOfArgs) {

        switch on stubbedMethodName {
            when 'login' {
                if (MxSiteService.hasMockError == true) {
                    throw new MxSiteService.MxSiteServiceException('Script-thrown exception');
                } else {
                    return new Pagereference('https://testurl.com');
                }
            }
            when 'forgotPassword' {
                if (MxSiteService.hasMockError == true) {
                    throw new MxSiteService.MxSiteServiceException('Script-thrown exception');
                } else {
                    return true;
                }
            }
            when else {
                NoSuchElementException nsee = new NoSuchElementException();
                nsee.setMessage('The method called currently isn\'t set up and cannot be mocked.');
                throw nsee;
            }
        }
    }
}