<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.BookReservation" %>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    List<BookReservation> reservations = (List<BookReservation>) request.getAttribute("reservations");
    String statusFilter = (String) request.getAttribute("statusFilter");
    if (statusFilter == null) statusFilter = "ALL";

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    if (flashSuccess != null) session.removeAttribute("flashSuccess");

    String flashError = (String) session.getAttribute("flashError");
    if (flashError != null) session.removeAttribute("flashError");

    int count = reservations != null ? reservations.size() : 0;
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="page-content">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Reservations &amp; Waitlist Management</h1>
            <p class="page-subtitle">Inspect student waiting list queues, monitor physical copy allocations, and purge expired pickups.</p>
        </div>
        <div class="page-header-actions">
            <form action="<%= request.getContextPath() %>/AdminReservationsServlet" method="post" class="d-inline m-0">
                <input type="hidden" name="action" value="expireCheck">
                <button type="submit" class="btn-lib-secondary">
                    <i class="fas fa-clock-rotate-left me-1"></i> Check &amp; Expire Pickups
                </button>
            </form>
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

    <!-- Filter Bar -->
    <div class="panel mb-4">
        <div class="panel-body py-3">
            <form method="get" action="<%= request.getContextPath() %>/AdminReservationsServlet" class="row g-2 align-items-center">
                <div class="col-md-4">
                    <label class="form-label font-mono small mb-1">// STATUS FILTER</label>
                    <select name="status" class="form-select" onchange="this.form.submit()">
                        <option value="ALL" <%= "ALL".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>All Reservations</option>
                        <option value="Pending" <%= "Pending".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Pending in Queue</option>
                        <option value="Available" <%= "Available".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Ready for Pickup (Allocated)</option>
                        <option value="Fulfilled" <%= "Fulfilled".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Fulfilled (Issued)</option>
                        <option value="Expired" <%= "Expired".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Expired Pickups</option>
                        <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(statusFilter) ? "selected" : "" %>>Cancelled by Student</option>
                    </select>
                </div>
                <div class="col-md-2 d-grid align-self-end">
                    <a href="<%= request.getContextPath() %>/AdminReservationsServlet" class="btn-lib-secondary text-center">
                        <i class="fas fa-rotate-left me-1"></i> Reset
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- Reservations Table Panel -->
    <div class="panel">
        <div class="panel-header d-flex justify-content-between align-items-center">
            <div class="d-flex align-items-center gap-2">
                <h2 class="panel-title">Waitlist Queue Ledger</h2>
                <span class="badge-status badge-neutral"><%= count %> <%= count == 1 ? "Record" : "Records" %></span>
            </div>
            <span class="text-muted small">Queue order determines automatic allocation priority</span>
        </div>

        <div class="table-responsive">
            <table class="table-lib mb-0">
                <thead>
                    <tr>
                        <th style="width: 70px;">Res ID</th>
                        <th>Book Title</th>
                        <th>Student Account</th>
                        <th class="text-center">Waitlist Pos</th>
                        <th class="text-center">Status</th>
                        <th>Created At</th>
                        <th>Pickup Deadline</th>
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
                        <td>
                            <strong><%= res.getStudentName() != null ? res.getStudentName() : "Student #" + res.getStudentId() %></strong>
                            <div class="text-muted small">ID #<%= res.getStudentId() %></div>
                        </td>
                        <td class="text-center">
                            <% if (isPending) { %>
                                <span class="badge-status badge-warning font-mono">
                                    Queue #<%= res.getQueuePosition() > 0 ? res.getQueuePosition() : 1 %>
                                </span>
                            <% } else if (isAvailable) { %>
                                <span class="badge-status badge-success">
                                    <i class="fas fa-box-open me-1"></i> Allocated
                                </span>
                            <% } else { %>
                                <span class="text-muted small">—</span>
                            <% } %>
                        </td>
                        <td class="text-center">
                            <% if (isPending) { %>
                                <span class="badge-status badge-warning">Waiting</span>
                            <% } else if (isAvailable) { %>
                                <span class="badge-status badge-success">Ready for Pickup</span>
                            <% } else if (isFulfilled) { %>
                                <span class="badge-status badge-neutral">Fulfilled</span>
                            <% } else if (isCancelled) { %>
                                <span class="badge-status badge-danger">Cancelled</span>
                            <% } else if (isExpired) { %>
                                <span class="badge-status badge-danger">Expired</span>
                            <% } else { %>
                                <span class="badge-status badge-neutral"><%= st %></span>
                            <% } %>
                        </td>
                        <td class="text-secondary small">
                            <%= res.getCreatedAt() != null ? res.getCreatedAt().toString().substring(0, 16) : "—" %>
                        </td>
                        <td class="small">
                            <% if (res.getExpiryDate() != null) { %>
                                <span class="<%= isAvailable ? "fw-bold text-danger" : "text-muted" %>">
                                    <i class="fas fa-clock me-1"></i> <%= res.getExpiryDate().toString().substring(0, 16) %>
                                </span>
                            <% } else { %>
                                <span class="text-muted">—</span>
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
                                <h3 class="empty-state-title">No reservations found</h3>
                                <p class="empty-state-text">
                                    There are currently no book reservations matching the selected filter.
                                </p>
                            </div>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

</div><!-- /.page-content -->

<jsp:include page="includes/admin-footer.jsp" />
<jsp:include page="includes/footer.jsp" />
