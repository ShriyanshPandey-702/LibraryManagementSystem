package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Security filter that protects all student servlet URLs.
 * Redirects unauthenticated requests to the student login page.
 */
@WebFilter(urlPatterns = {
        "/StudentDashboardServlet",
        "/StudentViewBooksServlet",
        "/StudentIssuedBooksServlet",
        "/StudentFineStatusServlet",
        "/StudentProfileServlet",
        "/StudentBookRequestServlet",
        "/StudentRequestBookServlet",
        "/StudentRenewBookServlet",
        "/StudentReturnBookServlet",
        "/StudentReservationsServlet",
        "/StudentReservationServlet",
        "/StudentReportBookServlet",
        "/StudentPayFineServlet",
        "/StudentBorrowingHistoryServlet",
        "/StudentConfirmIssueServlet",
        "/ReviewServlet"
})
public class StudentAuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        boolean loggedIn = session != null && session.getAttribute("studentId") != null;

        if (loggedIn) {
            resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            resp.setHeader("Pragma", "no-cache");
            resp.setHeader("X-Content-Type-Options", "nosniff");
            resp.setHeader("X-Frame-Options", "DENY");
            resp.setHeader("X-XSS-Protection", "1; mode=block");
            chain.doFilter(request, response);
        } else {
            resp.sendRedirect(req.getContextPath() + "/StudentLoginServlet");
        }
    }
}
