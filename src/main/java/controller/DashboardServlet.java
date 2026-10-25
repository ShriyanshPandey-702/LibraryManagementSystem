package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookDAO;
import dao.BookRequestDAO;
import dao.StudentDAO;
import dao.IssueDAO;
import util.DBConnection;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {

    private final BookDAO        bookDAO        = new BookDAO();
    private final BookRequestDAO bookRequestDAO = new BookRequestDAO();
    private final StudentDAO     studentDAO     = new StudentDAO();
    private final IssueDAO       issueDAO       = new IssueDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        int overdueCount = 0;
        double outstandingFines = 0.0;
        int pendingReservations = 0;
        int pendingReports = 0;
        double catalogAvgRating = 0.0;

        String metricsSql = 
            "SELECT " +
            " (SELECT COUNT(*) FROM issue_books WHERE status='Issued' AND due_date < CURDATE()) as overdue_cnt, " +
            " (SELECT COALESCE(SUM(fine), 0.0) FROM issue_books WHERE status='Issued' AND fine_paid=0) as fines_total, " +
            " (SELECT COUNT(*) FROM book_reservations WHERE status IN ('Waiting', 'Ready for Pickup')) as res_cnt, " +
            " (SELECT COUNT(*) FROM lost_damaged_reports WHERE status IN ('Pending', 'Under Review')) as rep_cnt, " +
            " (SELECT COALESCE(AVG(rating), 0.0) FROM book_reviews WHERE is_hidden=0) as avg_rat";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(metricsSql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                overdueCount = rs.getInt("overdue_cnt");
                outstandingFines = rs.getDouble("fines_total");
                pendingReservations = rs.getInt("res_cnt");
                pendingReports = rs.getInt("rep_cnt");
                catalogAvgRating = rs.getDouble("avg_rat");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("totalBooks",           bookDAO.getTotalBookTitles());
        request.setAttribute("totalQuantity",        bookDAO.getTotalBookCopies());
        request.setAttribute("lowStock",             bookDAO.getLowStockCount());
        request.setAttribute("pendingRequests",      bookRequestDAO.getPendingRequestCount());
        request.setAttribute("totalStudents",        studentDAO.countStudents());
        request.setAttribute("totalIssued",          issueDAO.getTotalIssuedBooks());
        request.setAttribute("overdueCount",         overdueCount);
        request.setAttribute("outstandingFines",     outstandingFines);
        request.setAttribute("pendingReservations",  pendingReservations);
        request.setAttribute("pendingReports",       pendingReports);
        request.setAttribute("catalogAvgRating",     catalogAvgRating);
        request.setAttribute("categoryDistribution", bookDAO.getCategoryDistribution());
        request.setAttribute("borrowingTrends",      issueDAO.getRecentBorrowingTrends());
        request.setAttribute("recentLoans",          issueDAO.getAllIssues());

        request.getRequestDispatcher("jsp/dashboard.jsp").forward(request, response);
    }
}
