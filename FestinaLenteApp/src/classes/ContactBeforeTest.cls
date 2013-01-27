@isTest
private class ContactBeforeTest {

    @isTest
    static void activeInactive() {
    
        Date today = Date.today();
    
        Contact c = new Contact(LastName = 'Smith');
        insert c;
        
        System.assertEquals('Active', [select Status__c from Contact where Id = :c.Id].Status__c);
        System.assertEquals(today, [select ActiveSince__c from Contact where Id = :c.Id].ActiveSince__c);
        System.assertEquals(null, [select InactiveSince__c from Contact where Id = :c.Id].InactiveSince__c);
        
        c.Status__c = 'Inactive';
        update c;
         
        System.assertEquals('Inactive', [select Status__c from Contact where Id = :c.Id].Status__c);
        System.assertEquals(null, [select ActiveSince__c from Contact where Id = :c.Id].ActiveSince__c);
        System.assertEquals(today, [select InactiveSince__c from Contact where Id = :c.Id].InactiveSince__c);       
    }
    
    @isTest
    static void waiting() {
    
        Date today = Date.today();
    
        Contact c = new Contact(LastName = 'Smith', Status__c = 'Waiting', WaitingForClassType__c = 'Term Riding');
        insert c;
        
        System.assertEquals('Waiting', [select Status__c from Contact where Id = :c.Id].Status__c);
        System.assertEquals(today, [select ActiveSince__c from Contact where Id = :c.Id].ActiveSince__c);
        System.assertEquals(today, [select WaitingSince__c from Contact where Id = :c.Id].WaitingSince__c);
        
        c.WaitingForClassType__c = null;
        update c;
        
        System.assertEquals('Active', [select Status__c from Contact where Id = :c.Id].Status__c);
        System.assertEquals(today, [select ActiveSince__c from Contact where Id = :c.Id].ActiveSince__c);
        System.assertEquals(null, [select WaitingSince__c from Contact where Id = :c.Id].WaitingSince__c);
        
        c.Status__c = 'Waiting';
        try {
            update c;
            System.assert(false, 'exceptin expected');
        } catch (Exception e) {
            System.debug('>>> message=' + e.getMessage());
        }
    }
}