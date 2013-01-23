@isTest
private class SelectableAvailableDateTest {

    @isTest
    static void test() {
    
        AvailableDate__c ad = new AvailableDate__c(Date__c = Date.newInstance(2013, 1, 20));
        SelectableAvailableDate sad = new SelectableAvailableDate(ad, null);
        
        System.assertEquals(false, sad.selected);
        System.assertEquals(true, sad.past);
    }
}