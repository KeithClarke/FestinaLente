@isTest
private class BookedDateAfterTest {

    private class Fixture {
    
        Class__c clazz;
        Contact contact;
        Booking__c booking;
        AvailableDate__c ad;
        BookedDate__c bd;
        
        Fixture() {
        
            clazz = new Class__c(DayOfWeek__c = 'Monday');
            insert clazz;
            
            contact = new Contact(FirstName = 'John', LastName = 'Client');
            insert contact;
  
            ad = new AvailableDate__c(Class__c = clazz.Id, Date__c = Date.newInstance(2013, 2, 18));
            insert ad;
            
            booking = new Booking__c(Class__c = clazz.Id, Client__c = contact.Id);
            insert booking;
            
            // BookedDate automatically created
            bd = [select Id from BookedDate__c where AvailableDate__c = :ad.Id and Booking__c = :booking.Id];
        }
    }
    
    @isTest
    static void validation() {
    
        Fixture f1 = new Fixture();
        Fixture f2 = new Fixture();
    
        // Common class parent
        try {
            insert new BookedDate__c(Booking__c = f1.booking.Id, AvailableDate__c = f2.ad.Id);
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            System.debug('>>> message=' + e.getMessage());
        }
        
        // Duplicate BookedDate
        try {
            insert new BookedDate__c(Booking__c = f1.booking.Id, AvailableDate__c = f1.ad.Id);
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            System.debug('>>> message=' + e.getMessage());
        }
    }
}