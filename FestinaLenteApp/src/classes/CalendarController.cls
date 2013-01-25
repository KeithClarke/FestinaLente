public with sharing class CalendarController {

    private static final String W = ' where ';
    private static final String A = ' and ';

    public Filter__c filter {get; private set;}
    public List<Back> backs {get; private set;}

    // Used for breadcrumbs
    public class Back {
        public Id id {get; private set;}
        public String name {get; private set;}
        public Back(Id id, String name) {
            this.id = id;
            this.name = name;
        }
    }

    public PageReference init() {

        Map<String, String> p = ApexPages.currentPage().getParameters();
        
        String clientId = p.get('clientId');
        String coachId = p.get('coachId');
        String horseId = p.get('horseId');
        String bookingId = p.get('bookingId');
        String classId = p.get('classId');
        
        // Transfer to fields for display/editing
        filter = new Filter__c(ShowBooked__c = true, ShowAvailable__c = true);
        if (clientId != null) {
            filter.Client__c = clientId;
        }
        if (coachId != null) {
            filter.Coach__c = coachId;
        }
        if (horseId != null) {
            filter.Horse__c = horseId;
        }
        if (bookingId != null) {
            filter.Booking__c = bookingId;
        }
        if (classId != null) {
            filter.Class__c = classId;
        }
        
        backs = new List<Back>();

        // Order here should match order of filter fields in page so "back" links are in matching order
        if (clientId != null) {
            backs.add(new Back(clientId, [select Name from Contact where Id = :clientId].Name));
        }
        if (coachId != null) {
            backs.add(new Back(coachId, [select Name from Contact where Id = :coachId].Name));
        }
        if (horseId != null) {
            backs.add(new Back(horseId, [select Name from Horse__c where Id = :horseId].Name));
        }
        if (bookingId != null) {
            backs.add(new Back(bookingId, [select Name from Booking__c where Id = :bookingId].Name));
        }
        if (classId != null) {
            backs.add(new Back(classId, [select Name from Class__c where Id = :classId].Name));
        }
        
        return null;
    }
  
    public PageReference refresh() {
    
        // Detailed data is transient so this will cause a re-generation using the current filter
        return null;
    }
    
    private BookedDate__c[] queryBookedDates() {
    
        // Only simple variables can be bound into queries
        String clientId = filter.Client__c;
        String coachId = filter.Coach__c;
        String horseId = filter.Horse__c;
        String bookingId = filter.Booking__c;
        String classId = filter.Class__c;
        
        // Build query
        String soql = ''
                + ' select'
                + '         Id, Name, Date__c,'
                + '         AvailableDate__r.Id,'
                + '         Booking__r.Id, Booking__r.Name, Booking__r.EarliestBookedDate__c, Booking__r.LatestBookedDate__c,'
                + '         Booking__r.Client__r.Name, Booking__r.Client__r.Level__c,'
                + '         Booking__r.Client__r.PreferredHorse__r.Name,'
                + '         Booking__r.Class__r.Coach__r.Name,'
                + '         Booking__r.Class__r.Id, Booking__r.Class__r.Name, Booking__r.Class__r.TimeInMinutes__c, Booking__r.Class__r.LengthInMinutes__c,'
                + '         Booking__r.Class__r.Type__c, Booking__r.Class__r.Detail__c, Booking__r.Class__r.Level__c'
                + ' from BookedDate__c'
                ;
        String op = W;
        if (clientId != null) {
            soql += op + 'Booking__r.Client__r.Id = :clientId';
            op = A;
        }
        if (coachId != null) {
            soql += op + 'Booking__r.Class__r.Coach__r.Id = :coachId';
            op = A;
        }
        if (horseId != null) {
            soql += op + 'Booking__r.Client__r.PreferredHorse__r.Id = :horseId';
            op = A;
        }
        if (bookingId != null) {
            soql += op + 'Booking__r.Id = :bookingId';
            op = A;
        }
        if (classId != null) {
            soql += op + 'Booking__r.Class__r.Id = :classId';
            op = A;
        }
        
        System.debug('>>> booked dates soql=' + soql);
        return Database.query(soql);
    }
    
    private AvailableDate__c[] queryAvailableDates(Set<Id> skipIds) {
    
        // Only simple variables can be bound into queries
        String coachId = filter.Coach__c;
        String classId = filter.Class__c;
        
        // Build query
        String soql = ''
                + ' select'
                + '         Id, Name, Date__c,'
                + '         Class__r.Coach__r.Name,'
                + '         Class__r.Id, Class__r.Name, Class__r.TimeInMinutes__c, Class__r.LengthInMinutes__c,'
                + '         Class__r.Type__c, Class__r.Detail__c, Class__r.Level__c'
                + ' from AvailableDate__c'
                ;
        String op = W;
        if (coachId != null) {
            soql += op + 'Class__r.Coach__r.Id = :coachId';
            op = A;
        }
        if (classId != null) {
            soql += op + 'Class__r.Id = :classID';
            op = A;
        }
        
        // If already being presented as a booked date don't show again as an available date
        if (skipIds.size() > 0) {
            soql += op + 'Id not in :skipIds';
            op = A;
        }
        
        System.debug('>>> available dates soql=' + soql);
        return Database.query(soql);
    }

    public String events {
        get {
            JSONGenerator g = JSON.createGenerator(true);
            g.writeStartArray();
            Set<Id> adIds = new Set<Id>();
            if (filter.ShowBooked__c) {
                for (BookedDate__c bd : queryBookedDates()) {
                    g.writeStartObject();
                    g.writeStringField('title', getTitle(bd));
                    g.writeStringField('tooltip', getTooltip(bd));
                    g.writeDateTimeField('start', getStartDateTime(bd.Date__c, bd.Booking__r.Class__r));
                    g.writeDateTimeField('end', getEndDateTime(bd.Date__c, bd.Booking__r.Class__r));
                    g.writeStringField('url', '/' + bd.Booking__r.Id);
                    g.writeStringField('color', '#ff6699');
                    g.writeEndObject();
                    adIds.add(bd.AvailableDate__r.Id);
                }
            }
            if (filter.ShowAvailable__c) {
                for (AvailableDate__c ad : queryAvailableDates(adIds)) {
                    g.writeStartObject();
                    g.writeStringField('title', getTitle(ad));
                    g.writeStringField('tooltip', getTooltip(ad));
                    g.writeDateTimeField('start', getStartDateTime(ad.Date__c, ad.Class__r));
                    g.writeDateTimeField('end', getEndDateTime(ad.Date__c, ad.Class__r));
                    g.writeStringField('url', '/' + ad.Class__r.Id);
                    g.writeStringField('color', '#6699ff');
                    g.writeEndObject();
                }
            }
            g.writeEndArray();
            return g.getAsString();
        }
    }
    
    private String getTitle(BookedDate__c bd) {

        return bd.Booking__r.Name;
    }
    
    private String getTitle(AvailableDate__c ad) {

        return ad.Class__r.Name;
    }
    
    private String getTooltip(BookedDate__c bd) {
    
        Booking__c b = bd.Booking__r;
        Class__c c = b.Class__r;
        
        String s = 'Booking: <b>' + b.Name + '</b>';
        if (b.Client__r != null) {
            s += '<br/>Client: ' + b.Client__r.Name;
        }
        if (b.Client__r != null && b.Client__r.Level__c != null) {
            s += '<br/>Level: ' + b.Client__r.Level__c;
        }
        if (b.Client__r != null && b.Client__r.PreferredHorse__r != null) {
            s += '<br/>Preferred Horse: ' + b.Client__r.PreferredHorse__r.Name;
        }
        
        s += '<br/>';
        
        s += '<br/>Class: <b>' + c.Name + '</b>';
        s += '<br/>Type: ' + c.Type__c;
        if (c.Detail__c != null) {
            s += '<br/>Detail: ' + c.Detail__c;
        }
        if (c.Level__c != null) {
            s += '<br/>Level: ' + c.Level__c;
        }
        if (c.Coach__r != null) {
            s += '<br/>Coach: ' + c.Coach__r.Name;
        }
        
        return s;
    }
    
    private String getTooltip(AvailableDate__c ad) {
    
        Class__c c = ad.Class__r;

        String s = 'Class: <b>' + c.Name + '</b>';
        s += '<br/>Type: ' + c.Type__c;
        if (c.Detail__c != null) {
            s += '<br/>Detail: ' + c.Detail__c;
        }
        if (c.Level__c != null) {
            s += '<br/>Level: ' + c.Level__c;
        }
        if (c.Coach__r != null) {
            s += '<br/>Coach: ' + c.Coach__r.Name;
        }
        
        return s;
    }

    private DateTime getStartDateTime(Date d, Class__c c) {
        return toDateTime(d, defaultTime(c.TimeInMinutes__c));
    }
    
    private DateTime getEndDateTime(Date d, Class__c c) {
        return toDateTime(d, defaultTime(c.TimeInMinutes__c) + defaultLength(c.LengthInMinutes__c));
    }
    
    private DateTime toDateTime(Date d, Integer minutesIntoDay) {
        return DateTime.newInstance(d.year(), d.month(), d.day(), minutesIntoDay / 60, Math.mod(minutesIntoDay, 60), 0);
    }
    
    private Integer defaultTime(Decimal t) {
        return t != null ? t.intValue() : 8;
    }
    
    private Integer defaultLength(Decimal l) {
        return l != null ? l.intValue() : 45;
    }
}