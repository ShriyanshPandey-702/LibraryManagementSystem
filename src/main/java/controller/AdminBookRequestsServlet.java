package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.BookRequestDAO;

@WebServlet("/AdminBookRequestsServlet")
public class AdminBookRequestsServlet extends HttpServlet {

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

        if ("1".equals(request.getParameter("approved"))) {
            request.setAttribute("successMessage", "Book issued and request approved successfully.");
        }

        request.setAttribute("pendingRequests", bookRequestDAO.getPendingRequests());
        request.getRequestDispatcher("jsp/admin-book-requests.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        String action = request.getParameter("action");
        if ("reject".equals(action)) {
            try {
                int requestId = Integer.parseInt(request.getParameter("requestId"));
                bookRequestDAO.markRequestRejected(requestId);
                response.sendRedirect("AdminBookRequestsServlet?rejected=1");
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("AdminBookRequestsServlet");
    }
}
