package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.LostDamagedDAO;
import model.Student;

@WebServlet("/StudentReportBookServlet")
public class StudentReportBookServlet extends HttpServlet {

    private final LostDamagedDAO lostDamagedDAO = new LostDamagedDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentUser") == null) {
            response.sendRedirect("StudentLoginServlet");
            return;
        }

        Student student = (Student) session.getAttribute("studentUser");

        try {
            int issueId = Integer.parseInt(request.getParameter("issueId"));
            int bookId = Integer.parseInt(request.getParameter("bookId"));
            String reportType = request.getParameter("reportType");
            String description = request.getParameter("description");

            if (reportType == null || (!"Lost".equalsIgnoreCase(reportType) && !"Damaged".equalsIgnoreCase(reportType))) {
                reportType = "Damaged";
            }

            boolean ok = lostDamagedDAO.createReport(issueId, bookId, student.getId(), reportType, description);
            if (ok) {
                session.setAttribute("flashSuccess", "Your report for " + reportType.toLowerCase() + " book has been submitted for administrative review.");
            } else {
                session.setAttribute("flashError", "Unable to submit report. Please verify this is an active loan.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flashError", "Invalid report submission data.");
        }

        response.sendRedirect("StudentIssuedBooksServlet");
    }
}
