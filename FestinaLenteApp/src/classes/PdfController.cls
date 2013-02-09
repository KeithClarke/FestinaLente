public with sharing class PdfController {
 
    public String format {
        get {
            String s = ApexPages.currentPage().getParameters().get('format');
            return s != null && s.length() > 0 ? s : 'PDF';
        }
    }
    
    public String layout {
        get {
            String s = ApexPages.currentPage().getParameters().get('layout');
            return s != null && s.length() > 0 ? s : 'landscape';
        }
    }

    public String formattedFrom {
        get {
            return fromDate.format();
        }
    }
    
    public String formattedTo {
        get {
            return toDate.format();
        }
    }

    private Date fromDate {
        get {
            if (fromDate == null) {
                fromDate = Date.parse(ApexPages.currentPage().getParameters().get('from'));
            }
            return fromDate;
        }
        private set;
    }
    
    private Date toDate {
        get {
            if (toDate == null) {
                toDate = Date.parse(ApexPages.currentPage().getParameters().get('to'));
            }
            return toDate;
        }
        private set;
    }
    
    public List<String> days {
        get {
            if (days == null) {
                String s = ApexPages.currentPage().getParameters().get('days');
                if (s.length() > 0) {
                    days = s.split(',');
                } else {
                    days = new List<String>();
                }
            }
            return days;
        }
        private set;
    }
    
    private AvailableDate__c[] query(String type) {
        return [
                select
                        Date__c,
                        DayOfWeek__c,
                        Class__r.Id,
                        Class__r.Name,
                        Class__r.Type__c,
                        Class__r.Detail__c,
                        Class__r.DayOfWeek__c,
                        Class__r.DayOfWeekNumber__c,
                        Class__r.Time__c,
                        Class__r.TimeInMinutes__c,
                        Class__r.Level__c,
                        Class__r.Length__c,
                        Class__r.Coach__r.Id,
                        Class__r.Coach__r.Name,
                        Class__r.Coach__r.ColourCode__c,
                        (select Booking__r.Client__r.Id, Booking__r.Client__r.Name from BookedDates__r)
                from AvailableDate__c
                where Class__r.Type__c = :type
                and Class__r.BookedDateCount__c > 0
                and Date__c >= :fromDate
                and Date__c <= :toDate
                and DayOfWeek__c in :days
                order by Class__r.DayOfWeekNumber__c, Class__r.TimeInMinutes__c, Class__r.Coach__r.Name, Date__c
                ];
    }
    
    public List<Table> termRidings {
        get {
        
            List<Table> tableList = new List<Table>();
            Map<Id, Table> tableMap = new Map<Id, Table>();
            
            AvailableDate__c[] ads = query('Term');
            
            // Create multiple tables
            for (AvailableDate__c ad : ads) {
            
                Table t = tableMap.get(ad.Class__r.Id);
                if (t == null) {
                
                    // Create table
                    t = new Table();
                    tableMap.put(ad.Class__r.Id, t);
                    tableList.add(t);
                    
                    // Add header row/cell (colspan set later)
                    Row r = new Row();
                    t.rows.add(r);
                    
                    Cell c = new Cell();
                    r.cells.add(c);
                    
                    c.text = ad.DayOfWeek__c
                            + ': ' + ad.Class__r.Time__c
                            + (ad.Class__r.Level__c != null ? ' (' + ad.Class__r.Level__c + ') ' : '')
                            + (ad.Class__r.Detail__c != null ? ad.Class__r.Detail__c : '')
                            + '<br/>' + ad.Class__r.Name
                            + (ad.Class__r.Coach__r.Name != null ? ' - ' + ad.Class__r.Coach__r.Name : '')
                            ;
                }
                t.ads.add(ad);
                
                // Figure out set of clients
                for (BookedDate__c bd : ad.BookedDates__r) {
                    t.clientSet.add(bd.Booking__r.Client__r.Name);
                }
            }
            
            // Add the date row
            for (Table t : tableList) {
            
                // Add date row
                Row r = new Row();
                t.rows.add(r);
                
                // Blank cell above client names
                r.cells.add(new Cell());
                
                // Date cells
                for (AvailableDate__c ad : t.ads) {
                    // Add date cells
                    Cell c = new Cell();
                    r.cells.add(c);
                    c.text = format(ad.Date__c);
                }
            }
            
            // Add row per client
            for (Table t : tableList) {
                for (String client : t.getSortedClients()) {
                    Row r = new Row();
                    t.rows.add(r);
                    
                    // Client names
                    Cell cc = new Cell();
                    r.cells.add(cc);
                    cc.text = client;
                    cc.styleClass = 'name';
                    
                    // Whether there is a booking for the dat
                    for (AvailableDate__c ad : t.ads) {
                        Cell ccc = new Cell();
                        r.cells.add(ccc);
                        ccc.styleClass = isBooking(new List<AvailableDate__c>{ad}, new Set<String>{client}) ? 'booked' : 'unbooked';
                    }
                }
            }
            
            // Booked count row
            for (Table t : tableList) {
                
                Row r = new Row();
                t.rows.add(r);
                
                Integer[] bookedCounts = t.getPerColStyleClassCount('booked');
                for (Integer i = 0; i < bookedCounts.size(); i++) {
                     Cell c = new Cell();
                     r.cells.add(c);
                     
                     if (i > 0) {
                         c.text = String.valueOf(bookedCounts[i]);
                     }
                }
            }
            
            // Update heading cell
            for (Table t : tableList) {
                Cell c = t.rows[0].cells[0];
                c.styleClass = 'heading';
                c.colspan = t.getMaxColCount();
            }

            return tableList;
        }
    }
  
    public List<Table> privateLessons {
        get {
        
            List<Table> tableList = new List<Table>();
            Map<String, Table> tableMap = new Map<String, Table>();
            
            AvailableDate__c[] ads = query('Private Lesson');
            
            // Create multiple tables
            for (AvailableDate__c ad : ads) {
            
                Table t = tableMap.get(ad.Class__r.DayOfWeek__c);
                if (t == null) {
                
                    // Create table
                    t = new Table();
                    tableMap.put(ad.Class__r.DayOfWeek__c, t);
                    tableList.add(t);
                    
                    // Add header row/cell (colspan set later)
                    Row r = new Row();
                    t.rows.add(r);
                    
                    Cell c = new Cell();
                    r.cells.add(c);
                    
                    c.text = ad.DayOfWeek__c;
                }
                t.ads.add(ad);
                t.addClassOnce(ad.Class__r);
            }
            
            // Add the date row
            List<Date> dateList = new List<Date>();
            for (Table t : tableList) {
            
                // Add date row
                Row r = new Row();
                t.rows.add(r);
                
                // Headings
                r.cells.add(new Cell('Coach'));
                r.cells.add(new Cell('Time'));
                r.cells.add(new Cell('Client'));
                
                // Date cells
                for (AvailableDate__c ad : t.ads) {
                    t.addDateOnce(ad.Date__c);
                }
                for (Date d : t.dateList) {
                    Cell c = new Cell();
                    r.cells.add(c);
                    c.text = format(d);
                }
            }
            
            // Add row per Class: Coach/Time/Client(s) in each
            for (Table t : tableList) {
                for (Class__c clazz : t.classes) {
                    Row r = new Row();
                    t.rows.add(r);
                    
                    Cell c = new Cell();
                    r.cells.add(c);
                    c.text = clazz.Coach__r.Name;
                    
                    // PDF required hex vales to be used
                    String colour = clazz.Coach__r.ColourCode__c;
                    if (colour != null) {
                        Integer s = colour.indexOf('(');
                        Integer e = colour.lastIndexOf(')');
                        if (s != -1 && e != -1) {
                            c.style = 'background-color: ' + colour.substring(s + 1, e);
                        }
                    }
                    
                    c.styleClass = 'name';
                    
                    Cell cc = new Cell();
                    r.cells.add(cc);
                    cc.text = clazz.Time__c;
                    
                    // Client names
                    Cell ccc = new Cell();
                    r.cells.add(ccc);
                    
                    List<AvailableDate__c> classAds = t.getAvailableDatesForClass(clazz);
                    
                    Set<String> nameSet = new Set<String>();
                    for (AvailableDate__c ad : classAds) {
                        for (BookedDate__c bd : ad.BookedDates__r) {
                            nameSet.add(bd.Booking__r.Client__r.Name);
                        }
                    }
                    List<String> nameList = new List<String>(nameSet);
                    nameList.sort();
                    ccc.text = String.valueOf(csv(nameList));
                    ccc.styleClass = 'name';
                    
                    // Whether there is a booking for the date
                    for (Date d : t.dateList) {
                        Cell cccc = new Cell();
                        r.cells.add(cccc);
                        cccc.styleClass = isBooking(filter(classAds, d), nameSet) ? 'booked' : 'unbooked';
                    }
                }
            }
            
            // Update heading cell
            for (Table t : tableList) {
                Cell c = t.rows[0].cells[0];
                c.styleClass = 'heading';
                c.colspan = t.getMaxColCount();
            }

            return tableList;
        }
    }
    
    private List<AvailableDate__c> filter(List<AvailableDate__c> ads, Date d) {
        List<AvailableDate__c> l = new List<AvailableDate__c>();
        for (AvailableDate__c ad : ads) {
            if (ad.Date__c == d) {
                l.add(ad);
            }
        }
        return l;
    }
    
    private String format(Date d) {
        return DateTime.newInstance(d.year(), d.month(), d.day()).format('d-MMM');
    }
    
    private String csv(List<String> ss) {
        String r = '';
        for (String s : ss) {
            if (r.length() > 0) {
                r += ', ';
            }
            r += s;
        }
        return r;
    }
    
    // TODO should use client id not name
    private Boolean isBooking(List<AvailableDate__c> ads, Set<String> clients) {
        for (AvailableDate__c ad : ads) {
            for (BookedDate__c bd : ad.BookedDates__r) {
                if (clients.contains(bd.Booking__r.Client__r.Name)) {
                    return true;
                }
            }
        }
        return false;
    }
}