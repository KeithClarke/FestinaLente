public class Dates {

    private static final Map<String, Integer> DAY_NAME_TO_INTEGER = new Map<String, Integer>{
        'Sunday' => 0,
        'Monday' => 1,
        'Tuesday' => 2,
        'Wednesday' => 3,
        'Thursday' => 4,
        'Friday' => 5,
        'Saturday' => 6
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
            Date sunday = Date.newInstance(2010, 1, 3);
            return Math.mod(sunday.daysBetween(d), 7);
        } else {
            return null;
        }
    }
}