package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookDAO;
import model.Book;

@WebServlet("/AddBookServlet")
public class AddBookServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();

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

        request.getRequestDispatcher("jsp/add-book.jsp").forward(request, response);
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
            String title = request.getParameter("title");
            String author = request.getParameter("author");
            String category = request.getParameter("category");
            if ("Other".equalsIgnoreCase(category)) {
                String custom = request.getParameter("customCategory");
                if (custom != null && !custom.trim().isEmpty()) {
                    category = custom.trim();
                }
            }
            
            String isbn = request.getParameter("isbn");
            if (isbn != null) {
                isbn = isbn.replaceAll("[^0-9]", ""); 
            }

            if (isbn == null || isbn.length() != 13) {
                request.setAttribute("errorMessage", "ISBN must be exactly 13 digits");
                request.getRequestDispatcher("jsp/add-book.jsp").forward(request, response);
                return;
            }

            if (bookDAO.isIsbnExists(isbn, 0)) {
                request.setAttribute("errorMessage", "ISBN already exists");
                request.getRequestDispatcher("jsp/add-book.jsp").forward(request, response);
                return;
            }

            String rackNo = request.getParameter("rack_no");
            double price = Double.parseDouble(request.getParameter("price"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            Book book = new Book();
            book.setTitle(title);
            book.setAuthor(author);
            book.setCategory(category);
            book.setIsbn(isbn);
            book.setRackNo(rackNo);
            book.setPrice(price);
            book.setQuantity(quantity);

            boolean added = bookDAO.addBook(book);
            if (added) {
                request.setAttribute("successMessage", "Book added successfully");
            } else {
                request.setAttribute("errorMessage", "Unable to add book");
            }

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Please enter valid values");
        }

        request.getRequestDispatcher("jsp/add-book.jsp").forward(request, response);
    }
}
