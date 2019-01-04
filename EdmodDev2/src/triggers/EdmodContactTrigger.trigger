trigger EdmodContactTrigger on Contact(before update) {
    EdmodUpdateChangeTypeTimeHelper updateChangeTypeTimeHelper = new EdmodUpdateChangeTypeTimeHelper();
    UpdateChangeTypeTimeHelper.updateChangeTypeTimeOnContactUpdate(Trigger.New, Trigger.Old);
}