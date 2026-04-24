package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.FineSettingsDAO;

@WebServlet("/FineSettingsServlet")
public class FineSettingsServlet extends HttpServlet {

    private final FineSettingsDAO fineSettingsDAO = new FineSettingsDAO();

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

        request.setAttribute("finePerDay", fineSettingsDAO.getFinePerDay());
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
            double finePerDay = Double.parseDouble(request.getParameter("finePerDay"));
            boolean updated = fineSettingsDAO.updateFinePerDay(finePerDay);

            if (updated) {
                request.setAttribute("successMessage", "Fine settings updated successfully");
            } else {
                request.setAttribute("errorMessage", "Unable to update fine settings");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Please enter a valid fine amount");
        }

        request.setAttribute("finePerDay", fineSettingsDAO.getFinePerDay());
        request.getRequestDispatcher("jsp/fine-settings.jsp").forward(request, response);
    }
}
