@isTest
private class BookingAfterTest {

    private class Fixture {
    
        Class__c clazz;
        Contact contact;
        Booking__c booking;
        AvailableDate__c ad;
        
        Fixture() {
        
            clazz = new Class__c();
            insert clazz;
            
            contact = new Contact(FirstName = 'John', LastName = 'Client');
            insert contact;
  
            ad = new AvailableDate__c(Class__c = clazz.Id);
            insert ad;
            
            assertBookedDateCount(0);
            
            booking = new Booking__c(Class__c = clazz.Id, Client__c = contact.Id);
            insert booking;
            
            assertBookedDateCount(1);
        }
        
        void assertBookedDateCount(Integer expected) {
            System.assertEquals(
                    expected,
                    [select Count() from BookedDate__c where AvailableDate__c = :ad.Id]
                    );
        }
    }
    
    @isTest
    static void bookedDatesCreated() {

        new Fixture();
    }
}