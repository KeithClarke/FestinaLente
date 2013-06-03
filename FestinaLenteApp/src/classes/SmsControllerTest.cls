@isTest
private class SmsControllerTest {

    @isTest
    static void testContact() {
          
        Contact c = new Contact(LastName = 'Doe', MobilePhone = '0861112222');
        insert c;
        
        ApexPages.currentPage().getParameters().put('contactId', c.Id);
        
        doTest();
    }
    
    @isTest
    static void testClass() {
        
        Contact c = new Contact(LastName = 'Doe', MobilePhone = '0861112222');
        insert c;
        
        Class__c clazz = new Class__c();
        insert clazz;
        
        Booking__c b = new Booking__c(Client__c = c.Id, Class__c = clazz.Id);
        insert b;
        
        ApexPages.currentPage().getParameters().put('classId', clazz.Id);
        
        doTest();
    }
    
    private static void doTest() {
        
        TwilioConfiguration__c config = new TwilioConfiguration__c(
                SetupOwnerId = UserInfo.getOrganizationId(),
                AccountSid__c = 'abc',
                AuthToken__c = 'xyz',
                FromNumber__c = '12345678'
                );
        insert config;

        ApexPages.currentPage().getParameters().put('retURL', 'fakeRetURL');
        
        SmsController controller = new SmsController();
        
        System.assertEquals('12345678', controller.fromNumber);
        
        System.assertEquals(1, controller.contacts.size());
        
        SmsController.SelectableContact sc = controller.contacts[0];
        System.assertEquals('+353861112222', sc.cleanMobileNumber);
        
        sc.selected = true;     
        controller.message = 'Message text';
        PageReference send = controller.send();
        System.assertEquals('fakeRetURL', send.getUrl());
        
        PageReference cancel = controller.cancel();
        System.assertEquals('fakeRetURL', cancel.getUrl());
        
        System.assertEquals(null, controller.refreshContacts());
        System.assertEquals(1, controller.contacts.size());
    }
}