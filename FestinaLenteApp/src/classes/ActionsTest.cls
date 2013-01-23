@isTest
private class ActionsTest {

    private class Fixture {
    
        Class__c clazz;
        Contact contact;
        Booking__c booking;
        AvailableDate__c ad;
        
        Fixture() {
        
            clazz = new Class__c();
            insert clazz;
            
            contact = new Contact(LastName = 'Doe');
            insert contact;
            
            booking = new Booking__c(Class__c = clazz.Id, Client__c = contact.Id);
            insert booking;
            
            ad = new AvailableDate__c(Class__c = clazz.Id);
            insert ad;
        }
    }

    @isTest
    static void deleteAvailableDates() {
    
        Fixture f = new Fixture();
        
        System.assertEquals(1, [select Count() from AvailableDate__c where Class__c = :f.clazz.Id]);
        Actions.deleteAvailableDates(new List<Id>{f.ad.Id});
        System.assertEquals(0, [select Count() from AvailableDate__c where Class__c = :f.clazz.Id]);
    }
    
    @isTest
    static void deleteBookings() {
    
        Fixture f = new Fixture();
        
        System.assertEquals(1, [select Count() from Booking__c where Class__c = :f.clazz.Id]);
        Actions.deleteBookings(new List<Id>{f.booking.Id});
        System.assertEquals(0, [select Count() from Booking__c where Class__c = :f.clazz.Id]);
    }

}