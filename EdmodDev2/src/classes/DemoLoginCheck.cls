public class DemoLoginCheck {
    /**
     * This function is used to check if a last login
     * exist for a Partner Platform and update accordingly.
     * @param partnerPlatformID
     * @param lastLoginTime
	**/    
    public static void checkLogin(ID partnerPlatformID,Date lastLoginTime){
        //Understated query will return a list of LastLoginInfo entries with the given partnerPlatformID.
        //In case multiple results are returned, only the latest entry is considered
       List<LastLoginInfo__c> logins = [Select ID, Platform_ID__c ,Last_Login__c   from LastLoginInfo__c where
                                  Platform_ID__c =:partnerPlatformID ORDER BY  Last_Login__c DESC];
        //if a login does not exists already, then create a new entry.
        //if an entry exist and lastlogintime is less then incoming login time, update it.
        if(logins.size()<1){
            LastLoginInfo__c login = new LastLoginInfo__c();
            login.Platform_ID__c =partnerPlatformID;
            login.Last_Login__c=lastLoginTime;
            insert login;
        } else if(logins[0].Last_Login__c!=lastLoginTime){
            logins[0].Platform_ID__c =partnerPlatformID;
            logins[0].Last_Login__c=lastLoginTime;
            update logins[0];
        }
    }
}