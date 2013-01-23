@isTest
private class CalendarControllerTest {

    private class Fixture {
    
        Horse__c horse;
        Contact coach;
        Class__c clazz;
        Contact client;
        Booking__c booking;
        AvailableDate__c ad1;
        BookedDate__c bd1;
        AvailableDate__c ad2;
        
        Fixture() {
        
            horse = new Horse__c(Name = 'Paddy');
            insert horse;
            
            coach = new Contact(
                    FirstName = 'Jane',
                    LastName = 'Coach',
                    RecordTypeId = [
                            select Id
                            from RecordType
                            where DeveloperName = 'Coach'
                            and SObjectType = :String.valueOf(Contact.SObjectType)
                            ].Id
                    );
            insert coach;
            
            clazz = new Class__c(Coach__c = coach.Id, DayOfWeek__c = 'Monday');
            insert clazz;
            
            client = new Contact(
                    FirstName = 'John',
                    LastName = 'Client',
                    PreferredHorse__c = horse.Id,
                    RecordTypeId = [
                            select Id
                            from RecordType
                            where DeveloperName = 'Client'
                            and SObjectType = :String.valueOf(Contact.SObjectType)
                            ].Id
                    );
            insert client;
            
            booking = new Booking__c(Class__c = clazz.Id, Client__c = client.Id);
            insert booking;
            
            ad1 = new AvailableDate__c(Class__c = clazz.Id, Date__c = Date.newInstance(2013, 2, 18));
            insert ad1;
            
            ad2 = new AvailableDate__c(Class__c = clazz.Id, Date__c = Date.newInstance(2013, 2, 25));
            insert ad2;
            
            bd1 = new BookedDate__c(AvailableDate__c = ad1.Id, Booking__c = booking.Id);
            insert bd1;
        }
        
        void addIdsToCurrentPage() {

            Map<String, String> p = ApexPages.currentPage().getParameters();
            p.put('clientId', client.Id);
            p.put('coachId', coach.Id);
            p.put('horseId', horse.Id);
            p.put('bookingId', booking.Id);
            p.put('classId', clazz.Id);
        }
    }

    @isTest
    static void events() {
    
        Fixture f = new Fixture();

        // No ids in URL
        CalendarController c1 = new CalendarController();
        c1.init();
        System.assertNotEquals(null, c1.events);
        
        // All ids in URL
        f.addIdsToCurrentPage();
        CalendarController c2 = new CalendarController();
        c2.init();
        System.assertNotEquals(null, c2.events);
    }
}