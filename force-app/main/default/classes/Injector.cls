/**
 * @author                              Kristopher Veraces
 * @date                                2020-09-23
 * 
 * @group                               Dependency injection
 */
public class Injector {
    private static final String ERR_APEX_CLASS_NOT_FOUND = 'Apex class not found';
    private static final String ERR_CLASS_NAME_REQUIRED = 'Class Name is required';

    /**
     * @description                 Dynamically instantiate a class
     * 
     * @param className             Class Name
     */
    public static Object instantiate(String className) {
        if (String.isBlank(className)) {
            throw new InjectorException(ERR_CLASS_NAME_REQUIRED);
        }

        Object obj;
        try {
            /**
             * Load the Type corresponding to the class name
             * and create a new instance of the class
             */
            obj = Type.forName(className).newInstance();
        } catch (Exception ex) {
            throw new InjectorException(ERR_APEX_CLASS_NOT_FOUND);
        }
        return obj;
    }

    public class InjectorException extends Exception {}
}