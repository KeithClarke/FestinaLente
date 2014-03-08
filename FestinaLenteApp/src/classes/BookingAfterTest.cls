@isTest
private class BookingAfterTest {

    private class Fixture {
    
        Class__c clazz;
        Contact contact;
        AvailableDate__c ad;
        Booking__c booking;
        
        Fixture() {
        
            insert clazz = new Class__c();
            insert contact = new Contact(FirstName = 'John', LastName = 'Client', Status__c = 'Waiting', ClassType__c = 'Blah');
            insert ad = new AvailableDate__c(Class__c = clazz.Id);
            
            assertBookedDateCount(0);
            
            insert booking = new Booking__c(Class__c = clazz.Id, Client__c = contact.Id);
            
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
    static void test() {

        new Fixture();
    }
}