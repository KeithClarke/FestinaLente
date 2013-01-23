public class Row {

    public List<Cell> cells {
        get {
            if (cells == null) {
                cells = new List<Cell>();
            }
            return cells;
        }
        private set;
    }
}