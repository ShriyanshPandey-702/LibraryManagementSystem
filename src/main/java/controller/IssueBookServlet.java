package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookDAO;
import dao.BookRequestDAO;
import dao.IssueDAO;
import dao.StudentDAO;
import model.BookRequest;
import model.Student;

@WebServlet("/IssueBookServlet")
public class IssueBookServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final IssueDAO issueDAO = new IssueDAO();
    private final StudentDAO studentDAO = new StudentDAO();
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

        request.setAttribute("books", bookDAO.getAvailableBooks());
        request.setAttribute("students", studentDAO.getAllStudents());

        String requestIdParam = request.getParameter("requestId");
        if (requestIdParam != null && !requestIdParam.trim().isEmpty()) {
            try {
                int requestId = Integer.parseInt(requestIdParam);
                BookRequest bookRequest = bookRequestDAO.getRequestById(requestId);
                if (bookRequest != null && "Pending".equalsIgnoreCase(bookRequest.getStatus())) {
                    request.setAttribute("requestId", bookRequest.getId());
                    request.setAttribute("selectedBookId", bookRequest.getBookId());
                    request.setAttribute("selectedStudentId", bookRequest.getStudentId());
                    request.setAttribute("selectedCourse", bookRequest.getCourse());
                    request.setAttribute("selectedYear", bookRequest.getYear());
                    request.setAttribute("selectedSection", "A");
                }
            } catch (NumberFormatException ignored) {
            }
        }

        if ("1".equals(request.getParameter("issued"))) {
            request.setAttribute("successMessage", "Book issued successfully");
        }
        request.getRequestDispatcher("jsp/issue-book.jsp").forward(request, response);
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
            int bookId = Integer.parseInt(request.getParameter("bookId"));
            if (bookId <= 0) {
                request.setAttribute("error", "Please select a valid book");
                request.setAttribute("books", bookDAO.getAvailableBooks());
                request.setAttribute("students", studentDAO.getAllStudents());
                request.getRequestDispatcher("jsp/issue-book.jsp").forward(request, response);
                return;
            }

            if (!bookDAO.isBookAvailable(bookId)) {
                request.setAttribute("error", "Book is not available for issue");
                request.setAttribute("books", bookDAO.getAvailableBooks());
                request.setAttribute("students", studentDAO.getAllStudents());
                request.getRequestDispatcher("jsp/issue-book.jsp").forward(request, response);
                return;
            }

            int studentId = Integer.parseInt(request.getParameter("studentId"));
            Student student = studentDAO.getStudentById(studentId);
            if (student == null) {
                request.setAttribute("error", "Selected student not found");
                request.setAttribute("books", bookDAO.getAvailableBooks());
                request.setAttribute("students", studentDAO.getAllStudents());
                request.getRequestDispatcher("jsp/issue-book.jsp").forward(request, response);
                return;
            }

            String studentName = student.getName();
            String studentContact = student.getEmail();
            String course = request.getParameter("course");
            String year = request.getParameter("year");
            String section = request.getParameter("section");
            String dueDate = request.getParameter("dueDate");
            String requestIdParam = request.getParameter("requestId");
            int requestId = 0;
            if (requestIdParam != null && !requestIdParam.trim().isEmpty()) {
                requestId = Integer.parseInt(requestIdParam);
            }

            IssueDAO.IssueResult issueResult = issueDAO.issueBookWithDetails(bookId, studentId, studentName, studentContact,
                    course, year, section, dueDate);
            if (issueResult.isSuccess()) {
                if (requestId > 0) {
                    bookRequestDAO.markRequestApproved(requestId);
                    response.sendRedirect("AdminBookRequestsServlet?approved=1");
                    return;
                }
                response.sendRedirect("IssueBookServlet?issued=1");
                return;
            } else {
                request.setAttribute("error", issueResult.getMessage());
            }

        } catch (Exception e) {
            request.setAttribute("error", "Please provide valid issue details");
        }

        request.setAttribute("books", bookDAO.getAvailableBooks());
        request.setAttribute("students", studentDAO.getAllStudents());
        request.getRequestDispatcher("jsp/issue-book.jsp").forward(request, response);
    }
}
