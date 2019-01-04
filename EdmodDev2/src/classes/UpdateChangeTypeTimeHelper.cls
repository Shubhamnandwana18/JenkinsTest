public class UpdateChangeTypeTimeHelper {
    public static void updateChangeTypeTime(List < Result__c > newResult, List < Result__c > oldResult){
        //List < Id > contactIdList = new List < Id > ();
        Map <Id, String> contactMap = new Map <Id, String> ();
        //Result__c r=new Result__c();
        try {
            for (Integer i=0; i<newResult.size(); i++) {
              
                if(String.valueOf(newResult.get(i).MetricType__c).equals(String.valueOf(oldResult.get(i).MetricType__c))){
                    if(newResult.get(i).MetricValue__c > oldResult.get(i).MetricValue__c) {
                        //contactIdList.add(newResult.get(i).Contact_ID__c);
                        String result;
                        if(contactMap.get(newResult.get(i).Contact_ID__c) != null) {
                           result = contactMap.get(newResult.get(i).Contact_ID__c) + ',' + String.valueOf(newResult.get(i).MetricType__c);
                        	contactMap.put(newResult.get(i).Contact_ID__c, result);
                        
                        }
                        	 else
                        	contactMap.put(newResult.get(i).Contact_ID__c, String.valueOf(newResult.get(i).MetricType__c));
                        
                    }
                }
                
            }
            
            if(contactMap.keySet().size()>0){
                updateContactField(contactMap);
            }       
        } catch (NullPointerException e) {
            System.debug(Logginglevel.ERROR, 'Class: UpdateChangeTypeTimeHelper, Line Number: ' + e.getLineNumber() +
                         e.getMessage() + ' NullPointerException has occurred in Trigger: ' + e.getStackTraceString());
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, 'Class: UpdateChangeTypeTimeHelper, Line Number: ' + e.getLineNumber() +
                         e.getMessage() + ' Exception has occurred in Trigger: ' + e.getStackTraceString());
        }
        
    }
    
    public static void updateContactField(Map <Id, String> contactMap){
        List<Contact> contacts=[SELECT Id, AccountId, Email, FirstName, LastName, Phone, Date_Joined_Time__c, Last_Change_Time__c, 
                                Last_Change_Type__c FROM Contact WHERE Id IN :contactMap.keySet()];
        List <Contact> contactsToUpdate = new List < Contact > ();
        System.debug('Contacts in Trigger' + contacts.size());
        for(Contact con : contacts) {
            con.Last_Change_Type__c = contactMap.get(con.Id);
            con.Last_Change_Time__c = DateTime.now();
            contactsToUpdate.add(con);           
        }
        Database.SaveResult[] saveResultChangeTypeTime;
        List < String > changeTypeTimeInfoErrors = new List < String > ();
        if (!contactsToUpdate.isEmpty()) {
            saveResultChangeTypeTime = Database.update(contactsToUpdate, false);
            for (Database.SaveResult sr: saveResultChangeTypeTime) {
                if (!sr.isSuccess()) {
                    for (Database.Error err: sr.getErrors()) {
                        changeTypeTimeInfoErrors.add('Could not update Last Change Type Time record. Error: ' + err.getStatusCode() + ' Message: ' + err.getMessage());
                    }
                }
            }
        }
        
        System.debug(LoggingLevel.ERROR, 'changeTypeTimeInfoErrors' + changeTypeTimeInfoErrors);
        
    }
}