@isTest
private class EditBookedDatesControllerTest {

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
            
            booking = new Booking__c(Class__c = clazz.Id, Client__c = contact.Id);
            insert booking;
            
            ad = new AvailableDate__c(Class__c = clazz.Id);
            insert ad;
        }
    }

    @isTest
    static void save() {
    
        Fixture f = new Fixture();
    
        ApexPages.currentPage().getParameters().put('bookingId', f.booking.Id);
        
        EditBookedDatesController c = new EditBookedDatesController();
        
        System.assertEquals(f.booking.Id, c.booking.Id);
        
        System.assertEquals(1, c.availables.size());
        c.availables.get(0).selected = true;
        
        Id bookingId = c.save().getUrl().substring(1);
        System.assertEquals(bookingId, f.booking.Id);
        System.assertEquals(1, [
                select Count()
                from BookedDate__c
                where Booking__c = :f.booking.Id
                and AvailableDate__c = :f.ad.Id
                ]);
    }
    
    @isTest
    static void cancel() {
   
        ApexPages.currentPage().getParameters().put('retURL', 'fake-url');
        
        EditBookedDatesController c = new EditBookedDatesController();
        System.assertEquals('fake-url', c.cancel().getUrl());
    }
}