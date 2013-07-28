public with sharing class ClassCopyAllController {
	
	public class SelectableClass {
		
		public Boolean selected {get; set;}
		public Class__c sob {get; private set;}
		
		public SelectableClass(Class__c sob) {
			this.selected = true;
			this.sob = sob;
		}
 	}

    public class Week {
    
        public Integer num {
            get {
            	return Dates.weekNumber(mon.d);
            }
        }
    
        public SelectableDate mon {get; set;}
        public SelectableDate tue {get; set;}
        public SelectableDate wed {get; set;}
        public SelectableDate thu {get; set;}
        public SelectableDate fri {get; set;}
        public SelectableDate sat {get; set;}
        public SelectableDate sun {get; set;}
        
        public Week(Range__c range, Date start, Set<Date> unselectedDates) {
            this.start = start;
            mon = new SelectableDate(range, start, unselectedDates);
            tue = new SelectableDate(range, start.addDays(1), unselectedDates);
            wed = new SelectableDate(range, start.addDays(2), unselectedDates);
            thu = new SelectableDate(range, start.addDays(3), unselectedDates);
            fri = new SelectableDate(range, start.addDays(4), unselectedDates);
            sat = new SelectableDate(range, start.addDays(5), unselectedDates);
            sun = new SelectableDate(range, start.addDays(6), unselectedDates);
        }
        
        public Date start {get; private set;}
        
        public void appendSelectedDates(Set<Date> dates) {
            mon.addDate(dates, true);
            tue.addDate(dates, true);
            wed.addDate(dates, true);
            thu.addDate(dates, true);
            fri.addDate(dates, true);
            sat.addDate(dates, true);
            sun.addDate(dates, true);
        }
        
        public void appendUnselectedDates(Set<Date> dates) {
            mon.addDate(dates, false);
            tue.addDate(dates, false);
            wed.addDate(dates, false);
            thu.addDate(dates, false);
            fri.addDate(dates, false);
            sat.addDate(dates, false);
            sun.addDate(dates, false);
        }
    }

    public class SelectableDate {
    
        public Boolean s {get; set;}        // Selected
        public Date d {get; private set;}   // Date value
        public String f {                   // Formatted date value
             get {
                 return d.format();
             }
        }
        public Boolean r {get; set;}        // Render
        
        public SelectableDate(Range__c range, Date d, Set<Date> unselectedDates) {
            this.s = !unselectedDates.contains(d);
            this.d = d;
            this.r = range.From__c <= d && d <= range.To__c;
        }
        
        public void addDate(Set<Date> dates, Boolean selected) {
            if (r && s == selected) {
                dates.add(d);
            }
        }
    }

    public SelectableClass[] selectableClasses {get; private set;}
    private Id id;
    private ApexPages.StandardSetController controller;
    
    // Allows this controller's page to be used in place of a standard controller; page should just call forward method
    public ClassCopyAllController(ApexPages.StandardController controller) {
        id = controller.getRecord().Id;
    }
    
    public PageReference forwardToListController() {
        PageReference pr = Page.ClassCopyAllList;
        pr.getParameters().put('id', id);
        return pr;
    }
    
    // Allows this controller's page to be used in place of a standard list controller (providing the page also has recordsetvar set).
    public ClassCopyAllController(ApexPages.StandardSetController controller) {
        
        this.controller = controller;
        
        Id id = (Id) ApexPages.currentPage().getParameters().get('id');
        if (id != null) {
            controller.setSelected([
                  select
                          Id,
                          Name,
                          Coach__c,
                          Type__c,
                          Detail__c,
                          DayOfWeek__c,
                          Time__c,
                          Level__c,
                          Length__c,
                          BookingCount__c,
                          EarliestAvailableDate__c,
                          LatestAvailableDate__c,
                          DayOfWeekNumber__c
                  from Class__c
                  where Id = :id
                  order by Name
                  ]);
        } else {
        	if (!Test.isRunningTest()) {
	        	String[] fields = new String[] {
		        		String.valueOf(Class__c.Id),
		        		String.valueOf(Class__c.Name),
		        		String.valueOf(Class__c.Coach__c),
		        		String.valueOf(Class__c.Type__c),
		        		String.valueOf(Class__c.Detail__c),
		        		String.valueOf(Class__c.DayOfWeek__c),
		        		String.valueOf(Class__c.Time__c),
		        		String.valueOf(Class__c.Level__c),
		        		String.valueOf(Class__c.Length__c),
		        		String.valueOf(Class__c.BookingCount__c),
		        		String.valueOf(Class__c.EarliestAvailableDate__c),
		        		String.valueOf(Class__c.LatestAvailableDate__c),
		        		String.valueOf(Class__c.DayOfWeekNumber__c)
		        	    };
	        	controller.addFields(fields);
        	}
        }
        
        // Make selectable
        this.selectableClasses = new List<SelectableClass>();
        for (Class__c clazz: (List<Class__c>) controller.getSelected()) {
        	selectableClasses.add(new SelectableClass(clazz));
        }
    }

    public PageReference refreshDaysToInclude() {
        if (weeksRange.From__c != range.From__c || weeksRange.To__c != range.To__c) {
            weeks = modifyWeeks(weeks, range);
            weeksRange = range.clone();
        }
        return null;
    }
    
    public Range__c range {
        get {
            if (range == null) {
                // Don't default from/to so user has to select
                range = new Range__c();
            }
            return range;
        }
        private set;
    }
    
    // Can be both consecutive days and weekly
    public Boolean consecutiveDays {
        get {
        	if (consecutiveDays == null) {
        		consecutiveDays = false;
        		for (SelectableClass  sc : selectableClasses) {
        			if (sc.selected && sc.sob.DayOfWeekNumber__c == null) {
        				consecutiveDays = true;
        				break;
        			}
        		}
        	}
            return consecutiveDays;
        }
        private set;
    }
    public Boolean weekly {
        get {
            if (weekly == null) {
            	weekly = false;
                for (SelectableClass  sc : selectableClasses) {
                    if (sc.selected && sc.sob.DayOfWeekNumber__c != null) {
                        weekly = true;
                        break;
                    }
                }
            }
            return weekly;
        }
        private set;
    }

    public Week[] weeks {
        get {
            if (weeks == null) {
                weeks = modifyWeeks(null, range);
                weeksRange = range.clone();
            }
            return weeks;
        }
        private set;
    }
    private Range__c weeksRange {get; set;}
    
    private static List<Week> modifyWeeks(List<Week> existings, Range__c range) {
        
        // Preserve dates that have been unselected
        Set<Date> unselectedDates = new Set<Date>();
        if (existings != null && existings.size() > 0) {
            for (Week existing : existings) {
                existing.appendUnselectedDates(unselectedDates);
            }
        }
        
        List<Week> weeks = new List<Week>();
        for (Date d = Dates.precedingMonday(range.From__c); d <= range.To__c; d = d.addDays(7)) {
            weeks.add(new Week(range, d, unselectedDates));
        }
        return weeks;
    }
    
    public PageReference copy() {
    	
    	// Does the copy
    	List<Id> ids = new ClassCopyAll(getSelectedClassIds(), getSelectedDates()).copy();
    	
    	if (ids.size() > 0) {
    		// Go to overviw page (recently created items)
    		return new PageReference('/' + Class__c.SObjectType.getDescribe().getKeyPrefix() + '/o');
    	} else {
	        // Go back to original page before this one
	        return controller.cancel();
    	}
    }
    
    // Public for tests only
    public Set<Id> getSelectedClassIds() {
    	       
        Set<Id> classIds = new Set<Id>();
        for (SelectableClass sc : selectableClasses) {
            classIds.add(sc.sob.Id);
        }
        return classIds;
    }
    
    // Public for tests only
    public Set<Date> getSelectedDates() {

        Set<Date> dates = new Set<Date>();
        for (Week week : weeks) {
            week.appendSelectedDates(dates);
        }
        return dates;
    }
}