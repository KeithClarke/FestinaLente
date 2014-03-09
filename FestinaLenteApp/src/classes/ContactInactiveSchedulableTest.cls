@isTest
private class ContactInactiveSchedulableTest {

    @isTest
    static void test() {
        
        Contact[] cs = new Contact[] {
                new Contact(FirstName = 'A', LastName = 'Has Recent Booking'),
                new Contact(FirstName = 'B', LastName = 'Has Old Booking'),
                new Contact(FirstName = 'C', LastName = 'Has Recent and Old Booking'),
                new Contact(FirstName = 'D', LastName = 'No Booking')
                };
        insert cs;
        
        Class__c clazz = new Class__c();
        insert clazz;
        
        Booking__c[] bs = new Booking__c[] {
                new Booking__c(Class__c = clazz.Id, Client__c = cs[0].Id, LatestBookedDate__c = Date.today().addYears(-1)),
                new Booking__c(Class__c = clazz.Id, Client__c = cs[1].Id, LatestBookedDate__c = Date.today().addYears(-3)),
                new Booking__c(Class__c = clazz.Id, Client__c = cs[2].Id, LatestBookedDate__c = Date.today().addYears(-1)),
                new Booking__c(Class__c = clazz.Id, Client__c = cs[2].Id, LatestBookedDate__c = Date.today().addYears(-3))
                };
        insert bs;
        
        new ContactInactiveSchedulable().execute(null);
        
        Contact[] actuals = [
                select Status__c, InactiveSince__c
                from Contact
                where Id in :cs
                order by FirstName
                ];
        
        System.assertEquals('Active', actuals[0].Status__c);
        System.assertEquals(null, actuals[0].InactiveSince__c);
        
        System.assertEquals('Inactive', actuals[1].Status__c);
        System.assertEquals(Date.today(), actuals[1].InactiveSince__c);
         
        System.assertEquals('Active', actuals[2].Status__c);
        System.assertEquals(null, actuals[2].InactiveSince__c);
        
        System.assertEquals('Active', actuals[3].Status__c);
        System.assertEquals(null, actuals[3].InactiveSince__c);
    }
}