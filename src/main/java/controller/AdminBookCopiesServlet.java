package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookCopyDAO;
import dao.BookDAO;
import model.Book;
import model.BookCopy;

@WebServlet("/AdminBookCopiesServlet")
public class AdminBookCopiesServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final BookCopyDAO bookCopyDAO = new BookCopyDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        String bookIdParam = request.getParameter("bookId");
        if (bookIdParam == null || bookIdParam.trim().isEmpty()) {
            response.sendRedirect("ViewBooksServlet");
            return;
        }

        try {
            int bookId = Integer.parseInt(bookIdParam.trim());
            Book book = bookDAO.getBookById(bookId);
            if (book == null) {
                response.sendRedirect("ViewBooksServlet");
                return;
            }

            List<BookCopy> copies = bookCopyDAO.getCopiesForBook(bookId);
            request.setAttribute("book", book);
            request.setAttribute("copies", copies);
            request.getRequestDispatcher("jsp/admin-book-copies.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ViewBooksServlet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        String action = request.getParameter("action");
        String bookIdParam = request.getParameter("bookId");

        if ("updateCopyStatus".equalsIgnoreCase(action)) {
            try {
                int copyId = Integer.parseInt(request.getParameter("copyId"));
                String status = request.getParameter("status");
                String conditionNotes = request.getParameter("conditionNotes");
                bookCopyDAO.updateCopyStatus(copyId, status, conditionNotes);
                session.setAttribute("flashSuccess", "Physical copy status updated.");
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("flashError", "Failed to update copy status.");
            }
        }

        response.sendRedirect("AdminBookCopiesServlet?bookId=" + bookIdParam);
    }
}
