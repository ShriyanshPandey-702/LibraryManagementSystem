package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.IssueDAO;

@WebServlet("/StudentPayFineServlet")
public class StudentPayFineServlet extends HttpServlet {

    private final IssueDAO issueDAO = new IssueDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentUser") == null) {
            response.sendRedirect("StudentLoginServlet");
            return;
        }

        Integer studentId = (Integer) session.getAttribute("studentId");
        if (studentId == null) {
            response.sendRedirect("StudentLoginServlet");
            return;
        }

        String issueIdParam = request.getParameter("issueId");
        if (issueIdParam != null && !issueIdParam.trim().isEmpty()) {
            try {
                int issueId = Integer.parseInt(issueIdParam);
                if (issueDAO.payFine(issueId, studentId)) {
                    request.getSession().setAttribute("flashSuccess", "Payment receipt #PAY-" + System.currentTimeMillis() % 100000 + " processed successfully! Fine marked as Paid.");
                } else {
                    request.getSession().setAttribute("flashError", "Failed to process fine payment.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                request.getSession().setAttribute("flashError", "Invalid payment transaction.");
            }
        }

        response.sendRedirect("StudentFineStatusServlet");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("StudentFineStatusServlet");
    }
}
