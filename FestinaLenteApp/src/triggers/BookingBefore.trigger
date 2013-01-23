trigger BookingBefore on Booking__c (before delete) {

    // Cascade the delete
    Set<Id> ids = Trigger.oldMap.keySet();
    delete [select Id from BookedDate__c where Booking__c in :ids];
}