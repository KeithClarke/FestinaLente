public class Dates {
	
	private static final Date SUNDAY = Date.newInstance(2010, 1, 3);

    private static final Map<String, Integer> DAY_NAME_TO_INTEGER = new Map<String, Integer>{
        'Sunday' => 0,
        'Monday' => 1,
        'Tuesday' => 2,
        'Wednesday' => 3,
        'Thursday' => 4,
        'Friday' => 5,
        'Saturday' => 6
    };
    private static Map<Integer, Integer> OFFSET_TO_PRECEDING_MONDAY = new map<Integer, Integer>{
        0 => -6,
        1 => 0,
        2 => -1,
        3 => -2,
        4 => -3,
        5 => -4,
        6 => -5
    };
    
    private static final Map<Integer, String> DAY_INTEGER_TO_NAME = new Map<Integer, String>();
    static {
        for (String day : DAY_NAME_TO_INTEGER.keySet()) {
            DAY_INTEGER_TO_NAME.put(DAY_NAME_TO_INTEGER.get(day), day);
        }
    }
    
    public static String dayIntegerToString(Integer i) {
        return DAY_INTEGER_TO_NAME.get(i);
    }
    
    public static Integer dayStringToInteger(String s) {
        return DAY_NAME_TO_INTEGER.get(s);
    }

    // Sunday is 0, Monday is 1 etc
    public static Integer dayOfWeek(Date d) {
        if (d != null) {
            return Math.mod(SUNDAY.daysBetween(d), 7);
        } else {
            return null;
        }
    }
    
    public static Date precedingMonday(Date d) {
        return d != null ? d.addDays(OFFSET_TO_PRECEDING_MONDAY.get(dayOfWeek(d))) : null;
    }
    
    public static Integer weekNumber(Date d) {
        // TODO check same as formula on available date
        // TODO test
        Integer days = Date.newInstance(2001, 1, 1).daysBetween(d);
        return Math.mod(days / 7, 52) + 1;
    }
    
    public static Boolean isEvenWeekNumber(Date d) {
    	return Math.mod(weekNumber(d), 2) == 0;
    }
}