public with sharing class CreateFlow_PartnerPlatform_Helper {
    
    public static void createOpportunity(List<Contact> contactList){
        //Create new Opportunity for each new entry in Contacts.
        List<Opportunity> newOpportunities = new List<Opportunity>();
        for(Contact con : contactList){
            Opportunity opp = new Opportunity();
            //opp.Participant_UID__c = con.Id;
            //opp.AccountId=con.AccountId;
            //opp.Name='Teacher_Onboarding';
            opp.StageName='Teacher_Signup';
            opp.CloseDate=date.today()+90;
            newOpportunities.add(opp);
        }    
        
        //Insert Opportunity records.
        Database.SaveResult[] saveResultListOpportunity;
        if(!newOpportunities.isEmpty())
            saveResultListOpportunity=Database.insert(newOpportunities, false);
        
        //Get list of errors for which Opportunity could not be made.
        List<String> opportunityErrors = new List<String>();    
        for (Database.SaveResult sr : saveResultListOpportunity) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    opportunityErrors.add('Could not create flow record. Error: '+err.getStatusCode()+' Message: '+err.getMessage());
                }
            }
        }
        //EdmodUploadCSVRecords uploadRecords = new EdmodUploadCSVRecords();
        //uploadRecords.printErrorsInLog(opportunityErrors);
    }
    
    public static void createPartnerPlatformInfo(List<Contact> contactList){
        
        System.debug('In trigger ContactsList:'+contactList);
        
        //Create new PartnerPlatformInfo for each new entry in Contacts.
        List<PartnerPlatformInfo__c > newPartnerPlatform = new List<PartnerPlatformInfo__c >();
        EdmodUploadCSVRecords uploadRecords = new EdmodUploadCSVRecords(null,null,null);
        //System.debug(contactList.size());
        for(Contact con : contactList){
            try{
                PartnerPlatformInfo__c ppi = new PartnerPlatformInfo__c();     
                System.debug(con.Email);
                List<String> csvRow = uploadRecords.getRowFromEmail(con.Email.trim());
                System.debug(''+csvRow);
                ppi.Contact_ID__c=con.Id;
                ppi.Teacher_ID__c = Double.valueOf(csvRow.get(0));
                ppi.Name='CODEHS';
                ppi.Last_Login_Time__c=DateTime.valueOf(csvRow.get(6));
                ppi.Class_Code__c=csvRow.get(7);
                ppi.Sections__c=Double.valueOf(csvRow.get(16));
                
                newPartnerPlatform.add(ppi);            
            }
            catch(NullPointerException e){
                System.debug(Logginglevel.ERROR,'Class: CreateFlow_PartnerPlatform_Helper, Line Number: '+e.getLineNumber()+' NullPointerException has occurred in Trigger: ' + e.getStackTraceString());
            }
            
            catch(Exception e){
                System.debug(Logginglevel.ERROR,'Class: CreateFlow_PartnerPlatform_Helper, Line Number: '+e.getLineNumber()+' Exception has occurred in Trigger: ' + e.getStackTraceString() );
            }
        }
        
        System.debug(newPartnerPlatform);
        
        //Insert PartnerPlatformInfo records.
        Database.SaveResult[] saveResultListPartnerPlatform;
        List<String> partnerPlatformErrors = new List<String>();    
        if(!newPartnerPlatform.isEmpty()){
            saveResultListPartnerPlatform=Database.insert(newPartnerPlatform, false);
            for (Database.SaveResult sr : saveResultListPartnerPlatform) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        partnerPlatformErrors.add('Could not create Partner Platform record. Error: '+err.getStatusCode()+' Message: '+err.getMessage());
                    }
                }        
            }
        }
        
        if(!partnerPlatformErrors.isEmpty()){
            uploadRecords.printErrorsInLog(partnerPlatformErrors);
        }
    }
    
}