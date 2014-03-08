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