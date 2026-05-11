package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookDAO;
import model.Book;

@WebServlet("/StudentViewBooksServlet")
public class StudentViewBooksServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentUser") == null) {
            response.sendRedirect("StudentLoginServlet");
            return;
        }

        String keyword = request.getParameter("keyword");
        List<Book> books;
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            books = bookDAO.searchAvailableBooks(keyword.trim());
            request.setAttribute("keyword", keyword.trim());
        } else {
            books = bookDAO.getAvailableBooks();
        }

        if ("1".equals(request.getParameter("requested"))) {
            request.setAttribute("successMessage", "Book request submitted successfully.");
        }
        if ("1".equals(request.getParameter("requestError"))) {
            request.setAttribute("errorMessage", "Unable to submit book request. Please try again.");
        }

        request.setAttribute("books", books);
        request.getRequestDispatcher("jsp/student-view-books.jsp").forward(request, response);
    }
}
