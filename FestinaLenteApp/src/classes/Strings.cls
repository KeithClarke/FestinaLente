public class Strings {

    public static String join(List<String> l, String separator) {
    	return String.join(l, separator);
    }
    
    public static String join(Set<String> s, String separator) {
    	List<String> l = new List<String>(s);
    	l.sort();
    	return join(l, separator);
    }
}