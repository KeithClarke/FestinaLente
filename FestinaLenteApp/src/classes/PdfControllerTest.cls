@isTest
private class PdfControllerTest {

    private class Fixture {
    
        Horse__c horse;
        Contact coach;
        Class__c clazz;
        Contact client;
        Booking__c booking;
        AvailableDate__c ad;
        BookedDate__c bd;
        
        Fixture(String type) {
        
            horse = new Horse__c(
                    Name = 'Paddy'
                    );
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
                    Type__c = type
                    );
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
            
            booking = new Booking__c(
                    Class__c = clazz.Id,
                    Client__c = client.Id
                    );
            insert booking;
            
            ad = new AvailableDate__c(
                    Class__c = clazz.Id,
                    Date__c = Date.newInstance(2013, 2, 18)
                    );
            insert ad;
            
            bd = new BookedDate__c(
                    AvailableDate__c = ad.Id,
                    Booking__c = booking.Id
                    );
            insert bd;

            Map<String, String> p = ApexPages.currentPage().getParameters();
            p.put('from', '1/1/2013');
            p.put('to', '6/6/2013');
            p.put('days', 'Monday');
            p.put('format', 'PDF');
            p.put('layout', 'landscape');
        }
    }
    
    @isTest
    static void termRidings() {
    
        Fixture f = new Fixture('Term Riding');
        
        PdfController c = new PdfController();
        List<Table> tables = c.termRidings;
        System.assertEquals(1, tables.size());
    }
    
    @isTest
    static void privateLessons() {
    
        Fixture f = new Fixture('Private Lesson');
        
        PdfController c = new PdfController();
        List<Table> tables = c.privateLessons;
        System.assertEquals(1, tables.size());
    }
    
    @isTest
    static void termOther() {
    
        Fixture f = new Fixture('Term Riding');
        
        PdfController c = new PdfController();
        System.assertEquals('PDF', c.format);
        System.assertEquals('landscape', c.layout);
        System.assertEquals('01/01/2013', c.formattedFrom);
        System.assertEquals('06/06/2013', c.formattedTo);
    }
}