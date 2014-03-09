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
        
        Fixture(String type, Boolean useClassIdsParameter) {
        
            horse = new Horse__c(
                    Name = 'Paddy'
                    );
            insert horse;
            
            coach = new Contact(
                    FirstName = 'Jane',
                    LastName = 'Coach',
                    ColourCode__c = 'AliceBlue (#F0F8FF)',
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
	        if (useClassIdsParameter) {
	        	p.put('classIds', clazz.Id);
	        } else {
	            p.put('from', '1/1/2013');
	            p.put('to', '6/6/2013');
	            p.put('days', 'Monday');
	            p.put('format', 'PDF');
	            p.put('layout', 'landscape');
	        }
        }
    }
    
    @isTest
    static void termRidings() {

        for (Boolean useClassIdsParameter : new Boolean[] {false, true}) {
        	
	        Fixture f = new Fixture('Term', useClassIdsParameter);
	        
	        PdfController c = new PdfController();
	        List<Table> tables = c.termRidings;
	        System.assertEquals(1, tables.size());
        }
    }
    
    @isTest
    static void privateLessons() {
    
	    for (Boolean useClassIdsParameter : new Boolean[] {false, true}) {
	    	
	        Fixture f = new Fixture('Private Lesson', useClassIdsParameter);
	        
	        PdfController c = new PdfController();
	        List<Table> tables = c.privateLessons;
	        System.assertEquals(1, tables.size());
	    }
    }
    
    @isTest
    static void ponyCamps() {
    
	    for (Boolean useClassIdsParameter : new Boolean[] {false, true}) {
	    	
	        Fixture f = new Fixture('Pony Camp', useClassIdsParameter);
	        
	        PdfController c = new PdfController();
	        List<Table> tables = c.ponyCamps;
	        System.assertEquals(1, tables.size());
	    }
    }
    
    @isTest
    static void termOther() {
    
	    for (Boolean useClassIdsParameter : new Boolean[] {false, true}) {
	    	
	        Fixture f = new Fixture('Term', useClassIdsParameter);
	        
	        PdfController c = new PdfController();
	        System.assertEquals('PDF', c.format);
	        System.assertEquals('landscape', c.layout);
	        System.assertEquals('01/01/2013 - 06/06/2013', c.formattedFromTo);
	    }
    }
}