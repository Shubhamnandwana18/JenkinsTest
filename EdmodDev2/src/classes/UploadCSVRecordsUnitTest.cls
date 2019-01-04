@isTest
public class UploadCSVRecordsUnitTest {
    @isTest static void addNewAccountsToListTest(){
		
        
        insertTechStartPartner();
       // Test.startTest();
        List<List<String>> csvData = new List<List<String>>{new List<String>{'ID', 'First Name', 'Last Name', 'Email', 'Phone', 'Date Joined', 'Last Login', 'Class Code', 
            'School', 'School NCES ID', 'District', 'District NCES ID', 'City', 'State', 'Country', 'Num Sections', 'Num Students', 'Num Students Who Completed A Project', 
            'Num Student Program Shares', 'Teacher Checklist Completed 1','Teacher Checklist Completed 2', 'Teacher Checklist Completed 3', 'Teacher Checklist Completed 4', 'Teacher Checklist Completed 5', 
            'Students Completed Music 1 Hour', 'Students Completed Music 10 Hour', 'Students Completed Art 1 Hour', 'Students Completed Art 10 Hour','Students Completed Sports 1 Hour', 'Students Completed Sports 10 Hour', 'Students Started Music 1 Hour', 'Students Started Art 1 Hour',
            'Students Started Sports 1 Hour', 'Students Started Music 10 Hour', 'Students Started Art 10 Hour', 'Students Started Sports 10 Hour','Num Students Who Started A Project'},
                new List<String>{'760545', 'Jeremy', 'TechStart', 'jkeesh+techstart12@codehs.com', '1231231234', '2018-08-16 10:08:22', '2018-08-22 11:08:40', '889AD', 'DEERFIELD HIGH SCHOOL', '171908002193', 'TWP HSD 113', '1719080', 'DEERFIELD', 'IL', 'USA', '1', '0', '0', '0', 'True', 'True', 'True', 'False', 'False', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'},
                    new List<String>{'736980', 'Lusmaia', 'Diaz', 'lusmaia@fb.com', '1111111111', '2018-07-20 02:07:35', '2018-08-09 01:08:51', '31A73', 'Facebook', '171908002555', 'TWP HSD 113', '1719069', 'Menlo Park', 'CA', 'USA', '2', '15', '1', '6', 'True', 'False', 'False', 'True', 'False', '1', '0', '0', '0', '0', '0', '9', '3', '2', '0', '0', '1', '0'},
                        new List<String>{'736981', 'Sophia', 'Smith', 'SophiaSmith@codehs.com', '1111111111', '2018-07-20 02:07:35', '2018-08-09 01:08:51', '31A73', 'Facebook', '171908002555', 'TWP HSD 113', '1719069', 'Menlo Park', 'CA', 'USA','7','87','11','0','True', 'True', 'True', 'True', 'True','6',	'3',	'3',	'2',	'1',	'0',	'8',	'6',	'5',	'4',	'5',	'2', '25'}
							};
        //to check case when duplicate entries in newAccountList
     	TestingUploadCSVRecords newUploadCSVRecordsTest = new TestingUploadCSVRecords(csvData, 'TS', 'CODEHS');
        Map < String, Account > newAccountList=newUploadCSVRecordsTest.addNewAccountsToList();
        System.assertEquals(2, newAccountList.size()); 
        
        // case when all records are already present
       
        newUploadCSVRecordsTest=new TestingUploadCSVRecords(csvData, 'TS', 'CODEHS');
        insertAccounts();
        newUploadCSVRecordsTest.initializeAccountsMap();
        newAccountList=newUploadCSVRecordsTest.addNewAccountsToList();
        System.assertEquals(0, newAccountList.size());
        
       // Test.stopTest();
    }
    @isTest static void getCurrentEducationProgramTest(){
        TestingUploadCSVRecords UploadCSVRecordsTestObject = new TestingUploadCSVRecords(null, 'TS', null);
        CurrentEducationProgram__c newCurrentEducationProgram = new CurrentEducationProgram__c(
        	Name = 'TS_2018',
            ProgramType__c = 'TS',
            ProgramStartDate__c = Date.valueOf('2018-01-01'),
            ProgramEndDate__c = Date.valueOf('2019-01-01')
        );
        insert newCurrentEducationProgram;
        System.assertEquals(1,UploadCSVRecordsTestObject.getCurrentEducationProgram('TS').size());
    }
    @isTest static void initializeTechStartPartnersSetTest(){
        TestingUploadCSVRecords UploadCSVRecordsTestObject=new TestingUploadCSVRecords(null, null, null);
        insertTechStartPartner();
        UploadCSVRecordsTestObject.initializeTechStartPartnersSet();
        System.assertEquals(1, UploadCSVRecordsTestObject.initializeTechStartPartnersSet().size());
    }
    @isTest static void initializeAccountsMapTest(){ 
    	TestingUploadCSVRecords UploadCSVRecordsTestObject=new TestingUploadCSVRecords(null, null, null);
        insertAccounts();
        System.assertEquals(2, UploadCSVRecordsTestObject.initializeAccountsMap().size());
    }
    @isTest static void initializePartnerPlatformInfoMapTest(){
        TestingUploadCSVRecords UploadCSVRecordsTestObject=new TestingUploadCSVRecords(null, null, 'TS');
        
        insertPartnerPlatformInfo();
        System.debug('UploadCSVRecordsTestObject.initializePartnerPlatformInfoMap().size(),2  '+UploadCSVRecordsTestObject.initializePartnerPlatformInfoMap().size()+'  2');
        
        System.assertEquals(1, UploadCSVRecordsTestObject.initializePartnerPlatformInfoMap().size());
        
    }
    @isTest static void insertProgramTest() {
        if ([Select ID from CurrentEducationProgram__c].size() < 1) {
            CurrentEducationProgram__c tsProgram = new CurrentEducationProgram__c();
            tsProgram.Name = 'TS_2018';
            tsProgram.ProgramType__c = 'TS';
            insert tsProgram;
            tsProgram = new CurrentEducationProgram__c();
            tsProgram.Name = 'EFTW_2018';
            tsProgram.ProgramType__c = 'EFTW';
            insert tsProgram;
        }
        if ([SELECT Id from TechStartPartners__c].size() < 1) {
            TechStartPartners__c tsPartners = new TechStartPartners__c();
            tsPartners.Name = 'DEERFIELD HIGH SCHOOL';
            tsPartners.State_or_Territory__c = 'IL';
            tsPartners.School_NCES_ID__c = '171908002193';
            insert tsPartners;
            tsPartners = new TechStartPartners__c();
            tsPartners.Name = 'Facebook';
            tsPartners.State_or_Territory__c = 'CA';
            tsPartners.School_NCES_ID__c = '171908002555';
            insert tsPartners;
        }   
    }
    @isTest static void createOrUpdateRecordsTest(){
        TestingUploadCSVRecords newUploadCSVRecordsTest=new TestingUploadCSVRecords(null, null, null );
        List<Account> accountsList = new List<Account>();
        Long School_NCES_ID = 171908002555L;
        System.debug(School_NCES_ID);
        Integer District_NCES_ID = 1719069;
        Account newAccount;
        for(Integer i = 0 ; i < 10; i++){
            newAccount = new Account(
                Name='Facebook'+String.valueOf(i),
                Site='CA',
                School_NCES_ID__c = String.valueOf(School_NCES_ID),
                District__c='TWP HSD 113',
                District_NCES_ID__c= String.valueOf(District_NCES_ID),
                BillingCity='Menlo Park',
                BillingCountry='USA'
            );
            accountsList.add(newAccount);
            School_NCES_ID++;
            District_NCES_ID++;
        }
		newUploadCSVRecordsTest.createOrUpdateRecords(accountsList,'Insert');
		
    }
    static void  insertPartnerPlatformInfo(){
        Account newAccount = new Account(
            Name='Facebook',
            Site='CA',
            School_NCES_ID__c='171908002555',
            District__c='TWP HSD 113',
            District_NCES_ID__c='1719069',
            BillingCity='Menlo Park',
            BillingCountry='USA'
        );
        insert newAccount;

        Contact NewContact = new Contact (
            FirstName = 'Lusmaia',
            LastName = 'Diaz',
            AccountId = newAccount.ID,
            Email = 'lusmaia@fb.com',
            Date_Joined_Time__c = DateTime.valueOf('2019-08-16 10:08:22'),
            Last_Change_Type__c = ''          
        );
		insert NewContact;
        
        PartnerPlatformInfo__c NewPartnerPlatformInfo = new PartnerPlatformInfo__c(
            Contact_ID__c = NewContact.ID,
            Teacher_ID__c = 123456789,
            Name = 'TS'
        );//            ,Class_Code__c = ''
        insert NewPartnerPlatformInfo;
    }
	static void insertAccounts(){
        //System.debug('@'+[SELECT Id, Name, Site FROM Account].size());
        if([SELECT Id, Name, Site FROM Account].size()<1){
            Account account = new Account();
            account.Name='DEERFIELD HIGH SCHOOL';
            account.Site='IL';
            account.School_NCES_ID__c='171908002193';
            account.District__c='TWP HSD 113';
            account.District_NCES_ID__c='1719080';
            account.BillingCity='DEERFIELD';
            account.BillingCountry='USA';
            account.Is_Partner__c=False;
            insert account;
            
            account = new Account();
            account.Name='Facebook';
            account.Site='CA';
            account.School_NCES_ID__c='171908002555';
            account.District__c='TWP HSD 113';
            account.District_NCES_ID__c='1719069';
            account.BillingCity='Menlo Park';
            account.BillingCountry='USA';
            account.Is_Partner__c=True;
            insert account;
           // System.debug('@@'+[SELECT Id, Name, Site FROM Account].size());
        }
    }
    static void insertTechStartPartner(){
        if([SELECT Id, Name, School_NCES_ID__c, State_or_Territory__c   FROM TechStartPartners__c].size()<1){
            TechStartPartners__c  TechStartPartnersSampleAccount = new TechStartPartners__c();
            TechStartPartnersSampleAccount.Name='Facebook';
            TechStartPartnersSampleAccount.State_or_Territory__c='CA';
            TechStartPartnersSampleAccount.School_NCES_ID__c='171908002555';
            insert TechStartPartnersSampleAccount;
        }
    }
}