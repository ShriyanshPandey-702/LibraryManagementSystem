package controller;

import dao.BookDAO;
import dao.BookRequestDAO;
import dao.StudentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {

    private final BookDAO        bookDAO        = new BookDAO();
    private final BookRequestDAO bookRequestDAO = new BookRequestDAO();
    private final StudentDAO     studentDAO     = new StudentDAO();
    private final dao.IssueDAO   issueDAO       = new dao.IssueDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Auth check (belt-and-suspenders; AdminAuthFilter handles this too)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        request.setAttribute("totalBooks",           bookDAO.getTotalBookTitles());
        request.setAttribute("totalQuantity",        bookDAO.getTotalBookCopies());
        request.setAttribute("lowStock",             bookDAO.getLowStockCount());
        request.setAttribute("pendingRequests",      bookRequestDAO.getPendingRequestCount());
        request.setAttribute("totalStudents",        studentDAO.countStudents());
        request.setAttribute("totalIssued",          issueDAO.getTotalIssuedBooks());
        request.setAttribute("categoryDistribution", bookDAO.getCategoryDistribution());
        request.setAttribute("borrowingTrends",      issueDAO.getRecentBorrowingTrends());

        request.getRequestDispatcher("jsp/dashboard.jsp").forward(request, response);
    }
}
