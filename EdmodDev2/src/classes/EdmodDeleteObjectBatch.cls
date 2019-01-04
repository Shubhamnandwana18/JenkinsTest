global class EdmodDeleteObjectBatch implements Database.Batchable < sObject > {
    global final string OBJECT_NAME;

    global EdmodDeleteObjectBatch() {
        this.OBJECT_NAME = 'LastLoginInfo__c';
    }
    
    global EdmodDeleteObjectBatch(String objectName) {
        this.OBJECT_NAME = objectName;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info) {
       String query = 'Select Id from ' + OBJECT_NAME;
       return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List < sObject > records) {
        Database.delete(records);
    }
    
    global void finish(Database.BatchableContext bc) {
        String nextObject = getNextObject();
        
        if (nextObject != null) {
            EdmodDeleteObjectBatch deleteJob = new EdmodDeleteObjectBatch(nextObject);         
 			Database.executeBatch(deleteJob);
        } else {
            System.debug('*****Batch Execution Completed*****');
        }
    }
    
    global String getNextObject() {
        if (OBJECT_NAME == 'LastLoginInfo__c') {
            return 'Opportunity';
        } else if (OBJECT_NAME == 'Opportunity') {
            return 'Result__c';
        } else if (OBJECT_NAME == 'Result__c') {
            return 'PartnerPlatformInfo__c';
        } else if (OBJECT_NAME == 'PartnerPlatformInfo__c') {
            return 'Contact';
        } else if (OBJECT_NAME == 'Contact') {
            return 'Account';
        } else if (OBJECT_NAME == 'Account') {
            return 'Error_Log__c';
        } else {
            return null;
        }
    }
}
/*
 DeleteObjectBatch executeBatches = new DeleteObjectBatch();         
 Id batchJobId = Database.executeBatch(executeBatches);

 Deletion Order:
 LastLoginInfo__c > Opportunity > PartnerPlatformInfo__c > Result__c > Account > Errror_Log__c
 * */