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
    
    @isTest
    static void prefixSuffix1() {
    	doPrefixSuffix(null, null, '', 0);
    }
    
    @isTest
    static void prefixSuffix2() {
    	doPrefixSuffix('Hi', 'Bye', 'HiBye', 2);
    }
    
    @isTest
    static void prefixSuffix3() {
    	doPrefixSuffix('Hi\\n', '\\nBye', 'Hi\n\nBye', 3);
    }
    
    @isTest
    static void prefixSuffix4() {
    	String expectedPrefix = 'Hi from ' + UserInfo.getName() + ' ' + UserInfo.getName() + '\n';
    	String expectedSuffix = '\nBye from ' + UserInfo.getName() + '\n' + UserInfo.getName();
    	doPrefixSuffix(
    	       'Hi from {!User.Name} {!User.Name}\\n',
    	       '\\nBye from {!User.Name}\\n{!User.Name}',
    	       expectedPrefix + expectedSuffix,
    	       expectedPrefix.length()
    	       );
    }
    
    private static void doPrefixSuffix(String prefix, String suffix, String expectedMessage, Integer expectedCaretPosition) {
    	
    	TwilioConfiguration__c config = new TwilioConfiguration__c(
                SetupOwnerId = UserInfo.getOrganizationId(),
                AccountSid__c = 'abc',
                AuthToken__c = 'xyz',
                FromNumber__c = '12345678',
                MessagePrefix__c = prefix,
                MessageSuffix__c = suffix
                );
        insert config;

        SmsController controller = new SmsController();
        System.assertEquals(expectedMessage, controller.message);
        System.assertEquals(expectedCaretPosition, controller.caretPosition);
    }
}