package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

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
