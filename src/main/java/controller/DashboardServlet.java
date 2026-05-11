package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookDAO;
import dao.BookRequestDAO;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final BookRequestDAO bookRequestDAO = new BookRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            if (session != null && session.getAttribute("studentUser") != null) {
                response.sendRedirect("StudentDashboardServlet");
            } else {
                response.sendRedirect("LoginServlet");
            }
            return;
        }

        request.setAttribute("totalBooks", bookDAO.getTotalBookTitles());
        request.setAttribute("totalQuantity", bookDAO.getTotalBookCopies());
        request.setAttribute("lowStock", bookDAO.getLowStockCount());
        request.setAttribute("pendingRequests", bookRequestDAO.getPendingRequestCount());
        request.getRequestDispatcher("jsp/dashboard.jsp").forward(request, response);
    }
}
