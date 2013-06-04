@isTest
private class NightlySchedulableTest {

    @isTest
    static void coverageOnly() {
    	
    	Contact c = new Contact(FirstName = 'Jane' , LastName = 'Doe');
    	insert c;
    	
    	SchedulableContext context = null;
    	new NightlySchedulable().execute(context);
    }
}