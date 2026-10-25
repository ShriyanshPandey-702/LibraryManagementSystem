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
import dao.ReviewDAO;
import model.Book;
import model.Student;

@WebServlet("/StudentViewBooksServlet")
public class StudentViewBooksServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentUser") == null) {
            response.sendRedirect("StudentLoginServlet");
            return;
        }

        Student student = (Student) session.getAttribute("studentUser");

        String keyword = request.getParameter("keyword");
        String category = request.getParameter("category");
        String availability = request.getParameter("availability");
        String sortBy = request.getParameter("sortBy");
        String ratingParam = request.getParameter("minRating");
        String yearParam = request.getParameter("year");

        Integer minRating = null;
        if (ratingParam != null && !ratingParam.trim().isEmpty()) {
            try { minRating = Integer.parseInt(ratingParam.trim()); } catch (Exception ignored) {}
        }

        Integer year = null;
        if (yearParam != null && !yearParam.trim().isEmpty()) {
            try { year = Integer.parseInt(yearParam.trim()); } catch (Exception ignored) {}
        }

        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try { page = Integer.parseInt(pageParam.trim()); if (page < 1) page = 1; } catch (Exception ignored) {}
        }
        int pageSize = 12;
        int offset = (page - 1) * pageSize;

        List<Book> books = bookDAO.searchBooksAdvanced(keyword, category, availability, minRating, year, sortBy, offset, pageSize);

        request.setAttribute("books", books);
        request.setAttribute("categories", bookDAO.getAllCategories());
        request.setAttribute("keyword", keyword != null ? keyword : "");
        request.setAttribute("category", category != null ? category : "ALL");
        request.setAttribute("availability", availability != null ? availability : "all");
        request.setAttribute("sortBy", sortBy != null ? sortBy : "recent");
        request.setAttribute("minRating", minRating);
        request.setAttribute("year", year);
        request.setAttribute("currentPage", page);

        if ("1".equals(request.getParameter("requested"))) {
            request.setAttribute("successMessage", "Book request submitted successfully.");
        }
        if ("1".equals(request.getParameter("requestError"))) {
            request.setAttribute("errorMessage", "Unable to submit book request. Please try again.");
        }

        request.getRequestDispatcher("jsp/student-view-books.jsp").forward(request, response);
    }
}
