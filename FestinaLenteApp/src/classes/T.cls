// Time
public class T implements Comparable {

    // Minutes
    public Integer i {get; private set;}
    
    // Formatted
    public String s {get; private set;}
    
    public T(Integer i, String s) {
        this.i = i;
        this.s = s;
    }
    
    public Integer compareTo(Object compareTo) {
        T that = (T) compareTo;
        if (that.i > this.i) {
            return 1;
        } else if (that.i < this.i) {
            return -1;
        } else {
            return 0;
        }
    }
}