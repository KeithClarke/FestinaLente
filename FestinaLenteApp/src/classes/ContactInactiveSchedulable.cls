public with sharing class ContactInactiveSchedulable implements Schedulable {

    public void execute(SchedulableContext context) {
        
        // Contacts that
        // - not already inactive
        // - have had a Booking
        // - but not had one in the last 2 years
        Date d = Date.today().addYears(-2);
        Contact[] contacts = [
                select Id
                from Contact
                where Status__c != 'Inactive'
                and RecordType.Name = 'Client'
                and Id in (select Client__c from Booking__c)
                and Id not in (select Client__c from Booking__c where LatestBookedDate__c > :d)
                ];
        for (Contact c : contacts) {
            c.Status__c = 'Inactive';
            c.InactiveSince__c = Date.today();
        }
        update contacts;
    }
}