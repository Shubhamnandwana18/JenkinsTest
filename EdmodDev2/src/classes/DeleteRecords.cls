public class DeleteRecords {
    List<Id> partnerPlatformInfos=new List<Id>();
    List<Id> results=new List<Id>();
    List<Id> opportunities=new List<Id>();
    List<Id> lastLoginInfos=new List<Id>();
    public void deleteAccounts(String accountName,String state){
        Account a=[Select Id from Account where name=:accountName and Site =:state][0];
        List<Contact> contacts;
        if(a!=null){
            contacts=getContacts(a.Id); 
            for(Contact con:contacts){
                getPartnerPlatformInfos(con.Id);
                getResults(con.Id);
                getOpportunities(con.Id);
            }
            for(Id ppiId:partnerPlatformInfos){
                getLastLoginInfos(ppiId);
            }
        }
        Database.delete(lastLoginInfos);
        Database.delete(opportunities);
        Database.delete(results);
        Database.delete(partnerPlatformInfos);
        Database.delete(contacts);
        Database.delete(a);
    }
    public List<Contact> getContacts(String accountId){
        return [select Id from contact where AccountId =: accountId];
    }
    public void getPartnerPlatformInfos(String contactId){
        List <PartnerPlatformInfo__c> ppi=[select Id from PartnerPlatformInfo__c where Contact_ID__c  =: contactId];
        for(PartnerPlatformInfo__c obj:ppi){
                partnerPlatformInfos.add(obj.Id);
            }
    }
    public void getResults(String contactId){
         List <Result__c> res=[select Id from Result__c where Contact_ID__c  =: contactId];
        for(Result__c obj:res){
                results.add(obj.Id);
            }
    }
    public void getOpportunities(String contactId){
          List <Opportunity> opp=[select Id from Opportunity where Contact_ID__c  =: contactId];
        for(Opportunity obj:opp){
               opportunities.add(obj.id);
            }        
    }
    public void getLastLoginInfos(String partnerPlatformId){
        List <LastLoginInfo__c> lli=[select Id from LastLoginInfo__c where Platform_ID__c   =: partnerPlatformId];
        for(LastLoginInfo__c obj:lli){
               lastLoginInfos.add(obj.id);
            }
        
    }
}