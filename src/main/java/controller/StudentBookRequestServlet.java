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
import dao.StudentDAO;
import model.Book;
import model.BookRequest;
import model.Student;

@WebServlet("/StudentBookRequestServlet")
public class StudentBookRequestServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final StudentDAO studentDAO = new StudentDAO();
    private final BookRequestDAO bookRequestDAO = new BookRequestDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentUser") == null) {
            response.sendRedirect("StudentLoginServlet");
            return;
        }

        if (session.getAttribute("adminUser") != null) {
            response.sendRedirect("DashboardServlet");
            return;
        }

        try {
            int bookId = Integer.parseInt(request.getParameter("bookId"));
            Student student = (Student) session.getAttribute("studentUser");
            
            if (student == null || bookId <= 0) {
                response.sendRedirect("StudentViewBooksServlet?requestError=1");
                return;
            }

            // Check for duplicate pending request
            if (bookRequestDAO.hasPendingRequest(student.getId(), bookId)) {
                request.setAttribute("errorMessage", "You already have a pending request for this book.");
                request.setAttribute("books", bookDAO.getAvailableBooks());
                request.getRequestDispatcher("jsp/student-view-books.jsp").forward(request, response);
                return;
            }

            Book book = bookDAO.getBookById(bookId);
            if (book == null) {
                response.sendRedirect("StudentViewBooksServlet?requestError=1");
                return;
            }

            BookRequest bookRequest = new BookRequest();
            bookRequest.setStudentId(student.getId());
            bookRequest.setStudentName(student.getName());
            bookRequest.setCourse(student.getCourse());
            bookRequest.setYear(student.getYear());
            bookRequest.setBookId(book.getBookId());
            bookRequest.setBookTitle(book.getTitle());

            if (bookRequestDAO.createRequest(bookRequest)) {
                response.sendRedirect("StudentViewBooksServlet?requested=1");
            } else {
                response.sendRedirect("StudentViewBooksServlet?requestError=1");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("StudentViewBooksServlet?requestError=1");
        }
    }
}
