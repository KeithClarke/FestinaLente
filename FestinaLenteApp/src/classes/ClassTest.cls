@isTest
private class ClassTest {

    @isTest
    static void picklistFormulaFieldsNull() {
    
        Class__c clazz = new Class__c();
        insert clazz;
        
        Class__c actual = [
                select DayOfWeekNumber__c, LengthInMinutes__c, TimeInMinutes__c
                from Class__c
                where Id = :clazz.Id
                ];
        
        System.assertEquals(null, actual.DayOfWeekNumber__c);
        System.assertEquals(null, actual.LengthInMinutes__c);
        System.assertEquals(null, actual.TimeInMinutes__c);
    }
    
    @isTest
    static void picklistFormulaFieldsNonNull() {
    
        Class__c clazz = new Class__c(
                DayOfWeek__c = 'Tuesday',
                Length__c = '45 mins',
                Time__c = '2:15 pm'
                );
        insert clazz;
        
        Class__c actual = [
                select DayOfWeekNumber__c, LengthInMinutes__c, TimeInMinutes__c
                from Class__c
                where Id = :clazz.Id
                ];
        
        System.assertEquals(2, actual.DayOfWeekNumber__c);
        System.assertEquals(45, actual.LengthInMinutes__c);
        System.assertEquals(855, actual.TimeInMinutes__c);
    }
}