trigger OpportunityTrigger on Opportunity (before insert, before update, before delete) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();

    if(Trigger.isBefore && Trigger.isInsert) {
        handler.onBeforeInsert(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate) {
        handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isBefore && Trigger.isDelete) {
        handler.onBeforeDelete(Trigger.old);
    }
}