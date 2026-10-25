import util.DBConnection;

public class TestConnection {
    public static void main(String[] args) {
        try {
            DBConnection.getConnection();
            System.out.println("Database connection successful!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}