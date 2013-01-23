@isTest
private class PrintingControllerTest {

    @isTest
    static void test() {
    
        PrintingController p = new PrintingController();
        System.assertNotEquals(null, p.printing.From__c);
        System.assertEquals(null, p.printing.To__c);
    }
}