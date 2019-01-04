public class EdmodUtilityMethods {
    
    /*
     * IsNullEmpty
     * @description Method to check NULL/EMPTY values
     * @param value : value to be checked for null or empty 
     */
    public static boolean IsNullEmpty(String value) {
        if (value == null || value == '') {
            return true;
        } else {
            return false;
        }
    }
}