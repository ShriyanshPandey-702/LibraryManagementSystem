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

@WebServlet("/AddBookServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,        // 1 MB
    maxFileSize = 5 * 1024 * 1024,           // 5 MB
    maxRequestSize = 10 * 1024 * 1024        // 10 MB
)
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

        request.setAttribute("categories", bookDAO.getAllCategories());
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
            // Mandatory fields
            String title = request.getParameter("title");
            String author = request.getParameter("author");
            String quantityStr = request.getParameter("quantity");

            if (title == null || title.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Book title is required.");
                forwardToAddBook(request, response);
                return;
            }

            if (author == null || author.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Author name is required.");
                forwardToAddBook(request, response);
                return;
            }

            int quantity = 1;
            if (quantityStr != null && !quantityStr.trim().isEmpty()) {
                quantity = Integer.parseInt(quantityStr.trim());
                if (quantity < 0) quantity = 0;
            }

            // Optional fields
            String category = request.getParameter("category");
            if ("Other".equalsIgnoreCase(category)) {
                String custom = request.getParameter("customCategory");
                if (custom != null && !custom.trim().isEmpty()) {
                    category = custom.trim();
                }
            }

            String isbn = request.getParameter("isbn");
            if (isbn != null && !isbn.trim().isEmpty()) {
                isbn = isbn.trim();
                if (bookDAO.isIsbnExists(isbn, 0)) {
                    request.setAttribute("errorMessage", "A book with this ISBN already exists.");
                    forwardToAddBook(request, response);
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

            double price = 0.0;
            String priceStr = request.getParameter("price");
            if (priceStr != null && !priceStr.trim().isEmpty()) {
                try {
                    price = Double.parseDouble(priceStr.trim());
                } catch (Exception ignored) {}
            }

            // Optional cover image upload
            String coverImage = handleImageUpload(request);

            Book book = new Book();
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
            book.setCoverImage(coverImage);

            boolean added = bookDAO.addBook(book);
            if (added) {
                session.setAttribute("flashSuccess", "Book \"" + book.getTitle() + "\" added successfully to catalog.");
                response.sendRedirect("ViewBooksServlet");
                return;
            } else {
                request.setAttribute("errorMessage", "Unable to save book to database.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error processing book creation: " + e.getMessage());
        }

        forwardToAddBook(request, response);
    }

    private void forwardToAddBook(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("categories", bookDAO.getAllCategories());
        request.getRequestDispatcher("jsp/add-book.jsp").forward(request, response);
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

                // Save to webapp images/covers directory
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
            // Optional image upload should not fail the creation
            e.printStackTrace();
        }
        return null;
    }
}
