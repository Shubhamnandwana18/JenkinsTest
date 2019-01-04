trigger EdmodResultTrigger on Result__c(after insert, after update) {
    //Update Change Type and Change Time in contact
    EdmodUpdateChangeTypeTimeHelper updateChangeTypeTimeHelper = new EdmodUpdateChangeTypeTimeHelper();
    if (Trigger.isInsert && Trigger.isAfter) {
        UpdateChangeTypeTimeHelper.insertChangeTypeTime(Trigger.New);
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
        UpdateChangeTypeTimeHelper.updateChangeTypeTime(Trigger.New, Trigger.Old);
    }

    //Insert External Lookup key if not present or data inserted directly from Salesforce Org.
    EdmodUpdateExternalKeyHelper externalKeyHelper = new EdmodUpdateExternalKeyHelper();
    if (Trigger.isInsert && Trigger.isBefore) {
        externalKeyHelper.insertExternalKeyResult(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        externalKeyHelper.updateExternalKeyResult(Trigger.New, Trigger.Old);
    }

}