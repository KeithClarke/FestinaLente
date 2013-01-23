@isTest
private class CellTest {

    @isTest
    static void html() {
    
        System.assertEquals('<td></td>', new Cell().html);
        
        Cell c = new Cell('content');
        c.styleClass = 'sss';
        c.style = 'color: red';
        c.colspan = 3;
        System.assertEquals('<td class="sss" style="color: red" colspan="3">content</td>', c.html);
    }
}