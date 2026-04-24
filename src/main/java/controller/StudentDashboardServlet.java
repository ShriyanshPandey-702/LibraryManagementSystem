package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import dao.IssueDAO;
import dao.BookRequestDAO;
import model.Student;

@WebServlet("/StudentDashboardServlet")
public class StudentDashboardServlet extends HttpServlet {

    private final IssueDAO issueDAO = new IssueDAO();
    private final BookRequestDAO bookRequestDAO = new BookRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentUser") == null) {
            response.sendRedirect("StudentLoginServlet");
            return;
        }

        Student student = (Student) session.getAttribute("studentUser");
        int studentId = student.getId();

        request.setAttribute("borrowedCount", issueDAO.getStudentActiveBorrowedCount(studentId));
        request.setAttribute("totalFine", issueDAO.getStudentTotalFine(studentId));
        request.setAttribute("pendingRequests", bookRequestDAO.getStudentPendingRequestCount(studentId));

        request.getRequestDispatcher("jsp/student-dashboard.jsp").forward(request, response);
    }
}
