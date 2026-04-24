package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.BookDAO;
import model.Book;

@WebServlet("/UpdateBookServlet")
public class UpdateBookServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();

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
            int id = Integer.parseInt(request.getParameter("id"));
            String title = request.getParameter("title");
            String author = request.getParameter("author");
            String category = request.getParameter("category");
            String isbn = request.getParameter("isbn");
            String rackNo = request.getParameter("rack_no");
            double price = Double.parseDouble(request.getParameter("price"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            Book book = new Book();
            book.setBookId(id);
            book.setTitle(title);
            book.setAuthor(author);
            book.setCategory(category);
            book.setIsbn(isbn);
            book.setRackNo(rackNo);
            book.setPrice(price);
            book.setQuantity(quantity);

            bookDAO.updateBook(book);

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("ViewBooksServlet");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("ViewBooksServlet");
    }
}
