global with sharing class Actions {

    WebService static void deleteAvailableDates(Id[] ids) {
        deleteSobType(AvailableDate__c.SObjectType, ids);
    }
    
    WebService static void deleteBookings(Id[] ids) {
        deleteSobType(Booking__c.SObjectType, ids);
    }
    
    private static void deleteSobType(SObjectType sobType, Id[] ids) {
        List<SObject> sobs = new List<SObject>();
        for (Id id : ids) {
            sobs.add(sobType.newSObject(Id = id));
        }
        delete sobs;
    }
}