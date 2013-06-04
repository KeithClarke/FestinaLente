@isTest
private class ContactStatusBatchableTest {
	
	private class Fixture {
    
        Class__c clazz;
        Contact contact;
        Booking__c booking;
        AvailableDate__c ad;
        BookedDate__c bd;
        
        Fixture(String classType, Date d) {
        
            clazz = new Class__c(Type__c = classType);
            insert clazz;
            
            contact = new Contact(FirstName = 'John', LastName = 'Client ' + d);
            insert contact;
  
            ad = new AvailableDate__c(Class__c = clazz.Id, Date__c = d);
            insert ad;
            
            booking = new Booking__c(Class__c = clazz.Id, Client__c = contact.Id);
            insert booking;
            
            // This is automatically created
            bd = [select Id from BookedDate__c where AvailableDate__c = :ad.Id];
        }
        
        void assertContact(String expectedStatus, String expectedActiveClassTypes) {
        	
        	Contact actual = [select Status__c, ActiveClassType__c from Contact where Id = :contact.Id];
        	System.assertEquals(expectedStatus, actual.Status__c);
        	System.assertEquals(expectedActiveClassTypes, actual.ActiveClassType__c);
        }
    }

    @isTest
    static void test() {
    	
    	Database.BatchableContext bc = null;
    	
        Date today = Date.today();
    	Fixture f0 = new Fixture('aaa', today.addDays(-1));
    	Fixture f1 = new Fixture('bbb', today);
    	Fixture f2 = new Fixture('ccc', today.addDays(1));
    	
    	ContactStatusBatchable batchable = new ContactStatusBatchable();
    	
    	// Start
    	Database.QueryLocatorIterator iter = batchable.start(bc).iterator();
    	
    	System.assertEquals(true, iter.hasNext());
    	Contact c0 = (Contact) iter.next();
    	
    	System.assertEquals(true, iter.hasNext());
    	Contact c1 = (Contact) iter.next();
    	
    	System.assertEquals(true, iter.hasNext());
    	Contact c2 = (Contact) iter.next();
    	
    	System.assertEquals(false, iter.hasNext());
    	
    	// Execute
    	batchable.execute(bc, new SObject[] {c0, c1, c2});
    	
    	// Finish
    	batchable.finish(bc);
    	
    	f0.assertContact('Inactive', null);
    	f1.assertContact('Active', 'bbb');
    	f2.assertContact('Active', 'ccc');
    }
}