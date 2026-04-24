package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

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
