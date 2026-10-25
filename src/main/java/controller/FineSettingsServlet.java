package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.FineSettingsDAO;
import dao.SettingsDAO;

@WebServlet("/FineSettingsServlet")
public class FineSettingsServlet extends HttpServlet {

    private final FineSettingsDAO fineSettingsDAO = new FineSettingsDAO();
    private final SettingsDAO settingsDAO = new SettingsDAO();

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

        request.setAttribute("finePerDay", settingsDAO.getDoubleSetting("fine_per_day", 5.00));
        request.setAttribute("renewalDays", settingsDAO.getIntSetting("renewal_days", 7));
        request.setAttribute("maxBooksPerStudent", settingsDAO.getIntSetting("max_books_per_student", 3));
        request.setAttribute("pickupDays", settingsDAO.getIntSetting("reservation_pickup_days", 3));

        request.getRequestDispatcher("jsp/fine-settings.jsp").forward(request, response);
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
            String fineParam = request.getParameter("finePerDay");
            String renewalParam = request.getParameter("renewalDays");
            String maxBooksParam = request.getParameter("maxBooksPerStudent");
            String pickupDaysParam = request.getParameter("pickupDays");

            if (fineParam != null && !fineParam.trim().isEmpty()) {
                double fine = Double.parseDouble(fineParam.trim());
                if (fine >= 0) {
                    settingsDAO.updateSetting("fine_per_day", String.format("%.2f", fine));
                    fineSettingsDAO.updateFinePerDay(fine);
                }
            }

            if (renewalParam != null && !renewalParam.trim().isEmpty()) {
                int ren = Integer.parseInt(renewalParam.trim());
                if (ren > 0 && ren <= 60) {
                    settingsDAO.updateSetting("renewal_days", String.valueOf(ren));
                }
            }

            if (maxBooksParam != null && !maxBooksParam.trim().isEmpty()) {
                int maxB = Integer.parseInt(maxBooksParam.trim());
                if (maxB > 0 && maxB <= 50) {
                    settingsDAO.updateSetting("max_books_per_student", String.valueOf(maxB));
                }
            }

            if (pickupDaysParam != null && !pickupDaysParam.trim().isEmpty()) {
                int pickup = Integer.parseInt(pickupDaysParam.trim());
                if (pickup > 0 && pickup <= 30) {
                    settingsDAO.updateSetting("reservation_pickup_days", String.valueOf(pickup));
                }
            }

            request.setAttribute("successMessage", "Library policy settings updated successfully.");
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Invalid policy input. Please ensure numbers are positive.");
        }

        request.setAttribute("finePerDay", settingsDAO.getDoubleSetting("fine_per_day", 5.00));
        request.setAttribute("renewalDays", settingsDAO.getIntSetting("renewal_days", 7));
        request.setAttribute("maxBooksPerStudent", settingsDAO.getIntSetting("max_books_per_student", 3));
        request.setAttribute("pickupDays", settingsDAO.getIntSetting("reservation_pickup_days", 3));

        request.getRequestDispatcher("jsp/fine-settings.jsp").forward(request, response);
    }
}
