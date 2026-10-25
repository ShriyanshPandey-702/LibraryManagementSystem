package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.IssueDAO;

@WebServlet("/StudentReturnBookServlet")
public class StudentReturnBookServlet extends HttpServlet {

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
                int issueId = Integer.parseInt(issueIdParam.trim());
                IssueDAO.IssueResult result = issueDAO.returnBookByStudent(issueId, studentId);
                if (result.isSuccess()) {
                    request.getSession().setAttribute("flashSuccess", result.getMessage());
                } else {
                    request.getSession().setAttribute("flashError", result.getMessage());
                }
            } catch (Exception e) {
                e.printStackTrace();
                request.getSession().setAttribute("flashError", "Invalid return request.");
            }
        }

        response.sendRedirect("StudentIssuedBooksServlet");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("StudentIssuedBooksServlet");
    }
}
