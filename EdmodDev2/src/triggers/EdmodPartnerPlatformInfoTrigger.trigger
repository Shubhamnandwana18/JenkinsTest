trigger EdmodPartnerPlatformInfoTrigger on PartnerPlatformInfo__c(after insert, after update, before insert, before update) {
    //Create or Update Last Login Info for each PartnerPlatform 
    EdmodInsertLastLoginInfoHelper edmodInsertLastLoginInfoHelper  = new EdmodInsertLastLoginInfoHelper();
    if (Trigger.isInsert && Trigger.isAfter) {
        edmodInsertLastLoginInfoHelper.createLastLoginInfo(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
        edmodInsertLastLoginInfoHelper.updateLastLoginInfo(Trigger.New, Trigger.Old);
    }

    //Insert External Lookup key if not present or data inserted directly from Salesforce Org.
    EdmodUpdateExternalKeyHelper externalKeyHelper = new EdmodUpdateExternalKeyHelper();
    if (Trigger.isInsert && Trigger.isBefore) {
        externalKeyHelper.insertExternalKeyPartnerPlatformInfo(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        externalKeyHelper.updateExternalKeyPartnerPlatformInfo(Trigger.New, Trigger.Old);
        edmodInsertLastLoginInfoHelper.updatePPILastLoginTime(Trigger.New, Trigger.Old);
    }

}