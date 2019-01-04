@isTest 
public class EdmodUpdateExternalKeyHelperTest {
    
    /* @Test: insertExternalKeyAccountTest
     * @Description: This function executes the EdmodExecuteBatches function of class EdmodExecuteBatches.
     * In this it is checked that External_Lookup_Key is generated in case when key is absent. 
	 * The External_Lookup_Keys is made with the combination of Account Name and Site.
     */
    @isTest static void insertExternalKeyAccountTest(){
        Test.startTest();
        EdmodUpdateExternalKeyHelper updateExternalKeyHelper = new EdmodUpdateExternalKeyHelper();
        List < Account > oldAccountList = new List< Account >();
        List < Account > newAccountList = new List< Account >();
        Account account = returnCreatedAccountOld();
        oldAccountList.add(account);
        updateExternalKeyHelper.insertExternalKeyAccount(oldAccountList);
        System.assertEquals(account.Name + EdmodConstants.KEY_DELIMITER + account.Site, account.External_Lookup_Key__c);
    	

		Account newAccount = returnCreatedAccountNew();
        newAccountList.add(newAccount); 
        updateExternalKeyHelper.updateExternalKeyAccount( newAccountList, oldAccountList );

        // To Check that new key has been generated
        System.assertEquals(newAccount.Name + EdmodConstants.KEY_DELIMITER + newAccount.Site,
                            newAccount.External_Lookup_Key__c);
        Test.stopTest();
    }
    
    // These functions create sample accounts 
    static Account returnCreatedAccountOld(){
    	Account account = new Account(
            Name='Facebook',
            Site='CA',
            School_NCES_ID__c='171908002555',
            District__c='TWP HSD 113',
            District_NCES_ID__c='1719069',
            BillingCity='Menlo Park',
            BillingCountry='USA'
        );
        return account;
    }
    
    static Account returnCreatedAccountNew(){
        Account newAccount = new Account(
            Name='DEERFIELD HIGH SCHOOL',
            Site='IL',
            School_NCES_ID__c='171908002193',
            District__c='TWP HSD 113',
            District_NCES_ID__c='1719080',
            BillingCity='DEERFIELD',
            BillingCountry='USA'
        );
       return newAccount;
    }
}