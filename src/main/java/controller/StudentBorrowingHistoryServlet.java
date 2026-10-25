package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.IssueDAO;
import model.IssueRecord;
import model.Student;

@WebServlet("/StudentBorrowingHistoryServlet")
public class StudentBorrowingHistoryServlet extends HttpServlet {

    private final IssueDAO issueDAO = new IssueDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/StudentLoginServlet");
            return;
        }

        Student student = (Student) session.getAttribute("studentUser");
        int studentId = student.getId();

        String search = request.getParameter("search");
        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        List<IssueRecord> historyList = issueDAO.getBorrowingHistory(studentId, search, status, startDate, endDate);
        IssueDAO.LifetimeStats stats = issueDAO.getLifetimeStats(studentId);

        request.setAttribute("historyList", historyList);
        request.setAttribute("stats", stats);
        request.setAttribute("currentSearch", search != null ? search.trim() : "");
        request.setAttribute("currentStatus", status.trim().toUpperCase());
        request.setAttribute("currentStartDate", startDate != null ? startDate.trim() : "");
        request.setAttribute("currentEndDate", endDate != null ? endDate.trim() : "");

        request.getRequestDispatcher("jsp/student-borrowing-history.jsp").forward(request, response);
    }
}
