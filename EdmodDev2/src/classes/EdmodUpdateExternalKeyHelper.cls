/*
 * EdmodUpdateExternalKeyHelper class inserts External Lookup key for different objects.
 */
public class EdmodUpdateExternalKeyHelper {
    /*
     * insertExternalKeyAccount
     * @description Insert External Key for Account
     * @param accounts     
     */
    public void insertExternalKeyAccount(List < Account > accounts) {
        for (Account account: accounts) {
            if (String.isEmpty(account.External_Lookup_Key__c) || account.External_Lookup_Key__c == null) {
                account.External_Lookup_Key__c = account.Name + EdmodConstants.KEY_DELIMITER + account.Site;
            }
        }
    }

    /*
     * updateExternalKeyAccount
     * @description Update External Key for Account
     * @param newAccounts
     * @param oldAccounts     
     */
    public void updateExternalKeyAccount(List < Account > newAccounts, List < Account > oldAccounts) {
        for (Integer i = 0; i < newAccounts.size(); i++) {
            if ((!newAccounts.get(i).Name.equals(oldAccounts.get(i).Name)) || (!newAccounts.get(i).Site.equals(oldAccounts.get(i).Site))) {
                newAccounts.get(i).External_Lookup_Key__c = newAccounts.get(i).Name + EdmodConstants.KEY_DELIMITER + newAccounts.get(i).Site;
            }
        }
    }

    /*
     * insertExternalKeyPartnerPlatformInfo
     * @description Update External Key for PartnerPlatformInfo
     * @param ppiList       
     */
    public void insertExternalKeyPartnerPlatformInfo(List < PartnerPlatformInfo__c > ppiList) {
        for (PartnerPlatformInfo__c ppi: ppiList) {
            if (String.isEmpty(ppi.External_Lookup_Key__c) || ppi.External_Lookup_Key__c == null) {
                ppi.External_Lookup_Key__c = ppi.Teacher_ID__c + EdmodConstants.KEY_DELIMITER + ppi.Name;
            }
        }
    }

    /*
     * updateExternalKeyPartnerPlatformInfo
     * @description Update External Key for PartnerPlatformInfo
     * @param newPpiList
     * @param oldPpiList     
     */
    public void updateExternalKeyPartnerPlatformInfo(List < PartnerPlatformInfo__c > newPpiList, List < PartnerPlatformInfo__c > oldPpiList) {
        for (Integer i = 0; i < newPpiList.size(); i++) {
            if ((newPpiList.get(i).Teacher_ID__c != oldPpiList.get(i).Teacher_ID__c) || (!newPpiList.get(i).Name.equals(oldPpiList.get(i).Name))) {
                newPpiList.get(i).External_Lookup_Key__c = newPpiList.get(i).Teacher_ID__c + EdmodConstants.KEY_DELIMITER + newPpiList.get(i).Name;
            }
        }
    }

    /*
     * insertExternalKeyResult
     * @description Update External Key for Result
     * @param resultList       
     */
    public void insertExternalKeyResult(List < Result__c > resultList) {
        for (Result__c result: resultList) {
            if (String.isEmpty(result.External_Lookup_Key__c) || result.External_Lookup_Key__c == null) {
                result.External_Lookup_Key__c = result.Contact_ID__c + EdmodConstants.KEY_DELIMITER +
                    result.Name + EdmodConstants.KEY_DELIMITER + result.PartnerPlatformInfo__c +
                    EdmodConstants.KEY_DELIMITER + result.MetricType__c;
            }
        }
    }

    /*
     * updateExternalKeyResult
     * @description Update External Key for Result
     * @param newResultList
     * @param oldResultList     
     */
    public void updateExternalKeyResult(List < Result__c > newResultList, List < Result__c > oldResultList) {
        for (Integer i = 0; i < newResultList.size(); i++) {
            if (!newResultList.get(0).Account_ID__c.equals(oldResultList.get(0).Account_ID__c) || !newResultList.get(0).Contact_ID__c.equals(oldResultList.get(0).Contact_ID__c) ||
                !newResultList.get(0).Name.equals(oldResultList.get(0).Name) || !newResultList.get(0).MetricType__c.equals(oldResultList.get(0).MetricType__c)) {
                newResultList.get(0).External_Lookup_Key__c = newResultList.get(0).Contact_ID__c +
                    EdmodConstants.KEY_DELIMITER + newResultList.get(0).Name + EdmodConstants.KEY_DELIMITER +
                    newResultList.get(0).PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER + newResultList.get(0).MetricType__c;
            }
        }
    }
}