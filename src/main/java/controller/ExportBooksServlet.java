package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookDAO;
import model.Book;

@WebServlet("/ExportBooksServlet")
public class ExportBooksServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        List<Book> books = bookDAO.getAllBooks();

        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"library_catalog_" + System.currentTimeMillis() + ".csv\"");

        try (PrintWriter writer = response.getWriter()) {
            // Write CSV Header
            writer.println("Book ID,Title,Author,Category,ISBN,Rack Number,Price,Quantity");

            for (Book book : books) {
                writer.printf("%d,\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",%.2f,%d%n",
                        book.getBookId(),
                        escapeCsv(book.getTitle()),
                        escapeCsv(book.getAuthor()),
                        escapeCsv(book.getCategory()),
                        escapeCsv(book.getIsbn()),
                        escapeCsv(book.getRackNo()),
                        book.getPrice(),
                        book.getQuantity());
            }
        }
    }

    private String escapeCsv(String val) {
        if (val == null) return "";
        return val.replace("\"", "\"\"");
    }
}
