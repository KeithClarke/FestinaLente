public with sharing class ClassDeepCloneController {

    // Public for testing
    public Class__c clazz;

    public ClassDeepCloneController(ApexPages.StandardController controller) {
    
        this.clazz = (Class__c) controller.getRecord();
    }
    
    public AvailableDate__c[] ads {
        get {
            return [
                    select Id, Date__c, DayOfWeekNumber__c
                    from AvailableDate__c
                    where Class__c = :clazz.Id
                    order by Date__c
                    ];
        }
    }
    
    public PageReference save() {
    
        Class__c newClazz = clazz.clone();
        insert newClazz;
        
        // Need to get formula result
        Decimal newClazzDayOfWeekNumber = [
                select DayOfWeekNumber__c
                from Class__c
                where Id = :newClazz.Id
                ].DayOfWeekNumber__c;
        
        // Clone AvailableDates changing date if needed (similar logic in ClassAfterTrigger)      
        List<AvailableDate__c> newAds = new List<AvailableDate__c>();
        for (AvailableDate__c ad : ads) {
            newAds.add(new AvailableDate__c(
                    Class__c = newClazz.Id,
                    Date__c = ad.Date__c.addDays(newClazzDayOfWeekNumber.intValue() - ad.DayOfWeekNumber__c.intValue())
                    ));
        }
        if (newAds.size() > 0) {
            insert newAds;
        }

        return new PageReference('/' + newClazz.Id);
    }
    
    public PageReference cancel() {
        
        return new PageReference('/' + clazz.Id);
    }
}