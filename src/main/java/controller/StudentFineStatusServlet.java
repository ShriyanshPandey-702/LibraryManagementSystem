package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.IssueDAO;

@WebServlet("/StudentFineStatusServlet")
public class StudentFineStatusServlet extends HttpServlet {

    private final IssueDAO issueDAO = new IssueDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("StudentLoginServlet");
            return;
        }

        if (session.getAttribute("adminUser") != null) {
            response.sendRedirect("DashboardServlet");
            return;
        }

        Integer studentId = (Integer) session.getAttribute("studentId");
        if (studentId == null) {
            response.sendRedirect("StudentLoginServlet");
            return;
        }

        request.setAttribute("issuedBooks", issueDAO.getIssuesByStudentId(studentId));
        request.getRequestDispatcher("jsp/student-fine-status.jsp").forward(request, response);
    }
}
