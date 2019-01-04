trigger EdmodAccountTrigger on Account(before insert, before update) {
    //Insert External Lookup key if not present or data inserted directly from Salesforce Org.
    EdmodUpdateExternalKeyHelper externalKeyHelper = new EdmodUpdateExternalKeyHelper();
    if (Trigger.isInsert && Trigger.isBefore) {
        externalKeyHelper.insertExternalKeyAccount(Trigger.New);
    } else if (Trigger.isUpdate && Trigger.isBefore) {
        externalKeyHelper.updateExternalKeyAccount(Trigger.New, Trigger.Old);
    }
}