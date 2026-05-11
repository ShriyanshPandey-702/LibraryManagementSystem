package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.IssueDAO;

@WebServlet("/ReturnBookServlet")
public class ReturnBookServlet extends HttpServlet {

    private final IssueDAO issueDAO = new IssueDAO();

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

        request.setAttribute("issuedBooks", issueDAO.getActiveIssues());
        request.getRequestDispatcher("jsp/return-book.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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

        try {
            int issueId = Integer.parseInt(request.getParameter("issueId"));
            double fineAmount = issueDAO.returnBook(issueId);

            if (fineAmount >= 0) {
                request.setAttribute("successMessage", "Book returned successfully");
                request.setAttribute("fineMessage", "Fine Amount: Rs. " + fineAmount);
            } else {
                request.setAttribute("errorMessage", "Unable to return this book");
            }

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Invalid return request");
        }

        request.setAttribute("issuedBooks", issueDAO.getActiveIssues());
        request.getRequestDispatcher("jsp/return-book.jsp").forward(request, response);
    }
}
