public with sharing class GenerateAvailableDatesController {

    private Id classId {
        get {
            if (classId == null) {
                classId = ApexPages.currentPage().getParameters().get('classId');
            }
            return classId;
        }
        private set;
    }

    public Class__c clazz {
        get {
            if (clazz == null) {
                clazz = [
                        select Id, Name, Type__c, DayOfWeek__c, DayOfWeekNumber__c, (select Date__c from AvailableDates__r)
                        from Class__c
                        where Id = :classId
                        ];
            }
            return clazz;
        }
        private set;
    }

    public Range__c range {
        get {
            if (range == null) {
                Date nextMonday = Date.today().addDays(-Dates.dayOfWeek(Date.today()) + 1);
                range = new Range__c(From__c = nextMonday);
            }
            return range;
        }
        private set;
    }

    public PageReference generate() {
    
        // Move start to correct day of week
        Date s = range.From__c;
        while(Dates.dayOfWeek(s) != clazz.DayOfWeekNumber__c) {
           s = s.addDays(1);
        }
        
        Set<Date> alreadyPresentDates = new Set<Date>();
        for (AvailableDate__c ad : clazz.AvailableDates__r) {
            alreadyPresentDates.add(ad.Date__c);
        }
        
        // Add weekly dates
        List<Date> newDates = new List<Date>();
        for (Date d = s; d <= range.To__c; d = d.addDays(7)) {
            if (!alreadyPresentDates.contains(d)) {
                newDates.add(d);
            }
        }
        
        List<AvailableDate__c> inserts = new List<AvailableDate__c>();
        for (Date newDate : newDates) {
            inserts.add(new AvailableDate__c(Class__c = classId, Date__c = newDate));
        }
        insert inserts;
        
        return new PageReference('/' + classId);
    }

    public PageReference cancel() {
        return new PageReference('/' + classId);
    }
}