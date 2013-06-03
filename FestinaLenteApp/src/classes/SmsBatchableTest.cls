@isTest
private class SmsBatchableTest {
	
    private class TwilioMock implements HttpCalloutMock {
    	
    	private Integer statusCode;
    	
    	public TwilioMock(Integer statusCode) {
    		this.statusCode = statusCode;
    	}

        public HTTPResponse respond(HTTPRequest request) {
                
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(statusCode);
            return res;
        }
    }

    @isTest
    static void workingSend() {
        send(true);
    }
    
    @isTest
    static void failingSend() {
    	send(false);
    }
    
    private static void send(Boolean working) {
               
        TwilioConfiguration__c config = new TwilioConfiguration__c(
                SetupOwnerId = UserInfo.getOrganizationId(),
                AccountSid__c = 'abc',
                AuthToken__c = 'xyz',
                FromNumber__c = '12345678'
                );
        insert config;
        
        Test.setMock(HttpCalloutMock.class, new TwilioMock(working ? 200 : 400));
        
        Contact c = new Contact(
               LastName = 'Doe',
               MobilePhone = '1112222'
               );
        insert c;
        
        Test.startTest();
        doTest(c.Id, working);
        Test.stopTest();
    }
    
    @future(callout=true)
    private static void doTest(Id contactId, Boolean taskExpected) {
    	
    	Database.BatchableContext bc = null;
    	SmsBatchable sms = new SmsBatchable(new Set<id>{contactId}, 'Text message');
    	
    	Database.QueryLocatorIterator iter = sms.start(bc).iterator();
    	System.assertEquals(true, iter.hasNext());
    	
    	sms.execute(bc, new SObject[] {iter.next()});
    	
    	sms.finish(bc);
    	
    	// Task created on successful send
    	System.assertEquals(taskExpected ? 1 : 0, [
    	        select Count()
    	        from Task
    	        where WhoId = :contactId
    	        and Subject = 'SMS: Text message'
    	        ]);
    	
    	// Email sent on failure: can't easily access that in test
    }
}