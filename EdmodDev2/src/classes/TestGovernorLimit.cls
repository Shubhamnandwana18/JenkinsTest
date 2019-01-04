public class TestGovernorLimit {
	
	Map<String,Opportunity> opportunitiesMap = new Map<String,Opportunity>();
    public List < List < String >> csvData;

    /*public void A(){
        for(Integer i=0;i<51;i++){
        List<Test__c> listA=[select Id,Name from Test__c];
        }
    }
    public void B(){
        for(Integer i=0;i<51;i++){
        List<Test__c> listB=[select Id,Name from Test__c];
        }
    }
    public boolean isRowValid(List<String> csvRow){
        List<String> errorList=new List<String>();
        Boolean isErrorPresent=false;
        
        Boolean isMetricValuesPresent=checkAllMetricValues(csvRow);
        
        if(!isMetricValuesPresent){
            errorList.add('Metric values cannot be null or empty');
            isErrorPresent=true;
        }else{        
            if((Integer.valueOf(csvRow.get(17))+Integer.valueOf(csvRow.get(36))) > Integer.valueOf(csvRow.get(16))){
                errorList.add('Invalid Row: #Students signed up is less than sum of #students with project started and #students with project completed');
                isErrorPresent=true;
            }
            
            if(Integer.valueOf(csvRow.get(17))>Integer.valueOf(csvRow.get(36))){
                errorList.add('Invalid Row: #Students with project started is less than sum of #students completed');
                isErrorPresent=true;
            }
            if(Datetime.valueOf(csvRow.get(7))<Datetime.valueOf(csvRow.get(6))){
                errorList.add('Invalid Row: Last login date is less than date joined');
                isErrorPresent=true;
            }
        }                  
        System.debug(LoggingLevel.ERROR, errorList);
        if(isErrorPresent){
           return false; 
        }else{
            return true;
        }
    }      
    public Boolean checkAllMetricValues(List<String> csvRow){
        for(Integer i=15;i<=csvRow.size();i++){
            if(UtilityMethods.IsNullEmpty(csvRow.get(i))){
                return false;
            }
        }
        return true;
    }*/
    
    public void processOpportunities() {
        try {
            //Initialize Opportuniy Map
            initializeOpportunitiesMap();
            
            addNewOpportunitiesToList();
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, 'Class: UploadCSVRecords, Line Number: ' + e.getLineNumber() + ' Exception has occurred in Accounts: ' + e.getStackTraceString());
            System.debug('Data: ' + csvData);
        }
    }
    
    public void initializeOpportunitiesMap() {
        opportunitiesMap.clear();
        for (Opportunity opp: [SELECT AccountId, Contact_ID__c, PartnerPlatformInfo__c, Name, Type from Opportunity]) {
            opportunitiesMap.put(opp.AccountId + EdmodConstants.KEY_DELIMITER + opp.Contact_ID__c + EdmodConstants.KEY_DELIMITER + opp.PartnerPlatformInfo__c + EdmodConstants.KEY_DELIMITER + opp.Name + EdmodConstants.KEY_DELIMITER + opp.Type, opp);
        }
    }
    
    public void addNewOpportunitiesToList() {
        for (Integer i = 1; i < csvData.size(); i++) {
            
        }
    }
    
    public void insertTest(){
        Account acc=[select Id,name from Account limit 1];
        List<test__c> listTest=new List<Test__c>();
        for(Integer i=0;i<5;i++){
            Test__c test=new Test__c();
            test.Name='test'+i;
            test.Email__c='testEmail'+i+'@mail.com';
            test.Account__c =acc.Id;
            test.Key__c='test'+i+'_'+'testEmail'+i+'@mail.com'+'_'+acc.Id;
            listTest.add(test);
        }
        System.debug('Insertlist'+listTest);
        insert listTest;
    }
    public void upsertTest(){
        Account acc=[select Id,name from Account limit 1];
        List<test__c> listTest=new List<Test__c>();
        for(Integer i=0;i<6;i++){
            Test__c test=new Test__c();
            test.Name='testUpsert'+i;
            test.Email__c='testUpsertEmail'+i+'@mail.com';
            test.Account__c =acc.Id;
            test.Key__c='test'+i+'_'+'testEmail'+i+'@mail.com'+'_'+acc.Id;
            
            listTest.add(test);
        }
        
        System.debug('Upsertlist'+listTest);
        upsert listTest Key__c;
    }
    /*
     TestGovernorLimit tgl=new TestGovernorLimit();
	 tgl.insertTest();

	TestGovernorLimit tgl=new TestGovernorLimit();
	 tgl.upsertTest();
     * */
    
    
}