@isTest
private class BookingAfterTest {

    private class Fixture {
    
        Class__c clazz;
        Contact contact;
        AvailableDate__c ad;
        Booking__c booking;
        
        Fixture() {
        
            insert clazz = new Class__c(Type__c = 'foo');
            insert contact = new Contact(FirstName = 'John', LastName = 'Client', Status__c = 'Waiting', ClassType__c = 'bar');
            
            // Date needs to be in the futre as past dates are ignored
            insert ad = new AvailableDate__c(Class__c = clazz.Id, Date__c = Date.newInstance(2100, 1, 1));
            
            assertBookedDateCount(0);
            assertContactStatus('Waiting');
            
            insert booking = new Booking__c(Class__c = clazz.Id, Client__c = contact.Id);
            
            assertBookedDateCount(1);
            assertContactStatus('Active');
            
            delete booking;
            assertContactStatus('Inactive');
        }
        
        void assertBookedDateCount(Integer expected) {
            System.assertEquals(
                    expected,
                    [select Count() from BookedDate__c where AvailableDate__c = :ad.Id]
                    );
        }
        
        void assertContactStatus(String expected) {
        	System.assertEquals(expected, [select Status__c from Contact where Id = :contact.Id].Status__c);
        }
    }
    
    @isTest
    static void test() {

        new Fixture();
    }
}