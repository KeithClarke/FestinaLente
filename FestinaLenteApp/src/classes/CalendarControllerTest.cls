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
            
            clazz = new Class__c(
                    Coach__c = coach.Id,
                    DayOfWeek__c = 'Monday',
                    Level__c = 'A - Advanced'
                    );
            insert clazz;
            
            client = new Contact(
                    FirstName = 'John',
                    LastName = 'Client',
                    Level__c = 'B - Beginner',
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
            
            ad1 = new AvailableDate__c(Class__c = clazz.Id, Date__c = Date.newInstance(2013, 1, 7));
            insert ad1;
            
            ad2 = new AvailableDate__c(Class__c = clazz.Id, Date__c = Date.newInstance(2013, 1, 14));
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
    static void initialPage() {
    
        Fixture f = new Fixture();

        // All ids in URL
        f.addIdsToCurrentPage();
        CalendarController c = new CalendarController();
        c.init();
        
        System.assertNotEquals(null, c.filter.Client__c);
        System.assertNotEquals(null, c.filter.Coach__c);
        System.assertNotEquals(null, c.filter.Horse__c);
        System.assertNotEquals(null, c.filter.Booking__c);
        System.assertNotEquals(null, c.filter.Class__c);
        
        System.assertEquals(5, c.backs.size());
        
        // Altough there is a later available date, this is the last booked dat
        System.assertEquals('7/1/2013', c.initialDateDmy);
    }
    
    @isTest
    static void eventsCallback() {
    
        Fixture f = new Fixture();
        
        // Just using this as a convenient source of intial values
        CalendarController c = new CalendarController();
        
        // No id filtering; 1 bd and 1 ad (other ad skipped)
        System.assertEquals(2, CalendarController.events(c.starts, c.ends, c.filter).size());
        
        // All id filtering
        c.filter.Client__c = f.client.Id;
        c.filter.Coach__c = f.coach.Id;
        c.filter.Horse__c = f.horse.Id;
        c.filter.Booking__c = f.booking.Id;
        c.filter.Class__c = f.clazz.Id;
        System.assertEquals(2, CalendarController.events(c.starts, c.ends, c.filter).size());
        
        // Turn off ads
        c.filter.ShowAvailable__c = false;
        System.assertEquals(1, CalendarController.events(c.starts, c.ends, c.filter).size());
        
        // Also turn off bds
        c.filter.ShowBooked__c = false;
        System.assertEquals(0, CalendarController.events(c.starts, c.ends, c.filter).size());
    }
}