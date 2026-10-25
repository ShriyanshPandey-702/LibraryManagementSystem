package controller;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import dao.BookDAO;
import model.Book;

@WebServlet("/UpdateBookServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 10 * 1024 * 1024
)
public class UpdateBookServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String title = request.getParameter("title");
            String author = request.getParameter("author");

            if (title == null || title.trim().isEmpty() || author == null || author.trim().isEmpty()) {
                session.setAttribute("flashError", "Title and Author are mandatory fields.");
                response.sendRedirect("EditBookServlet?id=" + id);
                return;
            }

            int quantity = 1;
            String quantityStr = request.getParameter("quantity");
            if (quantityStr != null && !quantityStr.trim().isEmpty()) {
                quantity = Integer.parseInt(quantityStr.trim());
                if (quantity < 0) quantity = 0;
            }

            double price = 0.0;
            String priceStr = request.getParameter("price");
            if (priceStr != null && !priceStr.trim().isEmpty()) {
                try {
                    price = Double.parseDouble(priceStr.trim());
                } catch (Exception ignored) {}
            }

            String category = request.getParameter("category");
            String isbn = request.getParameter("isbn");
            if (isbn != null && !isbn.trim().isEmpty()) {
                isbn = isbn.trim();
                if (bookDAO.isIsbnExists(isbn, id)) {
                    session.setAttribute("flashError", "ISBN already exists on another book.");
                    response.sendRedirect("EditBookServlet?id=" + id);
                    return;
                }
            } else {
                isbn = null;
            }

            String rackNo = request.getParameter("rack_no");
            String description = request.getParameter("description");
            String publisher = request.getParameter("publisher");

            Integer pubYear = null;
            String yearStr = request.getParameter("publication_year");
            if (yearStr != null && !yearStr.trim().isEmpty()) {
                try {
                    pubYear = Integer.parseInt(yearStr.trim());
                } catch (Exception ignored) {}
            }

            String newCoverImage = handleImageUpload(request);

            Book book = new Book();
            book.setBookId(id);
            book.setTitle(title.trim());
            book.setAuthor(author.trim());
            book.setCategory(category != null && !category.trim().isEmpty() ? category.trim() : null);
            book.setIsbn(isbn);
            book.setRackNo(rackNo != null && !rackNo.trim().isEmpty() ? rackNo.trim() : null);
            book.setDescription(description != null && !description.trim().isEmpty() ? description.trim() : null);
            book.setPublisher(publisher != null && !publisher.trim().isEmpty() ? publisher.trim() : null);
            book.setPublicationYear(pubYear);
            book.setPrice(price);
            book.setQuantity(quantity);
            book.setCoverImage(newCoverImage); // will be COALESCE'd in DAO if null

            boolean updated = bookDAO.updateBook(book);
            if (updated) {
                session.setAttribute("flashSuccess", "Book \"" + book.getTitle() + "\" updated successfully.");
            } else {
                session.setAttribute("flashError", "Unable to update book.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flashError", "Invalid data submitted.");
        }

        response.sendRedirect("ViewBooksServlet");
    }

    private String handleImageUpload(HttpServletRequest request) {
        try {
            Part filePart = request.getPart("cover_file");
            if (filePart != null && filePart.getSize() > 0) {
                String submittedName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String ext = "";
                int dotIndex = submittedName.lastIndexOf('.');
                if (dotIndex > 0) {
                    ext = submittedName.substring(dotIndex).toLowerCase();
                }
                if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".webp")) {
                    return null;
                }

                String newFileName = "cover_" + UUID.randomUUID().toString().substring(0, 8) + ext;
                String uploadPath = request.getServletContext().getRealPath("/images/covers");
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                File destFile = new File(uploadDir, newFileName);
                try (InputStream in = filePart.getInputStream();
                     FileOutputStream out = new FileOutputStream(destFile)) {
                    byte[] buffer = new byte[8192];
                    int len;
                    while ((len = in.read(buffer)) > 0) {
                        out.write(buffer, 0, len);
                    }
                }
                return "images/covers/" + newFileName;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("ViewBooksServlet");
    }
}
