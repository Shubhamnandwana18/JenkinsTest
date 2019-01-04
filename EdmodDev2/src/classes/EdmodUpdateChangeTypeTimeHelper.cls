/*
 * EdmodUpdateChangeTypeTimeHelper class inserts/updates ChangeTypeTime for Contact Object.
 */
public class EdmodUpdateChangeTypeTimeHelper {
    /*
     * @description 		Compute  Last_Change_Type when Result are updated and print errors.
     * @param newResult		List of new Result object.
     * @param oldResult		List of old Result object.
     */
    public void updateChangeTypeTime(List < Result__c > newResult, List < Result__c > oldResult) {
        Map < Id, String > contactMap = new Map < Id, String > ();
        List < Error_Log__c > errors = new List < Error_Log__c > ();
        try {
            for (Integer i = 0; i < newResult.size(); i++) {
                if (String.valueOf(newResult.get(i).MetricType__c).equals(String.valueOf(oldResult.get(i).MetricType__c))) {
                    if (newResult.get(i).MetricValue__c != oldResult.get(i).MetricValue__c) {
                        String result;
                        if (contactMap.get(newResult.get(i).Contact_ID__c) != null) {
                            result = contactMap.get(newResult.get(i).Contact_ID__c) + ',' + String.valueOf(newResult.get(i).MetricType__c);
                            contactMap.put(newResult.get(i).Contact_ID__c, result);
                        } else
                            contactMap.put(newResult.get(i).Contact_ID__c, String.valueOf(newResult.get(i).MetricType__c));
                    }
                }
            }
            if (contactMap.keySet().size() > 0) {
                updateContactField(contactMap);
            }
        } catch (Exception e) {
            Error_Log__c errorLog = new Error_Log__c();
            errorLog.Time__c = DateTime.now();
            errorLog.Error_Message__c = 'Class: UpdateChangeTypeTimeHelper, Line Number: ' + e.getLineNumber() +
                ' Exception has occurred in Trigger: ' + e.getMessage();
            errors.add(errorLog);
        }
        printErrorsInLog(errors);
    }

    /*
     * @description 		Update change type and time in Contacts and print errors.
     * @param contactMap	Key is Contact Id and ChangeType metrices are values 
     */
    public void updateContactField(Map < Id, String > contactMap) {
        List < Contact > contacts = [SELECT Id, AccountId, Email, FirstName, LastName, Phone, Date_Joined_Time__c, Last_Change_Time__c,
            Last_Change_Type__c FROM Contact WHERE Id IN: contactMap.keySet()
        ];
        List < Contact > contactsToUpdate = new List < Contact > ();
        List < Error_Log__c > errors = new List < Error_Log__c > ();
        for (Contact con: contacts) {
            con.Last_Change_Type__c = contactMap.get(con.Id);
            con.Last_Change_Time__c = DateTime.now();
            contactsToUpdate.add(con);
        }

        Database.SaveResult[] saveResultChangeTypeTime;
        if (!contactsToUpdate.isEmpty()) {
            saveResultChangeTypeTime = Database.update(contactsToUpdate, false);
            for (Database.SaveResult sr: saveResultChangeTypeTime) {
                if (!sr.isSuccess()) {
                    Error_Log__c errorLog = new Error_Log__c();
                    errorLog.Time__c = DateTime.now();
                    errorLog.Error_Message__c = '';
                    for (Database.Error err: sr.getErrors()) {
                        errorLog.Error_Message__c += 'Could not update Last Change Type Time record. Error: ' +
                            err.getStatusCode() + ' Message: ' + err.getMessage();
                    }
                    errors.add(errorLog);
                }
            }
        }
        printErrorsInLog(errors);
    }

    /*
     * @description 		Compute  Last_Change_Type when Result is inserted and print errors.
     * @param newResult		List of new Result object.
     */
    public void insertChangeTypeTime(List < Result__c > newResult) {
        Map < Id, String > contactMap = new Map < Id, String > ();
        List < Error_Log__c > errors = new List < Error_Log__c > ();
        try {
            for (Integer i = 0; i < newResult.size(); i++) {
                if ((newResult.get(i).MetricValue__c > 0)) {
                    String result;
                    if (contactMap.get(newResult.get(i).Contact_ID__c) != null) {
                        result = contactMap.get(newResult.get(i).Contact_ID__c) + ',' + String.valueOf(newResult.get(i).MetricType__c);
                        contactMap.put(newResult.get(i).Contact_ID__c, result);
                    } else
                        contactMap.put(newResult.get(i).Contact_ID__c, String.valueOf(newResult.get(i).MetricType__c));
                }
            }
            if (contactMap.keySet().size() > 0) {
                updateContactField(contactMap);
            }
        } catch (Exception e) {
            Error_Log__c errorLog = new Error_Log__c();
            errorLog.Time__c = DateTime.now();
            errorLog.Error_Message__c = 'Class: UpdateChangeTypeTimeHelper, Line Number: ' + e.getLineNumber() +
                ' Exception has occurred in Trigger: ' + e.getMessage();
            errors.add(errorLog);
        }
        printErrorsInLog(errors);
    }

    /**
     * @description				Update Last_Change_Type and Last_Change_Time of contacts to old values if metric type is TEACHER_REGISTERED. 
     * @param newContact		List of new Contact object.
     * @param oldContact		List of old Contact object.
     */
    public void updateChangeTypeTimeOnContactUpdate(List < Contact > newContact, List < Contact > oldContact) {
        List < Error_Log__c > errors = new List < Error_Log__c > ();
        try {
            for (Integer i = 0; i < newContact.size(); i++) {
                if (newContact.get(i).Last_Change_Type__c == EdmodConstants.TEACHER_REGISTERED && !String.isEmpty(oldContact.get(i).Last_Change_Type__c)) {
                    newContact.get(i).Last_Change_Type__c = oldContact.get(i).Last_Change_Type__c;
                    newContact.get(i).Last_Change_Time__c = oldContact.get(i).Last_Change_Time__c;
                }
            }
        } catch (Exception e) {
            Error_Log__c errorLog = new Error_Log__c();
            errorLog.Time__c = DateTime.now();
            errorLog.Error_Message__c = 'Class: EdmodUpdateChangeTypeTimeHelper, Line Number: ' + e.getLineNumber() +
                ' Exception has occurred in Trigger: ' + e.getMessage();
            errors.add(errorLog);
        }
        printErrorsInLog(errors);
    }

    /*
     * @description Insert Errors in Error Log object.
     * 
     */
    public void printErrorsInLog(List < Error_Log__c > errorsList) {
        if (errorsList.size() > 0) {
            Database.SaveResult[] saveStatus = Database.insert(errorsList, false);
        }
    }
}