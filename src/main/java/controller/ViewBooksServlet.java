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

@WebServlet("/ViewBooksServlet")
public class ViewBooksServlet extends HttpServlet {

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

        List<Book> books = bookDAO.searchBooksAdvanced(keyword, category, availability, minRating, year, sortBy, 0, 500);

        request.setAttribute("books", books);
        request.setAttribute("categories", bookDAO.getAllCategories());
        request.setAttribute("keyword", keyword != null ? keyword : "");
        request.setAttribute("category", category != null ? category : "ALL");
        request.setAttribute("availability", availability != null ? availability : "all");
        request.setAttribute("sortBy", sortBy != null ? sortBy : "recent");
        request.setAttribute("minRating", minRating);
        request.setAttribute("year", year);

        request.getRequestDispatcher("jsp/view-books.jsp").forward(request, response);
    }
}
