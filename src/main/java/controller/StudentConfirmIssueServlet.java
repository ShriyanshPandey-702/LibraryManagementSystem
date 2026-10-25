package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.IssueDAO;
import model.Student;

@WebServlet("/StudentConfirmIssueServlet")
public class StudentConfirmIssueServlet extends HttpServlet {

    private final IssueDAO issueDAO = new IssueDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/StudentLoginServlet");
            return;
        }

        Student student = (Student) session.getAttribute("studentUser");
        int studentId = student.getId();

        String issueIdParam = request.getParameter("issueId");
        String action = request.getParameter("action");
        String reason = request.getParameter("reason");
        String redirectTarget = request.getParameter("redirect");

        if (issueIdParam == null || issueIdParam.trim().isEmpty() || action == null) {
            session.setAttribute("flashError", "Invalid confirmation request parameters.");
            redirectBack(request, response, redirectTarget);
            return;
        }

        try {
            int issueId = Integer.parseInt(issueIdParam.trim());

            if ("accept".equalsIgnoreCase(action)) {
                IssueDAO.IssueResult result = issueDAO.acceptBookIssue(issueId, studentId);
                if (result.isSuccess()) {
                    session.setAttribute("flashSuccess", result.getMessage());
                } else {
                    session.setAttribute("flashError", result.getMessage());
                }
            } else if ("reject".equalsIgnoreCase(action)) {
                IssueDAO.IssueResult result = issueDAO.rejectBookIssue(issueId, studentId, reason);
                if (result.isSuccess()) {
                    session.setAttribute("flashSuccess", result.getMessage());
                } else {
                    session.setAttribute("flashError", result.getMessage());
                }
            } else {
                session.setAttribute("flashError", "Unrecognized confirmation action.");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("flashError", "Invalid loan identifier.");
        } catch (Exception e) {
            session.setAttribute("flashError", "An unexpected error occurred while processing confirmation.");
        }

        redirectBack(request, response, redirectTarget);
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response, String redirectTarget)
            throws IOException {
        if ("history".equalsIgnoreCase(redirectTarget)) {
            response.sendRedirect(request.getContextPath() + "/StudentBorrowingHistoryServlet");
        } else {
            response.sendRedirect(request.getContextPath() + "/StudentIssuedBooksServlet");
        }
    }
}
