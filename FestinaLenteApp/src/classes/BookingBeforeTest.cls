@isTest
private class BookingBeforeTest {

    private class Fixture {
    
        Class__c clazz;
        Contact contact;
        Booking__c booking;
        AvailableDate__c ad;
        BookedDate__c bd;
        
        Fixture() {
        
            clazz = new Class__c();
            insert clazz;
            
            contact = new Contact(FirstName = 'John', LastName = 'Client');
            insert contact;
  
            ad = new AvailableDate__c(Class__c = clazz.Id);
            insert ad;
            
            booking = new Booking__c(Class__c = clazz.Id, Client__c = contact.Id);
            insert booking;
            
            // This is automatically created
            bd = [select Id from BookedDate__c where AvailableDate__c = :ad.Id];
        }
    }

    @isTest
    static void deleteBooking() {
    
        Fixture f = new Fixture();

        delete f.booking;
        System.assertEquals(1, [select Count() from Class__c where Id = :f.clazz.Id]);
        System.assertEquals(0, [select Count() from Booking__c where Id = :f.booking.Id]);
        System.assertEquals(1, [select Count() from AvailableDate__c where Id = :f.ad.Id]);
        System.assertEquals(0, [select Count() from BookedDate__c where Id = :f.bd.Id]);
    }
}