package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import util.DBConnection;

public class FineSettingsDAO {

    public double getFinePerDay() {
        String sql = "SELECT fine_per_day FROM fine_settings WHERE id=1";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getDouble("fine_per_day");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 5.0;
    }

    public boolean updateFinePerDay(double finePerDay) {
        String sql = "INSERT INTO fine_settings (id, fine_per_day) VALUES (1, ?) ON DUPLICATE KEY UPDATE fine_per_day = VALUES(fine_per_day)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDouble(1, finePerDay);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
