<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.BookReservation" %>
<%
    if (session.getAttribute("studentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/StudentLoginServlet");
        return;
    }
    List<BookReservation> reservations = (List<BookReservation>) request.getAttribute("reservations");

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    if (flashSuccess != null) session.removeAttribute("flashSuccess");

    String flashError = (String) session.getAttribute("flashError");
    if (flashError != null) session.removeAttribute("flashError");

    int count = reservations != null ? reservations.size() : 0;
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/student-navbar.jsp" />

<main class="page-content py-4">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">My Book Reservations</h1>
            <p class="page-subtitle">Track your waiting list queues, view pickup deadlines, and cancel pending reservations.</p>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-secondary">
                <i class="fas fa-magnifying-glass me-1"></i> Browse Catalog
            </a>
        </div>
    </header>

    <!-- Flash Alerts -->
    <% if (flashSuccess != null && !flashSuccess.isEmpty()) { %>
        <div class="alert alert-success mb-4" role="alert">
            <i class="fas fa-check-circle me-2"></i><%= flashSuccess %>
        </div>
    <% } %>
    <% if (flashError != null && !flashError.isEmpty()) { %>
        <div class="alert alert-danger mb-4" role="alert">
            <i class="fas fa-circle-exclamation me-2"></i><%= flashError %>
        </div>
    <% } %>

    <!-- Reservations Panel -->
    <div class="panel">
        <div class="panel-header d-flex justify-content-between align-items-center">
            <div class="d-flex align-items-center gap-2">
                <h2 class="panel-title">Reservation Queue Ledger</h2>
                <span class="badge-status badge-neutral"><%= count %> <%= count == 1 ? "Record" : "Records" %></span>
            </div>
            <span class="text-muted small">Automatic allocation on book return based on FIFO waitlist queue</span>
        </div>

        <div class="table-responsive">
            <table class="table-lib mb-0">
                <thead>
                    <tr>
                        <th style="width: 80px;">Res ID</th>
                        <th>Book Title</th>
                        <th>Reserved Date</th>
                        <th class="text-center">Queue Position</th>
                        <th class="text-center">Status</th>
                        <th>Pickup Deadline</th>
                        <th class="text-end" style="width: 130px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (reservations != null && !reservations.isEmpty()) {
                        for (BookReservation res : reservations) {
                            String st = res.getStatus();
                            boolean isPending = "Pending".equalsIgnoreCase(st);
                            boolean isAvailable = "Available".equalsIgnoreCase(st);
                            boolean isFulfilled = "Fulfilled".equalsIgnoreCase(st);
                            boolean isCancelled = "Cancelled".equalsIgnoreCase(st);
                            boolean isExpired = "Expired".equalsIgnoreCase(st);
                %>
                    <tr>
                        <td class="text-muted small">#<%= res.getId() %></td>
                        <td>
                            <strong class="book-title"><%= res.getBookTitle() %></strong>
                            <div class="text-muted small">Book ID #<%= res.getBookId() %></div>
                        </td>
                        <td class="text-muted small"><%= res.getCreatedAt() != null ? res.getCreatedAt().toString().substring(0, 16) : "—" %></td>
                        <td class="text-center">
                            <% if (isPending) { %>
                                <span class="badge-status badge-warning font-mono">
                                    #<%= res.getQueuePosition() > 0 ? res.getQueuePosition() : 1 %> in queue
                                </span>
                            <% } else if (isAvailable) { %>
                                <span class="badge-status badge-success">
                                    <i class="fas fa-bell me-1"></i> Ready for Pickup
                                </span>
                            <% } else { %>
                                <span class="text-muted small">—</span>
                            <% } %>
                        </td>
                        <td class="text-center">
                            <% if (isPending) { %>
                                <span class="badge-status badge-warning">Waiting</span>
                            <% } else if (isAvailable) { %>
                                <span class="badge-status badge-success">Copy Allocated</span>
                            <% } else if (isFulfilled) { %>
                                <span class="badge-status badge-neutral">Loan Issued</span>
                            <% } else if (isCancelled) { %>
                                <span class="badge-status badge-danger">Cancelled</span>
                            <% } else if (isExpired) { %>
                                <span class="badge-status badge-danger">Pickup Expired</span>
                            <% } else { %>
                                <span class="badge-status badge-neutral"><%= st %></span>
                            <% } %>
                        </td>
                        <td class="small">
                            <% if (res.getExpiryDate() != null) { %>
                                <span class="fw-semibold text-danger">
                                    <i class="fas fa-clock me-1"></i> <%= res.getExpiryDate().toString().substring(0, 16) %>
                                </span>
                            <% } else { %>
                                <span class="text-muted">—</span>
                            <% } %>
                        </td>
                        <td class="text-end">
                            <% if (isPending || isAvailable) { %>
                                <form id="cancelResForm-<%= res.getId() %>" action="<%= request.getContextPath() %>/StudentReservationServlet" method="post" class="d-inline m-0">
                                    <input type="hidden" name="action" value="cancel">
                                    <input type="hidden" name="reservationId" value="<%= res.getId() %>">
                                    <button type="button" class="btn-lib-secondary btn-sm text-danger"
                                            onclick="confirmCancelReservation(<%= res.getId() %>, '<%= res.getBookTitle().replace("'", "\\'") %>')"
                                            title="Cancel waiting list reservation">
                                        <i class="fas fa-xmark me-1"></i> Cancel
                                    </button>
                                </form>
                            <% } else { %>
                                <span class="text-muted small">—</span>
                            <% } %>
                        </td>
                    </tr>
                <%      }
                    } else {
                %>
                    <tr>
                        <td colspan="7">
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="fas fa-calendar-check"></i>
                                </div>
                                <h3 class="empty-state-title">No reservations on file</h3>
                                <p class="empty-state-text">
                                    You have no active waiting list reservations. When a desired book is out of stock, use the catalog reserve option to join the queue.
                                </p>
                                <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-primary btn-sm">
                                    <i class="fas fa-magnifying-glass me-1"></i> Browse Catalog
                                </a>
                            </div>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

</main>

<footer class="site-footer">
    <div class="container-xl d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span>&copy; Library Management System &bull; Academic Operations Platform</span>
        <span class="text-muted small">Waitlist &amp; Hold Ledger</span>
    </div>
</footer>

<script>
function confirmCancelReservation(id, title) {
    sweetConfirm('Cancel Reservation?', 'Cancel your reservation for "' + title + '" and forfeit your queue position?', 'Yes, Cancel Reservation', function() {
        document.getElementById('cancelResForm-' + id).submit();
    });
}
</script>

<jsp:include page="includes/footer.jsp" />
