/*
 * EdmodInsertLastLoginInfoHelper class insert/update LastLoginInfo for PartnerPlatformInfo Object.
 */
public class EdmodInsertLastLoginInfoHelper {
    /*
     * @description 	Insert new LastLoginInfo object and print errors.
     * @param ppiList   List of new PartnerPlatformInfo object.
     */
    public void createLastLoginInfo(List < PartnerPlatformInfo__c > ppiList) {
        List < LastLoginInfo__c > newLLIRecords = new List < LastLoginInfo__c > ();
        List < Error_Log__c > errors = new List < Error_Log__c > ();
        Map<Id,String> contactsMap=getContactsMap(ppiList);
        for (PartnerPlatformInfo__c ppi: ppiList) {
            try {
                LastLoginInfo__c lliRow = new LastLoginInfo__c();
                lliRow.Last_Login__c = ppi.Last_Login_Time__c;
                lliRow.Platform_ID__c = ppi.Id;                
                newLLIRecords.add(lliRow);
            } catch (Exception e) {
                Error_Log__c errorLog = new Error_Log__c();
                errorLog.Time__c = DateTime.now();
                errorLog.Error_Message__c = 'Class: InsertLastLoginInfoHelper, Line Number: ' + e.getLineNumber() +
                    ' Exception has occurred in Trigger: ' + e.getMessage();
                errors.add(errorLog);
            }
        }
        insertLastLoginInfo(newLLIRecords,errors);
    }

    /*
     * @description 		Insert new LastLoginInfo object if new Last_Login_Time is greater than old Last_Login_Time.
     * @param newPPIList    List of new PartnerPlatformInfo object.
     * @param oldPPIList 	List of old PartnerPlatformInfo object.
     */
    public void updateLastLoginInfo(List < PartnerPlatformInfo__c > newPPIList, List < PartnerPlatformInfo__c > oldPPIList) {
        List < LastLoginInfo__c > updatedLLIRecords = new List < LastLoginInfo__c > ();
        List < Error_Log__c > errors = new List < Error_Log__c > ();
        Map<Id,String> contactsMap=getContactsMap(newPPIList);
        for (Integer i = 0; i < newPPIList.size(); i++) {
            try {
                if (newPPIList.get(i).Last_Login_Time__c > oldPPIList.get(i).Last_Login_Time__c) {
                    LastLoginInfo__c lliRow = new LastLoginInfo__c();
                    lliRow.Last_Login__c = newPPIList.get(i).Last_Login_Time__c;
                    lliRow.Platform_ID__c = newPPIList.get(i).Id;
                    lliRow.Name=contactsMap.get(newPPIList.get(i).contact_id__c);
                    updatedLLIRecords.add(lliRow);
                }
            } catch (Exception e) {
                Error_Log__c errorLog = new Error_Log__c();
                errorLog.Time__c = DateTime.now();
                errorLog.Error_Message__c = 'Class: InsertLastLoginInfoHelper, Line Number: ' + e.getLineNumber() +
                    ' Exception has occurred in Trigger: ' + e.getMessage();
                errors.add(errorLog);
            }
        }     
        insertLastLoginInfo(updatedLLIRecords,errors);
    }

    /**
     * @description 		Update Last_Login_Time__c of PartnerPlatformInfo__c object if it is greater than old Last_Login_Time.
     * @param newPPIList    List of new PartnerPlatformInfo object.
     * @param oldPPIList 	List of old PartnerPlatformInfo object.
     */
    public void updatePPILastLoginTime(List < PartnerPlatformInfo__c > newPPIList, List < PartnerPlatformInfo__c > oldPPIList) {
        for (Integer i = 0; i < newPpiList.size(); i++) {
            if (newPPIList.get(i).Last_Login_Time__c < oldPPIList.get(i).Last_Login_Time__c) {
                newPPIList.get(i).Last_Login_Time__c = oldPPIList.get(i).Last_Login_Time__c;
            }
        }
    }

    /**
     * @description Insert Errors in Error Log object.
     */
    public void printErrorsInLog(List < Error_Log__c > errorsList) {
        if (errorsList.size() > 0) {
            Database.SaveResult[] saveStatus = Database.insert(errorsList, false);
        }
    }
    /**
     * @description Get contactsMap corresponding to all partner platform info.
     */
     Map<Id,String> getContactsMap(List < PartnerPlatformInfo__c > ppiList){
        Map<Id,String> contactsMap=new Map<Id,String>();
        List<Id> contactIds=new List<Id>();
        for(PartnerPlatformInfo__c p: ppiList){
            contactIds.add(p.contact_id__c);
        }
        for(Contact c:[select Id,Name from Contact where Id IN: contactIds]){
            contactsMap.put(c.Id,c.Name);
        }
        return contactsMap;
    }
    /**
     * @description insert last login info.
     */
    void insertLastLoginInfo(List < LastLoginInfo__c > lliList,List<Error_Log__c> errors){
        Database.SaveResult[] saveResultListLastLoginInfo;
        if (!lliList.isEmpty()) {
            saveResultListLastLoginInfo = Database.insert(lliList, false);
            for (Database.SaveResult sr: saveResultListLastLoginInfo) {
                if (!sr.isSuccess()) {
                    Error_Log__c errorLog = new Error_Log__c();
                    errorLog.Time__c = DateTime.now();
                    errorLog.Error_Message__c = '';
                    for (Database.Error err: sr.getErrors()) {
                        errorLog.Error_Message__c += 'Could not Insert Last Login record. Error: ' + err.getStatusCode() +
                            ' Message: ' + err.getMessage();
                    }
                    errors.add(errorLog);
                }
            }
            printErrorsInLog(errors);
        }
    }
}