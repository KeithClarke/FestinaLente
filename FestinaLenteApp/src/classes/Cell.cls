public class Cell {

    public Cell() {
    }

    public Cell(String text) {
        this.text = text;
    }
    
    public Cell(String text, String styleClass) {
        this.text = text;
        this.styleClass = styleClass;
    }

    public String text {get; set;}
    public String styleClass {get; set;}
    public String style {get; set;}
    public Integer colspan {get; set;}
    
    public String html {
        get {
            String s = '<td';
            if (styleClass != null) {
                s += ' class="' + styleClass + '"';
            }
            if (style != null) {
                s += ' style="' + style + '"';
            }
            if (colspan != null) {
                s += ' colspan="' + colspan + '"';
            }
            s += '>';
            if (text != null) {
                s += text;
            }
            s += '</td>';
            return s;
        }
    }
}