@isTest
private class SmsControllerTest {
	
    @isTest
    static void testContact() {
          
        Contact c = new Contact(LastName = 'Doe', MobilePhone = '0861112222', Email = 'fake@fake.com');
        insert c;
        
        ApexPages.currentPage().getParameters().put('contactId', c.Id);
        
        doTest(null, 1);
    }
    
    @isTest
    static void testClass() {
        
        Contact c = new Contact(LastName = 'Doe', MobilePhone = '0861112222', Email = 'fake@fake.com');
        insert c;
        
        Class__c clazz = new Class__c();
        insert clazz;
        
        Booking__c b = new Booking__c(Client__c = c.Id, Class__c = clazz.Id);
        insert b;
        
        ApexPages.currentPage().getParameters().put('classId', clazz.Id);
        
        doTest(null, 1);
    }
    
    @isTest
    static void testFilteringUsingContactNoMatch() {
        doTestFiltering(true, false);
    }
    
    @isTest
    static void testFilteringUsingContactMatch() {
        doTestFiltering(true, true);
    }
    
    @isTest
    static void testFilteringUsingClassNoMatch() {
        doTestFiltering(false, false);
    }
    
    @isTest
    static void testFilteringUsingClassMatch() {
        doTestFiltering(false, true);
    }
    
    private static void doTestFiltering(Boolean useContactId, Boolean matchingFilter) {
        
        Contact c = new Contact(LastName = 'Doe', MobilePhone = '0861112222', Email = 'fake@face.com');
        insert c;
        
        Class__c clazz = new Class__c();
        insert clazz;
        
        Date d = Date.newInstance(2013, 1, 10);
        AvailableDate__c ad = new AvailableDate__c(Class__c = clazz.Id, Date__c = d);
        insert ad;
        
        Booking__c b = new Booking__c(Client__c = c.Id, Class__c = clazz.Id);
        insert b;
        
        // No need to create a BookedDate here: it is created by default
        
        if (useContactId) {
            ApexPages.currentPage().getParameters().put('contactId', c.Id);
        } else {
            ApexPages.currentPage().getParameters().put('classId', clazz.Id);
        }
        
        doTest(matchingFilter ? d : d.addDays(1), matchingFilter ? 1 : 0);
    }
    
    private static void doTest(Date filterDate, Integer expectedContactCount) {
        
        TwilioConfiguration__c config = new TwilioConfiguration__c(
                SetupOwnerId = UserInfo.getOrganizationId(),
                AccountSid__c = 'abc',
                AuthToken__c = 'xyz',
                FromNumber__c = '12345678',
                MessageCost__c = 0.05
                );
        insert config;

        ApexPages.currentPage().getParameters().put('retURL', 'fakeRetURL');
        
        SmsController controller = new SmsController();
        if (filterDate != null) {
            controller.filter.Date__c = filterDate;
        }
        
        System.assertEquals('12345678', controller.fromNumber);
        System.assertNotEquals(null, controller.messageCost);
        
        System.assertEquals(expectedContactCount, controller.contacts.size());
        if (expectedContactCount > 0) {
            SmsController.SelectableContact sc = controller.contacts[0];
            System.assertEquals('+353861112222', sc.cleanMobileNumber);
            
            sc.smsSelected = true; 
            controller.smsMessage = 'SMS message text';
            
            sc.emailSelected = true;    
            controller.emailSubject = 'Email subject';
            controller.emailMessage = 'Email message text';

            PageReference send = controller.send();
            
            System.assertEquals('fakeRetURL', send.getUrl());
            
            PageReference cancel = controller.cancel();
            System.assertEquals('fakeRetURL', cancel.getUrl());
        }
        
        System.assertEquals(null, controller.refreshContacts());
        System.assertEquals(expectedContactCount, controller.contacts.size());
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
        doPrefixSuffix('Hi\\s', '\\sBye', 'Hi  Bye', 3);
    }
    
    @isTest
    static void prefixSuffix5() {
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
        System.assertEquals(expectedMessage, controller.smsMessage);
        System.assertEquals(expectedCaretPosition, controller.caretPosition);
    }
}