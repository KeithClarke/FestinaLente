trigger ClassBefore on Class__c (before delete) {

    // Cascade the delete
    Set<Id> ids = Trigger.oldMap.keySet();
    delete [select Id from BookedDate__c where Booking__c in (select Id from Booking__c where Class__c in :ids)];
}