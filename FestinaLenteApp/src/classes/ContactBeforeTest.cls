@isTest
private class ContactBeforeTest {
    
    @isTest
    static void defaultingOfAccount() {
        
        Contact c = new Contact(LastName = 'Smith');
        insert c;
        
        Id accountId = [select AccountId from Contact where Id = :c.Id].AccountId;
        System.assertNotEquals(null, accountId);
        System.assertEquals('Default Account', [select Name from Account where Id = :accountId].Name);
    }
    
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
    
        Contact c = new Contact(LastName = 'Smith', Status__c = 'Waiting', ClassType__c = 'Term');
        insert c;
        
        System.assertEquals('Waiting', [select Status__c from Contact where Id = :c.Id].Status__c);
        System.assertEquals(null, [select ActiveSince__c from Contact where Id = :c.Id].ActiveSince__c);
        System.assertEquals(today, [select WaitingSince__c from Contact where Id = :c.Id].WaitingSince__c);
        
        c.ClassType__c = null;
        update c;
        
        System.assertEquals('Inactive', [select Status__c from Contact where Id = :c.Id].Status__c);
        System.assertEquals(null, [select ActiveSince__c from Contact where Id = :c.Id].ActiveSince__c);
        System.assertEquals(null, [select WaitingSince__c from Contact where Id = :c.Id].WaitingSince__c);
        System.assertEquals(today, [select InactiveSince__c from Contact where Id = :c.Id].InactiveSince__c);
        
        c.Status__c = 'Waiting';
        try {
            update c;
            System.assert(false, 'exceptin expected');
        } catch (Exception e) {
            System.debug('>>> message=' + e.getMessage());
        }
    }
    
    @isTest
    static void waiverForm() {
    
        Date today = Date.today();
    
        Contact c = new Contact(LastName = 'Smith');
        insert c;
        System.assertEquals(null, [select WaiverFormCompletedDate__c from Contact where Id = :c.Id].WaiverFormCompletedDate__c);
        
        c.WaiverFormCompleted__c = true;
        update c;
        System.assertEquals(today, [select WaiverFormCompletedDate__c from Contact where Id = :c.Id].WaiverFormCompletedDate__c);
        
        c.WaiverFormCompleted__c = false;
        update c;
        System.assertEquals(null, [select WaiverFormCompletedDate__c from Contact where Id = :c.Id].WaiverFormCompletedDate__c);
    }
}