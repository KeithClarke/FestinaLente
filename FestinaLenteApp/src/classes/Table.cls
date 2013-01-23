public class Table {

    public void addDateOnce(Date d) {
        if (!dateSet.contains(d)) {
            dateSet.add(d);
            dateList.add(d);
        }
    }

    private Set<Date> dateSet {
        get {
            if (dateSet == null) {
                dateSet = new Set<Date>();
            }
            return dateSet;
        }
        private set;
    }
    
    public List<Date> dateList {
        get {
            if (dateList == null) {
                dateList = new List<Date>();
            }
            return dateList;
        }
        private set;
    }

    public void addClassOnce(Class__c clazz) {
        if (!classIds.contains(clazz.Id)) {
            classIds.add(clazz.Id);
            classes.add(clazz);
        }
    }
    
    private Set<Id> classIds {
        get {
            if (classIds == null) {
                classIds = new Set<Id>();
            }
            return classIds;
        }
        private set;
    }

    public List<Class__c> classes {
        get {
            if (classes == null) {
                classes = new List<Class__c>();
            }
            return classes;
        }
        private set;
    }

    public List<AvailableDate__c> ads {
        get {
            if (ads == null) {
                ads = new List<AvailableDate__c>();
            }
            return ads;
        }
        private set;
    }

    public Set<String> clientSet {
        get {
            if (clientSet == null) {
                clientSet = new Set<String>();
            }
            return clientSet;
        }
        private set;
    }
    
    public Set<T> timeSet {
        get {
            if (timeSet == null) {
                timeSet = new Set<T>();
            }
            return timeSet;
        }
        private set;
    }

    public List<Row> rows {
        get {
            if (rows == null) {
                rows = new List<Row>();
            }
            return rows;
        }
        private set;
    }
    
    public Integer getMaxColCount() {
        Integer max = 0;
        for (Row r : rows) {
            if (r.cells.size() > max) {
                max = r.cells.size();
            }
        }
        return max;
    }
    
    public Integer[] getPerColStyleClassCount(String styleClass) {
        List<Integer> l = new List<Integer>();
        Integer max = getMaxColCount();
        for (Integer i = 0; i < max; i++) {
            l.add(0);
        }
        for (Row r : rows) {
            for (Integer i = 0; i < r.cells.size(); i++) {
                if (r.cells.get(i).styleClass == styleClass) {
                    l.set(i, l.get(i) + 1);
                }
            }
        }
        return l;
    }
    
    public List<String> getSortedClients() {
        List<String> l = new List<String>(clientSet);
        l.sort();
        return l;
    }
    
    public List<T> getSortedTimes() {
        List<T> l = new List<T>(timeSet);
        l.sort();
        return l;
    }
    
    public List<AvailableDate__c> getAvailableDatesForClass(Class__c clazz) {
         List<AvailableDate__c> l = new List<AvailableDate__c>();
         for (AvailableDate__c ad : ads) {
             if (ad.Class__r.Id == clazz.Id) {
                 l.add(ad);
             }
         }
         return l;
    }
}