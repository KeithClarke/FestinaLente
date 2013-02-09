/**
 * Maths operations that handle nulls.
 */
public class Maths {

    public static Date min(Date d1, Date d2) {
        if (d1 != null && d2 != null) {
            return d1 < d2 ? d1 : d2;
        } else if (d1 != null) {
            return d1;
        } else if (d2 != null) {
            return d2;
        } else {
            return null;
        }
    }
    
    public static Date max(Date d1, Date d2) {
        if (d1 != null && d2 != null) {
            return d1 > d2 ? d1 : d2;
        } else if (d1 != null) {
            return d1;
        } else if (d2 != null) {
            return d2;
        } else {
            return null;
        }
    }
}